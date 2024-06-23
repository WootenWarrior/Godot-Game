extends Enemy

class_name Physical_enemy

@export var aggro_radius = 0
var target = null

func _ready():
	super._ready()

func _process(delta):
	super._process(delta)
	if target and Collision_shape:
		var target_pos = target.global_position
		var direction = target_pos - Collision_shape.global_position
		Enemy_reference.velocity = direction.normalized()
		print(direction.normalized())
