@tool

extends Node2D

@onready var floor_tilemap = $Floor
@onready var walls_tilemap = $Walls
@onready var decor_tilemap = $Decor
@onready var water_tilemap = $Water
@onready var step_timer = $StepTimer

@export_tool_button("Generate") var generate_button = generate
@export_tool_button("Clear") var clear_button = clear

@export_category("Room Generation Controls")
@export var width = 100
@export var height = 100
@export var number_of_entrances = 2
@export var lock_aspect = false
@export var square_size = Vector2(25,25)
@export var number_of_points = 10
@export var tile_size = 16
@export var noise_scale = 0.1
@export var floor_decor_noise_threshhold = 0.5
@export var water_noise_threshhold = 0.3
@export var misc_decor_noise_threshhold = 0.2
@export var enemy_count = 1
@export var generate_water = false
@export var keep_prev_layout = false

@export_category("Tiles")
@export var floor_tile = Vector2(5,0)
@export var closed_chest = Vector2(6,4)
@export var barrel = Vector2(5,10)
@export var door = Vector2(2,15)

@export_category("Misc")
@export var step_timer_enabled = false
@export var wait_time = 0.5

var size_limit = 1000
var floor_tile_coords = Vector2.ZERO
var floor_layer = 0
var points = []
var edge_cells = []

func generate():
	clear()
	var undo_redo = EditorInterface.get_editor_undo_redo()
	if wait_time > 0:
		step_timer.wait_time = wait_time
	
	await step_or_skip(func (): generate_floors())
	await step_or_skip(func (): generate_walls())
	await step_or_skip(func (): generate_decor())
	#await step_or_skip(func (): generate_entrances())
	await step_or_skip(func (): generate_navigation_region())
	await step_or_skip(func (): spawn_enemies())
	
	# TEMP
	await step_or_skip(func (): 
		#set_static_cam(walls_tilemap.get_used_rect())
		$Player.global_position = get_spawn_pos()
	)
	
	pass

func step_or_skip(function: Callable):
	if step_timer_enabled:
		step_timer.start()
		function.call()
		await step_timer.timeout
	else:
		function.call()

