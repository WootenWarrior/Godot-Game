extends TileMap

@export var base_height = 0
@export var base_width = 0
@export var base_y_offset = 0
@export var base_x_offset = 0

func _ready():
	generate_grid(base_height,base_width,base_y_offset,base_x_offset)

func generate_grid(height,width,x_offset,y_offset):
	var grid = []
	var prevCellId = 0
	for i in range(height):
		var row = []
		for j in range(width):
			row.append(j)
			set_cell(0,Vector2(i,j),prevCellId,Vector2(0,prevCellId))
			if prevCellId == 1:
				prevCellId = 0
			else:
				prevCellId = 1
		grid.append(row)
	
	
