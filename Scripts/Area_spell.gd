extends Spell

class_name Area_Spell

@onready var collider = $Area2D/Collider
var has_spell_area = true
var spell_area_type = "32x32"

func _process(delta):
	var player = get_parent().get_child(0)
	var mouse_pos = get_global_mouse_position()
	if player.position.y > mouse_pos.y:
		z_index = -2
	else:
		z_index = 0

func _on_fire():
	collider.disabled = false
	visible = true
	global_position = get_global_mouse_position()

func _on_animation_finished():
	visible = false
	collider.disabled = true
