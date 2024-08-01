extends TileMap

@export var num_of_rooms : int
@export var room_positions : Array[Vector2i]
@export var room_sizes : Array[Vector2i]
@export var tilemap_ID : int
@export var floor_layer : int
@export var floor_tile_cell : Vector2i
@export var wall_layer : int
@export var min_room_size : Vector2i
@export_category("WallTilesAdjacent")
@export var wall_tile_above : Vector2i
@export var wall_tile_below : Vector2i
@export var wall_tile_right : Vector2i
@export var wall_tile_left : Vector2i
@export_category("WallTilesNonAdjacent")
@export var wall_tile_top_right : Vector2i
@export var wall_tile_top_left : Vector2i
@export var wall_tile_bottom_right : Vector2i
@export var wall_tile_bottom_left : Vector2i
@onready var tilemap = $"."
var size : Vector2i
var room_spawn_position : Vector2i
var tile_size = 16

func _ready():
	build_rooms(tilemap)
	if $"..":
		WorldManager.instantiate_players(1)
		WorldManager.spawn_players_in_scene($"..",room_spawn_position)
	else:
		WorldManager.instantiate_players(1)
		WorldManager.spawn_players_in_scene(tilemap,room_spawn_position)
	var used_rect = tilemap.get_used_rect()
	size = Vector2i(used_rect.size.x,used_rect.size.y)

func translate_rooms(destination:TileMap):
	var used_rect = tilemap.get_used_rect()
	
	for x in range(used_rect.position.x,used_rect.end.x):
		for y in range(used_rect.position.y, used_rect.end.y):
			var cell = Vector2i(x, y)
			
			var tile_id = tilemap.get_cell_source_id(cell)
			var alternative_tile_id = tilemap.get_cell_alternative_tile_id(cell)
			var _transform = tilemap.get_cell_transform(cell)
			var autotile_coord = tilemap.get_cell_autotile_coord(cell)
			
			destination.set_cell(cell, tile_id)
			destination.set_cell_alternative_tile_id(cell, alternative_tile_id)
			destination.set_cell_transform(cell, _transform)
			destination.set_cell_autotile_coord(cell, autotile_coord)
	
	destination.update_dirty_quadrants()

func build_rooms(destination:TileMap):
	for room_num in range(num_of_rooms):
		var room_position = room_positions[room_num-1]
		var room_size = room_sizes[room_num-1]
		if room_size < min_room_size:
			room_size = min_room_size
		
		if room_num == 0:
			var center = Vector2i((room_size.x+room_position.x)/2,(room_size.y+room_position.y)/2)
			print(center)
			room_spawn_position = center*tile_size*tilemap.scale.x
		
		for x in range(room_size.x):
			for y in range(room_size.y):
				var cell = Vector2i(x+room_position.x,y+room_position.y)
				destination.set_cell(floor_layer,cell,tilemap_ID,floor_tile_cell)
	place_walls(destination)

func place_walls(destination:TileMap):
	var used_rect = destination.get_used_rect()
	
	for x in range(used_rect.position.x,used_rect.end.x):
		for y in range(used_rect.position.y, used_rect.end.y):
			var cell = Vector2i(x,y)
			var above_cell = Vector2i(x,y-1)
			var below_cell = Vector2i(x,y+1)
			var left_cell = Vector2i(x+1,y)
			var right_cell = Vector2i(x-1,y)
			
			var top_left_cell = Vector2i(x-1,y-1)
			var top_right_cell = Vector2i(x+1,y-1)
			var bottom_left_cell = Vector2i(x-1,y+1)
			var bottom_right_cell = Vector2i(x+1,y+1)
			
			if x == used_rect.position.x:
				if y == used_rect.position.y:
					place_corner(top_left_cell,destination,wall_tile_top_left)
				elif y == used_rect.end.y:
					place_corner(bottom_left_cell,destination,wall_tile_bottom_left)
			elif x == used_rect.end.x:
				if y == used_rect.position.y:
					place_corner(top_right_cell,destination,wall_tile_top_right)
				elif y == used_rect.end.y:
					place_corner(bottom_right_cell,destination,wall_tile_bottom_right)
			
			check_wall_cell(cell,above_cell,destination,wall_tile_above)
			check_wall_cell(cell,below_cell,destination,wall_tile_below)
			check_wall_cell(cell,left_cell,destination,wall_tile_left)
			check_wall_cell(cell,right_cell,destination,wall_tile_right)

func check_wall_cell(current_cell:Vector2i,check_cell:Vector2i,destination:TileMap,tile:Vector2i):
	if destination.get_cell_source_id(floor_layer,check_cell) != tilemap_ID:
		if destination.get_cell_source_id(floor_layer,current_cell) == tilemap_ID:
			destination.set_cell(wall_layer,check_cell,tilemap_ID,tile)

func place_corner(cell:Vector2i,tilemap:TileMap,cell_tile:Vector2i):
	tilemap.set_cell(wall_layer,cell,tilemap_ID,cell_tile)