func generate_floors():
	var max_width = min(width,1000)
	var max_height = min(height,1000)
	
	# Keeps as squares
	if lock_aspect:
		max_width = max(width,height)
		max_height = max(width,height)
	
	# Generating small squares randomly from points
	for i in range(number_of_points):
		var point = Rect2i(randi_range(square_size.x,max_width-square_size.x), 
			randi_range(square_size.x,max_height-square_size.y), square_size.x, square_size.y)
		for x in range(point.position.x, point.position.x + point.size.x):
			for y in range(point.position.y, point.position.y + point.size.y):
				var cell = Vector2(x,y)
				floor_tilemap.set_cell(cell,0,Vector2(5,0),0)
		points.append(point)
	# Astar object for traversal within boundaries (i.e. where player can move)
	var astar = AStarGrid2D.new()
	var used_rect = floor_tilemap.get_used_rect()
	astar.region = Rect2i(used_rect.position.x - 1, used_rect.position.y - 1, 
		used_rect.size.x + 2, used_rect.size.y + 2)
	astar.cell_size = Vector2(1, 1)
	astar.update()
	
	# Log edge cells for wall placements
	edge_cells = []
	for point in points:
		for x in range(point.position.x - 1, point.position.x + point.size.x + 1):
			var top = Vector2(x,point.position.y - 1)
			var bottom = Vector2(x,point.position.y + point.size.y)
			
			if (floor_tilemap.get_cell_source_id(top) == -1):
				edge_cells.append(top)
			if (floor_tilemap.get_cell_source_id(bottom) == -1):
				edge_cells.append(bottom)
		for y in range(point.position.y - 1, point.position.y + point.size.y + 1):
			var left = Vector2(point.position.x - 1, y)
			var right = Vector2(point.position.x + point.size.x, y)
			
			if (floor_tilemap.get_cell_source_id(left) == -1):
				edge_cells.append(left)
			if (floor_tilemap.get_cell_source_id(right) == -1):
				edge_cells.append(right)
	
	# Set edge cells as boundary for astar
	for cell in edge_cells:
		astar.set_point_solid(cell)
	
	# Generate graph of points and their neighbours and determine if room is connected
	var connected = true
	var graph = {}
	for i in range(points.size()):
		var point1 = points[i]
		var start1 = Vector2i(point1.position.x, point1.position.y)
		
		if !graph.has(start1):
			graph[start1] = []
		
		for j in range(points.size() - 1):
			var point2 = points[j]
			
			if point2 == point1:
				continue
			
			var start2 = Vector2i(point2.position.x, point2.position.y)
			
			if !graph.has(start2):
				graph[start2] = []
			
			if astar.get_point_path(start1, start2, false):
				# Add bidirectional edge
				if !graph[start1].has(start2):
					graph[start1].append(start2)
				if !graph[start2].has(start1):
					graph[start2].append(start1)
			else:
				connected = false
	
	print(connected)
	if (!connected):
		# Depth first search to find subgraphs
		var visited = {}
		var subgraphs = []
		for point in points:
			var pos: Vector2i = point.position
			if pos not in visited:
				var subgraph = []
				dfs(visited, graph, pos, subgraph)
				subgraphs.append(subgraph)
		
		#print("graph: ", graph)
		#print("subgraphs: ", subgraphs)
		#print("visited points: ", visited)
		
		# Randomly select a point in each subgraph
		var points_to_connect = []
		for subgraph in subgraphs:
			var point = subgraph[randi_range(0, (subgraph.size() - 1))]
			points_to_connect.append(point)
		
		# Setup Astar object that ignores boundaries
		var astar_connect = AStarGrid2D.new()
		astar_connect.cell_size = Vector2(1, 1)
		astar_connect.region = floor_tilemap.get_used_rect()
		astar_connect.update()
		
		# Move from point to point generating new points at set intervals to create
		# a fully connected room
		var min_distance = floor(min(square_size.x /2,square_size.y /2))
		for i in range(points_to_connect.size() - 1):
			var counter = 0
			var point1 = points_to_connect[i]
			var point2 = points_to_connect[i + 1]
			var path = astar_connect.get_point_path(point1, point2, false)
			#print(path)
			#print("point1: ", point1)
			#print("point2: ", point2)
			for j in range(path.size()):
				counter += 1
				var new_point = path[j]
				if counter > min_distance:
					#var new_point_rect = Rect2i(
						#new_point.x - floor(square_size.x / 2),
						#new_point.y - floor(square_size.y / 2),
						#square_size.x,
						#square_size.y
						#)
					var new_point_rect = Rect2i(
						new_point.x,
						new_point.y,
						square_size.x,
						square_size.y
						)
					points.append(new_point_rect)
					counter = 0
		
		print("all_points: ", points)
		for point in points:
			for x in range(point.position.x, point.position.x + point.size.x):
				for y in range(point.position.y, point.position.y + point.size.y):
					var cell = Vector2(x,y)
					if floor_tilemap.get_cell_source_id(cell) == -1:
						floor_tilemap.set_cell(cell,0,Vector2(5,0),0)
		
		# Recalculate edge cells
		var new_used_rect = floor_tilemap.get_used_rect()
		astar.region = Rect2i(new_used_rect.position.x - 1, new_used_rect.position.y - 1, 
			new_used_rect.size.x + 2, new_used_rect.size.y + 2)
		astar.update()
		
		for cell in edge_cells:
			astar.set_point_solid(cell, false)
		
		edge_cells = []
		for point in points:
			for x in range(point.position.x - 1, point.position.x + point.size.x + 1):
				var top = Vector2(x,point.position.y - 1)
				var bottom = Vector2(x,point.position.y + point.size.y)
				
				if (floor_tilemap.get_cell_source_id(top) == -1):
					edge_cells.append(top)
				if (floor_tilemap.get_cell_source_id(bottom) == -1):
					edge_cells.append(bottom)
			for y in range(point.position.y - 1, point.position.y + point.size.y + 1):
				var left = Vector2(point.position.x - 1, y)
				var right = Vector2(point.position.x + point.size.x, y)
				
				if (floor_tilemap.get_cell_source_id(left) == -1):
					edge_cells.append(left)
				if (floor_tilemap.get_cell_source_id(right) == -1):
					edge_cells.append(right)
		
		# Set edge cells as boundary for astar
		for cell in edge_cells:
			astar.set_point_solid(cell)

func dfs(visited, graph, node, subgraph):
	if !visited.has(node):
		visited[node] = 1
		subgraph.append(node)
	for neighbour in graph[node]:
		if !visited.has(neighbour):
			dfs(visited, graph, neighbour, subgraph)

func generate_walls():
	# Connect all the top wall tiles around the boundary
	walls_tilemap.set_cells_terrain_connect(edge_cells,0,1,false)
	
	# Set all the front facing wall tiles to the correct terrain
	var front_walls = []
	var wall_decor = []
	for cell in edge_cells:
		var left = Vector2(cell.x - 1,cell.y + 1)
		var right = Vector2(cell.x + 1,cell.y + 1)
		var below = Vector2i(cell.x,cell.y + 1)
		var below_2 = Vector2i(cell.x,cell.y + 2)
		var below_3 = Vector2i(cell.x,cell.y + 3)
		if ((floor_tilemap.get_cell_source_id(below) != -1) 
			&& (walls_tilemap.get_cell_source_id(below) == -1)):
			front_walls.append(below)
			front_walls.append(below_2)
			wall_decor.append(below_3)
	
	walls_tilemap.set_cells_terrain_connect(front_walls,0,0,false)
	walls_tilemap.set_cells_terrain_connect(wall_decor,0,2,false)
	
	pass

