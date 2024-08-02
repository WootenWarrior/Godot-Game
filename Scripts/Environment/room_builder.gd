extends TileMap

@export_category("Dungeon Settings")
@export var dungeon_size : Vector2i
@export var number_of_rooms : int
@export var spawn_position : Vector2i
@export var room_spacing : int

@export_category("Room Settings")
@export var max_room_size : Vector2i
@export var min_room_size : Vector2i
@export var corridor_min_width : int
@export var corridor_max_width : int

@export_category("Tilemap settings")
@export var floor_layer : int
@export var walls_layer : int
@export var tilemap_ID : int
@export var floor_tile_coords : Vector2i

@onready var timer = $Timer
var rooms = []

func _ready():
	WorldManager.instantiate_players(1)
	WorldManager.spawn_players_in_scene($".",spawn_position)
	spawn_rooms($".")
	correct_overlapping_rooms($".")
	#for i in range(len(rooms)):
		#print("room at: ",rooms[i]["position"], " size: ", rooms[i]["size"])

func spawn_rooms(tilemap:TileMap):
	for i in range(number_of_rooms):
		var room_position = Vector2i.ZERO
		room_position.x = randi_range(0,dungeon_size.x)
		room_position.y = randi_range(0,dungeon_size.y)
		
		var room_size = Vector2i.ZERO
		room_size.x = randi_range(min_room_size.x,max_room_size.x)
		room_size.y = randi_range(min_room_size.y,max_room_size.y)
		
		rooms.append({"position": room_position, "size": room_size})
		
		for x in range(room_position.x,room_position.x + room_size.x):
			for y in range(room_position.y,room_position.y + room_size.y):
				var cell = Vector2i(x,y)
				tilemap.set_cell(floor_layer,cell,tilemap_ID,floor_tile_coords)

func correct_overlapping_rooms(tilemap:TileMap):
	#Let this comment be testiment to the worst bug so far in this code
	var rooms_solved = false
	var iterations = 0
	var max_iterations = number_of_rooms**2
	timer.start(1)
	while (not rooms_solved) and iterations < max_iterations:
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
			remove_room(room,tilemap)
		for room in new_rooms:
			place_room(room,tilemap)
		#print("num_of_rooms = ",len(rooms))
		#print(iterations)
		if iterations == max_iterations:
			print("max iterations reached")

func place_room(room:Dictionary,tilemap:TileMap):
	var room_pos = room["position"]
	var room_size = room["size"]
	for x in range(room_pos.x,room_pos.x+room_size.x):
		for y in range(room_pos.y,room_pos.y+room_size.y):
			var cell = Vector2i(x,y)
			tilemap.set_cell(floor_layer,cell,tilemap_ID,floor_tile_coords)
	rooms.append({"position": room_pos, "size": room_size})

func remove_room(room:Dictionary,tilemap:TileMap):
	var room_pos = room["position"]
	var room_size = room["size"]
	for x in range(room_pos.x,room_pos.x+room_size.x):
		for y in range(room_pos.y,room_pos.y+room_size.y):
			var cell = Vector2i(x,y)
			tilemap.set_cell(floor_layer,cell,-1,Vector2i.ZERO)
	
	rooms = rooms.filter(func(existing_room):
		return existing_room != room
	)

func is_rooms_overlapping(room1:Dictionary,room2:Dictionary) -> bool:
	var room1_pos = room1["position"]
	var room2_pos = room2["position"]
	var room1_size = room1["size"] + Vector2i(room_spacing,room_spacing)
	var room2_size = room2["size"] + Vector2i(room_spacing,room_spacing)
	
	var overlap_x = (room1_pos.x < room2_pos.x + room2_size.x and room1_pos.x + room1_size.x > room2_pos.x)
	var overlap_y = (room1_pos.y < room2_pos.y + room2_size.y and room1_pos.y + room1_size.y > room2_pos.y)
	
	return overlap_x and overlap_y

func move_rooms_apart(room1:Dictionary,room2:Dictionary) -> Array:
	var pos1 = room1["position"]
	var size1 = room1["size"]
	var pos2 = room2["position"]
	var size2 = room2["size"]
	
	var overlap_x = min(pos1.x + size1.x + room_spacing - pos2.x, pos2.x + size2.x + room_spacing - pos1.x)
	var overlap_y = min(pos1.y + size1.y + room_spacing - pos2.y, pos2.y + size2.y + room_spacing - pos1.y)
	
	print(Vector2(overlap_x,overlap_y))
	
	var new_pos1 = Vector2i.ZERO
	var new_pos2 = Vector2i.ZERO
	
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
	
	var new_room1 = {"position":new_pos1,"size":size1}
	var new_room2 = {"position":new_pos2,"size":size2}
	
	#print("old pos1 = ",pos1, " old pos 2 = ",pos2)
	#print("new pos1 = ", new_pos1, " new pos 2 = ",new_pos2)
	return [new_room1,new_room2]
