extends TileMap

@export_category("Dungeon Settings")
@export var dungeon_size : Vector2i
@export var number_of_rooms : int
@export var spawn_position : Vector2i
@export var room_spacing : int
@export var use_timer = false
@export var debugging = false
@export var dungeon_wall_background_offset : int

@export_category("Room Settings")
@export var max_room_size : Vector2i
@export var min_room_size : Vector2i
@export var corridor_min_width : int
@export var corridor_max_width : int
@export var corridor_max_length : int
@export var max_entrances : int
@export var max_pillar_number : int
@export var decor_edge_offset : int

@export_category("Tilemap settings")
@export var floor_layer : int
@export var walls_layer : int
@export var decor_layer : int
@export var tilemap_ID : int
@export var tile_size = 16

@export_category("Tile coords")
@export var floor_tile_coords : Vector2i
@export var test_tile_coords : Vector2i
@export var wall_tile_background : Vector2i
@export var pillar_bases : Array[Vector2i]

@onready var timer = $Timer
@onready var tilemap = $"."
var root_node : Node2D = null
var rooms = []
var connected_rooms = []
var astar = AStarGrid2D.new()

class Room:
	var pos : Vector2i
	var size : Vector2i
	var max_entrances : int
	var entrances : Array
	var corridor_min_width : int
	var corridor_max_width : int
	var pillars = []
	
	func _init(_pos:Vector2i,_size:Vector2i,_max_entrances:int,
	_corridor_min_width:int,_corridor_max_width:int):
		self.pos = _pos
		self.size = _size
		self.max_entrances = _max_entrances
		self.corridor_min_width = _corridor_min_width
		self.corridor_max_width = _corridor_max_width
	
	func get_room_center() -> Vector2i:
		return Vector2i(pos.x + (size.x/2), pos.y + (size.y/2))
	
	func generate_entrances() -> void:
		var num_of_entrances = randi_range(1,max_entrances)
		var edge_tiles = []
		var offset = corridor_max_width
		
		# Top edge
		for x in range(pos.x + offset, pos.x + size.x - offset):
			edge_tiles.append(Vector2i(x, pos.y))
		
		# Bottom edge
		for x in range(pos.x + offset, pos.x + size.x - offset):
			edge_tiles.append(Vector2i(x, pos.y + size.y - 1))
		
		# Left edge
		for y in range(pos.y + offset, pos.y + size.y - offset):
			edge_tiles.append(Vector2i(pos.x, y))
		
		# Right edge
		for y in range(pos.y + offset, pos.y + size.y - offset):
			edge_tiles.append(Vector2i(pos.x + size.x - 1, y))
		
		for i in range(num_of_entrances):
			if len(edge_tiles) > 0:
				var random_index = randi_range(0, len(edge_tiles) - 1)
				var entrance_pos = edge_tiles[random_index]
				entrances.append(entrance_pos)
				for x in range(entrance_pos.x - corridor_max_width-1, entrance_pos.x + corridor_max_width+1):
					for y in range(entrance_pos.y - corridor_max_width-1, entrance_pos.y + corridor_max_width-1):
						var _pos = Vector2i(x,y)
						edge_tiles = edge_tiles.filter(func(existing_pos): 
							return existing_pos != _pos)

func _ready() -> void:
	var min_room_length = min(min_room_size.x,min_room_size.y)
	var max_room_num = min(dungeon_size.x/10,dungeon_size.y/10)
	if min_room_length/2 < corridor_max_width:
		corridor_max_width = min_room_length/2
	if corridor_max_width < corridor_min_width:
		corridor_min_width = corridor_max_width - 1
	if number_of_rooms > max_room_num:
		number_of_rooms = max_room_num
	
	tile_size = tilemap.tile_set.tile_size.x
	
	var start_time = Time.get_ticks_msec()
	spawn_rooms()
	correct_overlapping_rooms()
	place_corridors()
	make_secret_rooms()
	draw_walls()
	spawn_decor()
	set_navigation_region()
	var end_time = Time.get_ticks_msec()
	spawn_position = get_player_spawn_point()
	
	root_node = get_tree().current_scene
	if !root_node:
		root_node = tilemap
	
	WorldManager.instantiate_players(1)
	WorldManager.spawn_players_in_scene(root_node,spawn_position,tile_size)
	
	if debugging:
		print_all_debug_info(start_time,end_time)

