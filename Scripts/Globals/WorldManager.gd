extends Node

var player_scene = load("res://Scenes/Player.tscn")
var current_scene : Node2D
var num_of_players : int
var player = null
var players : Array
var rooms : Array
var boss_rooms : Array

func  _ready():
	var directory_path = "res://Scenes/Rooms/"
	var dir = DirAccess.open(directory_path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name:
		if file_name.ends_with(".tscn"):
			var _name = file_name.substr(0, file_name.length() - 5)
			var room = load(directory_path + file_name).instantiate()
			add_room(room)
		file_name = dir.get_next()
	dir.list_dir_end()

func spawn_player_in_scene(root_node : Node, spawn_pos : Vector2):
	player.position = spawn_pos
	root_node.add_child.call_deferred(player)

func create_player():
	player = player_scene.instantiate()

func add_room(room : Node2D):
	rooms.append(room)

func add_boss_room(room: Node2D):
	boss_rooms.append(room)

func get_random_room() -> Node2D:
	var room = randi_range(0, len(rooms)-1)
	return rooms[room]

func get_smallest_room() -> Node2D:
	var _room : Node2D
	var size = get_largest_room().size
	for room in rooms:
		if room.size <= size:
			size = room.size
			_room = room
	return _room

func get_largest_room() -> Node2D:
	var size = Vector2i(0,0)
	var _room : Node2D
	for room in rooms:
		if room.size > size:
			size = room.size
			_room = room
	return _room
