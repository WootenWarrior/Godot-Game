extends TileMap

@export var max_room_area : Vector2i = Vector2i(200,200)
@export var room_min_size : Vector2i = Vector2i(10,10)
@export var tilemap_scale = Vector2(2,2)
@export var num_of_rooms : int = 10
@export var min_split_offset : int = 2
@export var room_padding : int = 2

var rooms = []
var room_partitions = []
var empty_cell = Vector2i(-1,-1)
var background_tile = Vector2(1,1)
var wall_tile = Vector2(0,2)
var source_atlas_number = 0

class BSP_node:
	var x : int
	var y: int
	var width : int
	var height : int
	var min_split_offset : int
	var left = null
	var right = null
	var room = null
	var room_min_size : Vector2i
	var room_padding : int
	
	func _init(x: int, y: int, width: int, height: int, min_split_offset: int, room_padding : int, room_min_size: Vector2i):
		self.x = x
		self.y = y
		self.width = width
		self.height = height
		self.min_split_offset = min_split_offset
		self.room_min_size = room_min_size
		self.room_padding = room_padding
	
	func split() -> bool:
		var horizontal = randf_range(0,1) <= 0.5
		if horizontal:
			var new_width = randi_range(min_split_offset,width)
			if new_width <= room_min_size.x:
				return false
			left = BSP_node.new(x,y,width - new_width,height,min_split_offset,room_padding,room_min_size)
			right = BSP_node.new(x+width,y,new_width,height,min_split_offset,room_padding,room_min_size)
		else:
			var new_height = randi_range(min_split_offset,height)
			if new_height <= room_min_size.y:
				return false
			left = BSP_node.new(x,y,width,height-new_height,min_split_offset,room_padding,room_min_size)
			right = BSP_node.new(x,y+new_height,width,new_height,min_split_offset,room_padding,room_min_size)
		return true
	
	func create_room() -> Rect2:
		var room_width = randi_range(room_min_size.x, width-room_padding)
		var room_height = randi_range(room_min_size.y, height-room_padding)
		var room_x = randi_range(x, x + width - room_width)
		var room_y = randi_range(y, y + height - room_height)
		room = Rect2(room_x, room_y, room_width, room_height)
		return room

func _ready():
	var root = BSP_node.new(0,0,max_room_area.x,max_room_area.y,min_split_offset,room_padding,room_min_size)
	var nodes = [root]
	
	while len(room_partitions) < num_of_rooms:
		if len(nodes) <= 0:
			break
		
		var node = nodes.pop_back()
		if node.split():
			nodes.append(node.left)
			nodes.append(node.right)
		else:
			room_partitions.append(node)
	
	for region in room_partitions:
		var room_rect = region.create_room()
		make_room(room_rect.position, room_rect.size)

func make_room(position: Vector2, size: Vector2):
	for x in range(size.x):
		for y in range(size.y):
			var coords = Vector2i(position.x + x, position.y + y)
			set_cell(0, coords, source_atlas_number, background_tile)
	rooms.append(Rect2(position, size))
	print("Room: ", Rect2(position, size))