func spawn_rooms() -> void:
	for i in range(number_of_rooms):
		var room_position = Vector2i.ZERO
		room_position.x = randi_range(0,dungeon_size.x)
		room_position.y = randi_range(0,dungeon_size.y)
		
		var room_size = Vector2i.ZERO
		room_size.x = randi_range(min_room_size.x,max_room_size.x)
		room_size.y = randi_range(min_room_size.y,max_room_size.y)
		
		var new_room = Room.new(room_position,room_size,max_entrances,corridor_min_width,corridor_max_width)
		rooms.append(new_room)
		
		for x in range(room_position.x,room_position.x + room_size.x):
			for y in range(room_position.y,room_position.y + room_size.y):
				var cell = Vector2i(x,y)
				tilemap.set_cell(floor_layer,cell,tilemap_ID,floor_tile_coords)

func correct_overlapping_rooms() -> void:
	#Let this comment be testiment to the worst bug so far in this code
	var rooms_solved = false
	var iterations = 0
	var max_iterations = number_of_rooms**2
	timer.start(1)
	while (not rooms_solved) and iterations < max_iterations:
		if use_timer:
			timer.start()
			await timer.timeout
		iterations += 1
		rooms_solved = true
		
		var overlapping_rooms = []
		var new_rooms = []
		for room1 in rooms:
			for room2 in rooms:
				if room1 != room2 and not (overlapping_rooms.has(room1) or overlapping_rooms.has(room2)):
					if is_rooms_overlapping(room1,room2):
						#print("rooms_overlapping: ",room1,room2)
						rooms_solved = false
						var _new_rooms = move_rooms_apart(room1,room2)
						overlapping_rooms.append(room1)
						overlapping_rooms.append(room2)
						new_rooms.append(_new_rooms[0])
						new_rooms.append(_new_rooms[1])
		
		for room in overlapping_rooms:
			remove_room(room)
		for room in new_rooms:
			place_room(room)
		#print("num_of_rooms = ",len(rooms))
		#print(iterations)
		if iterations == max_iterations:
			print("max iterations reached")
	print(iterations)

func move_rooms_apart(room1:Room,room2:Room) -> Array:
	var pos1 = room1.pos
	var size1 = room1.size
	var pos2 = room2.pos
	var size2 = room2.size
	
	# Calculate exact overlap rect
	var overlap_x = min(pos1.x + size1.x + room_spacing - pos2.x, pos2.x + size2.x + room_spacing - pos1.x)
	var overlap_y = min(pos1.y + size1.y + room_spacing - pos2.y, pos2.y + size2.y + room_spacing - pos1.y)
	
	# Nessecary to avoid never exiting loop
	overlap_x += 1
	overlap_y += 1
	
	#print(Vector2(overlap_x,overlap_y))
	
	var new_pos1 = Vector2i.ZERO
	var new_pos2 = Vector2i.ZERO
	
	# Create new room positions based on relative room directions
	if pos1.x < pos2.x:								#to the left
		if pos1.y < pos2.y:							#above
			new_pos1.x = pos1.x - (overlap_x / 2)
			new_pos1.y = pos1.y - (overlap_y / 2)
			new_pos2.x = pos2.x + (overlap_x / 2)
			new_pos2.y = pos2.y + (overlap_y / 2)
		else:										#below
			new_pos1.x = pos1.x - (overlap_x / 2)
			new_pos1.y = pos1.y + (overlap_y / 2)
			new_pos2.x = pos2.x + (overlap_x / 2)
			new_pos2.y = pos2.y - (overlap_y / 2)
	else:											# to the right
		if pos1.y < pos2.y:							#above
			new_pos1.x = pos1.x + (overlap_x / 2)
			new_pos1.y = pos1.y - (overlap_y / 2)
			new_pos2.x = pos2.x - (overlap_x / 2)
			new_pos2.y = pos2.y + (overlap_y / 2)
		else:										#below
			new_pos1.x = pos1.x + (overlap_x / 2)
			new_pos1.y = pos1.y + (overlap_y / 2)
			new_pos2.x = pos2.x - (overlap_x / 2)
			new_pos2.y = pos2.y - (overlap_y / 2)
	
	var new_room1 = Room.new(new_pos1,size1,max_entrances,corridor_min_width,corridor_max_width)
	var new_room2 = Room.new(new_pos2,size2,max_entrances,corridor_min_width,corridor_max_width)
	
	#print("old pos1 = ",pos1, " old pos 2 = ",pos2)
	#print("new pos1 = ", new_pos1, " new pos 2 = ",new_pos2)
	return [new_room1,new_room2]

