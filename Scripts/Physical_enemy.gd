extends Enemy

class_name Physical_enemy

var target = null
 

func _ready():
	super._ready()

func _process(delta):
	super._process(delta)

func apply_force(body) -> void:
	var force_direction = (body.global_position - global_position).normalized()
	var force_strength = 1000  # Adjust as needed
	body.add_force(force_direction * force_strength)
