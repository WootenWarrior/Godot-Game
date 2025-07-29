extends TileMap

@export var dungeon_size : Vector2
@export var num_of_rooms : int
@export var spawn_pos : Vector2
@export var partition_ratio : float
var room_positions : Array
var min_room_size : Vector2i
var partitions : Array
var test_tiles = [Vector2(1,1),Vector2(3,0),Vector2(4,4),Vector2(0,2),Vector2(5,5)]

class BSP_node:
	var x : int
	var y: int
	var width : int
	var height : int
	var left = null
	var right = null
	var room = null
	var min_partition_size : Vector2i
	
	func _init(_x,_y,_width,_height,_min_partition_size):
		x = _x
		y = _y
		width = _width
		height = _height
		min_partition_size = _min_partition_size
	
	func split():
		var horizontal = randf_range(0,1) > 0.5
		print("split horizontal = ", horizontal)
		var new_width = randi_range(0,width)
		var new_height = randi_range(0,height)
		
		if new_height < min_partition_size.y:
			new_height = min_partition_size.y
		if new_width < min_partition_size.x:
			new_width = min_partition_size.x
		
		if not horizontal:
			left = BSP_node.new(x,y,new_width,height,min_partition_size)
			right = BSP_node.new(x+new_width,y,width-new_width,height,min_partition_size)
		else:
			left = BSP_node.new(x,y,width,new_height,min_partition_size)
			right = BSP_node.new(x,y+new_height,width,height-new_height,min_partition_size)

func _ready():
	var root = get_tree().root
	spawn_pos = Vector2(0,0)
	var smallest_room = WorldManager.get_smallest_room()
	min_room_size = smallest_room.size
	print(min_room_size)
	var max_room_number = min(dungeon_size.x/min_room_size.x,dungeon_size.y/min_room_size.y)
	if num_of_rooms > max_room_number:
		num_of_rooms = max_room_number
	if root:
		WorldManager.instantiate_players(1)
		WorldManager.spawn_players_in_scene(root,spawn_pos)
		room_positions = generate_room_positions()

func generate_room_positions() -> Array:
	var positions = []
	partitions = create_partitions()
	draw_partitions()
	for partition in partitions:
		var pos = Vector2(partition.x+partition.width/2,partition.y+partition.height/2)
		positions.append(pos)
	return positions

func create_partitions() -> Array:
	if partition_ratio >= 0.5:
		partition_ratio = 0.5
	var min_partition_size = min_room_size
	var root = BSP_node.new(0,0,dungeon_size.x,dungeon_size.y,min_partition_size)
	var nodes = [root]
	
	for i in range(num_of_rooms):
		var node = nodes.pop_back()
		node.split()
		nodes.append(node.left)
		nodes.append(node.right)
	
	for node in nodes:
		print("located: ",Vector2(node.x,node.y), " size: ", Vector2(node.width,node.height))
	
	return nodes

func draw_partitions():
	var iteration = 0
	var atlas_coords = Vector2(1,1)
	for node in partitions:
		for x in node.width:
			for y in node.height:
				var x_coord = x + node.x
				var x_end = node.x + node.width
				var y_coord = y + node.y
				var y_end = node.y + node.height
				set_cell(0,Vector2(x+node.x,y+node.y),1,test_tiles[iteration])
		iteration += 1
		if iteration >= len(test_tiles):
			break