func place_room(room:Room) -> void:
	var room_pos = room.pos
	var room_size = room.size
	for x in range(room_pos.x,room_pos.x+room_size.x):
		for y in range(room_pos.y,room_pos.y+room_size.y):
			var cell = Vector2i(x,y)
			tilemap.set_cell(floor_layer,cell,tilemap_ID,floor_tile_coords)
	var new_room = Room.new(room_pos,room_size,max_entrances,corridor_min_width,corridor_max_width)
	rooms.append(new_room)

func remove_room(room:Room) -> void:
	var room_pos = room.pos
	var room_size = room.size
	for x in range(room_pos.x,room_pos.x+room_size.x):
		for y in range(room_pos.y,room_pos.y+room_size.y):
			var cell = Vector2i(x,y)
			tilemap.set_cell(floor_layer,cell,-1,Vector2i.ZERO)
	
	rooms = rooms.filter(func(existing_room) : return existing_room != room)

func is_rooms_overlapping(room1:Room,room2:Room) -> bool:
	var room1_pos = room1.pos
	var room2_pos = room2.pos
	var room1_size = room1.size + Vector2i(room_spacing,room_spacing)
	var room2_size = room2.size + Vector2i(room_spacing,room_spacing)
	
	var overlap_x = (room1_pos.x < room2_pos.x + room2_size.x and room1_pos.x + room1_size.x > room2_pos.x)
	var overlap_y = (room1_pos.y < room2_pos.y + room2_size.y and room1_pos.y + room1_size.y > room2_pos.y)
	
	#print(Vector2(overlap_x,overlap_y))
	return overlap_x and overlap_y

func place_corridors() -> void:
	for room in rooms:
		room.generate_entrances()
	
	setup_astar()
	set_rooms_as_solid()
	place_paths()
	pass

func setup_astar() -> void:
	var used_rect = tilemap.get_used_rect()
	used_rect.size = used_rect.size + Vector2i(corridor_max_width*2,corridor_max_width*2)
	used_rect.position = used_rect.position - Vector2i(corridor_max_width*2,corridor_max_width*2)
	astar.region = used_rect
	astar.cell_size = Vector2i(1,1)
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.jumping_enabled = false
	astar.update()