func generate_decor():
	# Floor decor
	var used_rect = floor_tilemap.get_used_rect()
	var floor_decor_noise = create_noise()
	var water_noise = create_noise()
	
	var floor_decor_tiles = []
	var water_tiles = []
	for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
		for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
			var cell = Vector2i(x,y)
			var floor_decor_noise_value = floor_decor_noise.get_noise_2d(x,y)
			floor_decor_noise_value = (floor_decor_noise_value + 1) / 2
			var water_noise_value = floor_decor_noise.get_noise_2d(x,y)
			water_noise_value = (water_noise_value + 1) / 2
			
			if ((floor_decor_noise_value > floor_decor_noise_threshhold) 
				&& (floor_tilemap.get_cell_source_id(cell) != -1)):
				floor_decor_tiles.append(cell)
			if ((water_noise_value < water_noise_threshhold) 
				&& (water_tilemap.get_cell_source_id(cell) != -1)
				&& generate_water):
				water_tiles.append(cell)
	
	decor_tilemap.set_cells_terrain_connect(water_tiles,0,0,true)
	floor_tilemap.set_cells_terrain_connect(floor_decor_tiles,0,0,false)
	
	# Walls decor
	
	# Misc decor
	var misc_decor_noise = create_noise()
	for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
		for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
			var cell = Vector2i(x,y)
			var below_cell = Vector2i(x,y - 1)
			var misc_decor_noise_value = misc_decor_noise.get_noise_2d(x,y)
			misc_decor_noise_value = (misc_decor_noise_value + 1) / 2
			if ((misc_decor_noise_value < misc_decor_noise_threshhold) 
				&& (floor_tilemap.get_cell_source_id(cell) != -1)
				&& (walls_tilemap.get_cell_source_id(cell) == -1)):
				decor_tilemap.set_cell(cell,0,barrel,0)
	pass

func generate_entrances():
	# TODO Only check entrance possibility on edges of used rect
	# TODO Allow vertical entrances
	
	var possible_places = []
	for cell in edge_cells:
		var air_cells = [
			Vector2i(cell.x - 1, cell.y - 1), 
			Vector2i(cell.x, cell.y - 1),
			Vector2i(cell.x + 1, cell.y - 1)
		]
		var wall_cells = [
			Vector2i(cell.x - 2, cell.y), 
			Vector2i(cell.x - 1, cell.y), 
			cell, 
			Vector2i(cell.x + 1, cell.y),
			Vector2i(cell.x + 2, cell.y),
		]
		var valid = true
		for wall_cell in wall_cells:
			if walls_tilemap.get_cell_source_id(wall_cell) == -1:
				valid = false
		
		for air_cell in air_cells:
			if walls_tilemap.get_cell_source_id(air_cell) != -1:
				valid = false
			if floor_tilemap.get_cell_source_id(air_cell) != -1:
				valid = false
		
		if valid:
			possible_places.append(cell)
	
	var entrances = []
	for i in range(number_of_entrances):
		var random = randi_range(0, (len(possible_places) - 1))
		entrances.append(possible_places[random])
		possible_places.remove_at(random)
		possible_places.remove_at(random + 1)
		possible_places.remove_at(random - 1)
	
	for entrance in entrances:
		var x = entrance.x
		var y = entrance.y
		var positions_to_clear = [
			Vector2i(x, y),
			Vector2i(x - 1, y),
			Vector2i(x + 1, y),
			Vector2i(x - 1, y + 1),
			Vector2i(x + 1, y + 1),
			Vector2i(x, y + 2),
			Vector2i(x - 1, y + 2),
			Vector2i(x + 1, y + 2),
		]
		
		var door_position = Vector2i(x, y + 1)
		walls_tilemap.set_cell(door_position, 0, door, 0)
		for tilemap in [walls_tilemap, floor_tilemap]:
			for pos in positions_to_clear:
				tilemap.set_cell(pos, -1, Vector2i.ZERO, 0)
	
	pass

func generate_navigation_region():
	pass

func spawn_enemies():
	pass

func get_spawn_pos() -> Vector2i:
	var point_num = randi_range(0, (len(points) - 1))
	var point = points[point_num]
	return Vector2i((point.position.x + (point.size.x / 2)) * tile_size, 
		(point.position.y + (point.size.y / 2)) * tile_size)

func get_room_center() -> Rect2i:
	return floor_tilemap.get_used_rect()

func set_static_cam(rect: Rect2i):
	var viewport_size = $StaticCamera.get_viewport_rect().size
	var zoom = 1 / max((viewport_size.x / rect.size.x), (viewport_size.y / rect.size.y))
	print(zoom)
	$StaticCamera.global_position = Vector2i((rect.position.x + (rect.size.x / 2)) * tile_size,
		(rect.position.x + (rect.size.x / 2)) * tile_size)
	$StaticCamera.zoom = Vector2i(zoom, zoom)
	pass

func create_noise() -> FastNoiseLite:
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = noise_scale
	return noise

func clear():
	if (!keep_prev_layout):
		points.clear()
	floor_tilemap.clear()
	decor_tilemap.clear()
	walls_tilemap.clear()
