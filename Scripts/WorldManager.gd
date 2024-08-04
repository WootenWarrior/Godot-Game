extends Node

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

func spawn_players_in_scene(root_node : Node, spawn_pos : Vector2, tile_size : int):
	spawn_pos *= tile_size
	var num_of_players = len(players)
	var radius = 100
	var angle_step = 2*PI / num_of_players
	
	if num_of_players > 1:
		for i in range(num_of_players):
			var angle = i * angle_step
			var pos_x = spawn_pos.x + radius * cos(angle)
			var pos_y = spawn_pos.y + radius * sin(angle)
			var player_pos = Vector2(pos_x,pos_y)
			var player = players[i]
			player.position = player_pos
			root_node.add_child.call_deferred(player)
	else:
		var player = players[0]
		player.global_position = spawn_pos
		root_node.add_child.call_deferred(player)

func instantiate_players(num_of_players:int) -> void:
	for i in num_of_players:
		var player = load("res://Scenes/Player.tscn").instantiate()
		player.player_number = i
		add_player(player)

func add_player(_player) -> void:
	players.append(_player)

func set_player(_player, index : int) -> void:
	players[index] = _player

func get_players() -> Array:
	return players

func get_player(index : int) -> Node2D:
	return players[index]

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
