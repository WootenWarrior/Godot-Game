extends TileMap

@export var grid_size : Vector2i
@export var spawn : Vector2i
@onready var tilemap = $"."
var grid : Array

func _ready():
	WorldManager.instantiate_players(1)
	WorldManager.spawn_players_in_scene(tilemap,spawn)
	init_grid()
	place_spawn_room()

func init_grid():
	for x in grid_size.x:
		for y in grid_size.y:
			grid.append(Vector2i(x,y))
	pass

func place_spawn_room():
	var room = WorldManager.get_random_room()
	room.global_position = WorldManager.players[0].global_position
	room.translate_room(tilemap)
	add_child(room)
