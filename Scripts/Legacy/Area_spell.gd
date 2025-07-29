extends Spell

class_name AreaSpell

@export var AreaSpellConfig : AreaSpellConfig

func _ready() -> void:
	super._ready()
	type = Enums.spell_types.AREA

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

func _on_area_2d_body_entered(body) -> void:
	var direction = body.global_position - global_position
	#print("collision: ",body.name)
	if body.name == "Player":
		knockback(body,direction)
		body.damage(spell_config.damage)
		#print(body.health)

func _on_animated_sprite_2d_animation_finished():
	visible = false
	collider.disabled = true
