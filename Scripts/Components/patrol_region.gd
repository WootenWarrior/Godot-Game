class_name PatrolRegion extends Marker2D

@export var pathfinder: PathfindComponent
@export var max_distance = 15
@export var min_distance = 5
@export var wait_time = 2: 
		set(new_time):
			wait_time = new_time
			$Timer.wait_time = new_time
var pos = Vector2.ZERO: 
	set(new_pos):
		pos = new_pos
		global_position = pos

func _ready() -> void:
	global_position = pos
	$Timer.wait_time = wait_time
	$Timer.autostart = true
	$Timer.start()
