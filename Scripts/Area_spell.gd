extends Spell

class_name Area_Spell

var has_spell_area = true
var spell_area_type = "Idle_Small"
var can_knockback = true

func _process(_delta):
	var player = get_parent().get_child(0)
	var mouse_pos = get_global_mouse_position()
	if player.position.y > mouse_pos.y:
		z_index = -2
	else:
		z_index = 0

func knockback(body):
	var direction = body.global_position - global_position
	body.apply_force(direction,knockback_strength)

func connect_to_area_signal():
	area.connect("body_entered", Callable(self, "_on_area_2d_body_entered"))

func _on_fire():
	collider.disabled = false
	visible = true
	global_position = get_global_mouse_position()

func _on_animation_finished():
	visible = false
	collider.disabled = true
	can_knockback = true

func _on_area_2d_body_entered(body):
	#print("collision: ",body.name)
	if body.name != "TileMap":
		knockback(body)
		body.damage(damage)
		#print(body.health)
