extends Spell

class_name Area_Spell

var has_spell_area = true
var spell_area_type = "Idle_Small"
var can_knockback = true
var max_reach = 10

func _ready() -> void:
	super._ready()
	player.set_area_spell_max_reach(max_reach)
	type = types.AREA

func _process(_delta) -> void:
	var mouse_pos = get_global_mouse_position()
	if player.position.y > mouse_pos.y:
		z_index = -2
	else:
		z_index = 0

func _on_fire() -> void:
	collider.disabled = false
	visible = true
	global_position = get_global_mouse_position()

func _on_animation_finished() -> void:
	visible = false
	collider.disabled = true
	can_knockback = true

func _on_area_2d_body_entered(body) -> void:
	var direction = body.global_position - global_position
	#print("collision: ",body.name)
	if body.name != "TileMap":
		knockback(body,direction)
		body.damage(damage)
		#print(body.health)
