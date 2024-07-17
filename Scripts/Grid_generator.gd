extends TileMap

@export var base_height = 0
@export var base_width = 0
@export var base_y_offset = 0
@export var base_x_offset = 0
@export var tilemap_scale = Vector2(2,2)
var Grid = []
var empty_cell = Vector2i(-1,-1)
var background_tile = Vector2(1,1)
var wall_tile = Vector2(0,2)
var source_atlas_number = 0

func _ready():
	scale = tilemap_scale
	Grid = generate_grid(base_height,base_width,base_y_offset,base_x_offset)
	draw_walls()

func generate_grid(height,width,x_offset,y_offset) -> Array:
	var grid = []
	for i in range(height + y_offset):
		var row = []
		i += y_offset
		for j in range(width):
			j += x_offset
			row.append(j)
			set_cell(0,Vector2(i,j),source_atlas_number,background_tile)
		grid.append(row)
	return grid

func draw_walls():
	for x in len(Grid):
		x += base_x_offset
		for y in len(Grid[x]):
			y += base_y_offset
			var above_neighbour = Vector2(x,y-1)
			if get_cell_atlas_coords(0,above_neighbour) == empty_cell:
				set_cell(1,above_neighbour,source_atlas_number,wall_tile)