func set_rooms_as_solid() -> void:
	print("used rect = ",tilemap.get_used_rect())
	
	var size = tilemap.get_used_rect().size
	var pos = tilemap.get_used_rect().position
	for x in range(pos.x,pos.x+size.x):
		for y in range(pos.y,pos.y+size.y):
			var cell = Vector2i(x,y)
			astar.set_point_solid(cell,false)
	
	for room in rooms:
		var room_rect = Rect2i(room.pos,room.size)
		astar.fill_solid_region(room_rect)
		print(room_rect)
	
	for room in rooms:
		for entrance in room.entrances:
			var above = Vector2i(entrance.x,entrance.y - 1)
			var below = Vector2i(entrance.x,entrance.y + 1)
			var left = Vector2i(entrance.x - 1,entrance.y)
			var right = Vector2i(entrance.x + 1,entrance.y)
			var direction = Vector2i.ZERO
			var current_pos = Vector2i.ZERO
			if tilemap.get_cell_source_id(floor_layer,above) != tilemap_ID:
				direction.y += 1
			elif tilemap.get_cell_source_id(floor_layer,below) != tilemap_ID:
				direction.y -= 1
			elif tilemap.get_cell_source_id(floor_layer,left) != tilemap_ID:
				direction.x += 1
			elif tilemap.get_cell_source_id(floor_layer,right) != tilemap_ID:
				direction.x -= 1
			current_pos = entrance
			
			var width = corridor_max_width/2 + 1
			if direction.x != 0:
				for i in range(current_pos.y - width,current_pos.y + width):
					astar.set_point_solid(Vector2i(current_pos.x,i))
			else:
				for i in range(current_pos.x - width,current_pos.x + width):   #Here
					astar.set_point_solid(Vector2i(i,current_pos.y))

func place_paths() -> void:
	var taken_entrances = []
	for room in rooms:
		for entrance in room.entrances:
			astar.set_point_solid(entrance,false)
			if entrance in taken_entrances:
				continue
			
			var nearest_entrance = get_nearest_entrance(room,entrance)
			if nearest_entrance == Vector2i.ZERO:
				continue
			astar.set_point_solid(nearest_entrance,false)
			
			if astar.is_point_solid(entrance):
				print("entrance1 is solid!")
			if astar.is_point_solid(nearest_entrance):
				print("entrance2 is solid!")
			
			#print("entrance pair: ",[entrance,nearest_entrance])
			var path = astar.get_point_path(entrance,nearest_entrance)
			#print("path : ",path)
			for point in path:
				tilemap.set_cell(floor_layer,point,tilemap_ID,test_tile_coords)
				var width = randi_range(corridor_min_width,corridor_max_width)
				for dx in range(-width/2, width/2):
					for dy in range(-width/2, width/2):
						var corridor_point = point + Vector2(dx, dy)
						astar.set_point_solid(corridor_point,true)
						tilemap.set_cell(floor_layer, corridor_point, tilemap_ID, floor_tile_coords)
			taken_entrances.append(nearest_entrance)
			taken_entrances.append(entrance)

func make_secret_rooms():
	var unconnected_rooms = get_unconnected_rooms()
	for room in unconnected_rooms:
		print("secret room at :", room.pos)
		var center = room.get_room_center()

func draw_walls():
	var used_rect = tilemap.get_used_rect()
	var cells = []
	used_rect.position -= Vector2i(dungeon_wall_background_offset,dungeon_wall_background_offset)
	used_rect.size += Vector2i(dungeon_wall_background_offset*2,dungeon_wall_background_offset*2)
	for x in range(used_rect.position.x,used_rect.position.x+used_rect.size.x):
		for y in range(used_rect.position.y,used_rect.position.y+used_rect.size.y):
			var cell = Vector2i(x,y)
			if tilemap.get_cell_source_id(floor_layer,cell) != tilemap_ID:
				cells.append(cell)
	tilemap.set_cells_terrain_connect(walls_layer,cells,0,0,true)

