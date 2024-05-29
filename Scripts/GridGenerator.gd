extends TileMap

@export var baseHeight = 0
@export var baseWidth = 0
@export var baseYOffset = 0
@export var baseXOffset = 0

func _ready():
	Generate_Grid(baseHeight,baseWidth,baseXOffset,baseYOffset)

func Generate_Grid(height,width,offsetX,offsetY):
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
	
	