func spawn_decor():
	for room in rooms:
		var num_of_pillars = randi_range(0,max_pillar_number)
		var possible_pillar_positions = []
		for x in range(room.pos.x+decor_edge_offset,room.pos.x+room.size.x-decor_edge_offset):
			for y in range(room.pos.y+decor_edge_offset,room.pos.y+room.size.y-decor_edge_offset):
				var cell = Vector2i(x,y)
				possible_pillar_positions.append(cell)
		
		for i in range(num_of_pillars):
			var pillar_base_pos = possible_pillar_positions[randi_range(0,len(possible_pillar_positions)-1)]
			var pillar_top_pos = pillar_base_pos + Vector2i(0,-1)
			possible_pillar_positions = possible_pillar_positions.filter(func(current_pos) : 
				return current_pos != pillar_base_pos or current_pos != pillar_top_pos)
			var base = pillar_bases[randi_range(0,len(pillar_bases)-1)]
			var top = pillar_bases[randi_range(0,len(pillar_bases)-1)] + Vector2i(0,-1)
			tilemap.set_cell(decor_layer, pillar_base_pos, tilemap_ID, base)
			tilemap.set_cell(decor_layer, pillar_top_pos, tilemap_ID, top)

func set_navigation_region():
	var nav_region = NavigationRegion2D.new()
	var navigation_mesh = NavigationPolygon.new()
	tilemap.add_child(nav_region)
	var used_rect = tilemap.get_used_rect()
	var outline = PackedVector2Array([
		used_rect.position,
		used_rect.position + Vector2i(0,used_rect.size.y),
		used_rect.position + used_rect.size,
		used_rect.position + Vector2i(0,used_rect.size.x)
		])
	navigation_mesh.add_outline(outline)
	nav_region.navigation_polygon = navigation_mesh
	nav_region.bake_navigation_polygon()

func get_nearest_room(_room:Room) -> Room:
	var nearest_room = null
	var room_center1 = _room.get_room_center()
	var nearest_coords = Vector2i(INF,INF)
	for room in rooms:
		if room == _room:
			continue
		var room_center2 = room.get_room_center()
		if room_center2 < nearest_coords - room_center1:
			nearest_coords = room_center2
			nearest_room = room
	return nearest_room

func get_room(_entrance:Vector2i) -> Room:
	var room = null
	for _room in rooms:
		for entrance in _room.entrances:
			if _entrance == entrance:
				room = _room
	return room

func get_nearest_entrance(_room:Room,_entrance:Vector2i) -> Vector2i:
	var nearest_entrance = Vector2i.ZERO
	var closest_distance = INF
	for room in rooms:
		if _room == room:
			continue
		for entrance in room.entrances:
			var distance = abs(_entrance.x - entrance.x) + abs(_entrance.y - entrance.y)
			if distance > corridor_max_length:
				continue
			if distance < closest_distance:
				closest_distance = distance
				nearest_entrance = entrance
	#print("corridor length: ", closest_distance)
	return nearest_entrance

func get_unconnected_rooms() -> Array:
	var unconnected_rooms = []
	for room in rooms:
		var unconnected_entrances = []
		for entrance in room.entrances:
			if astar.is_point_solid(entrance):
				unconnected_entrances.append(entrance)
		if len(unconnected_entrances) == len(room.entrances):
			unconnected_rooms.append(room)
	return unconnected_rooms

func get_player_spawn_point() -> Vector2i:
	var random_room = rooms[randi_range(0,len(rooms)-1)]
	var cell = random_room.get_room_center()
	var pos = cell
	tilemap.set_cell(decor_layer, cell, tilemap_ID, test_tile_coords)
	print("player pos: ", tilemap.local_to_map(pos))
	print("cell at: ", cell)
	return pos

func print_all_debug_info(start_time,end_time):
	for i in range(len(rooms)):
		print("room at: ",rooms[i].pos, 
		" size: ", rooms[i].size, 
		" entrance locations: ",rooms[i].entrances)
		for corridor in rooms[i].entrances:
			tilemap.set_cell(floor_layer,corridor,tilemap_ID,test_tile_coords)
			print(tilemap.get_surrounding_cells(corridor))
		if len(rooms[i].entrances) <= 0:
			print("no entrances")
	print("%s took %d ms" % ["Loading",end_time - start_time])
	# The loading time is proportional to the number of checks done
	# I.e if the dungeon is small and has lots of rooms, the loading time increases
