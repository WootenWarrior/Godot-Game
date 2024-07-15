extends Magic_weapon

@export var radius: int = 10
@export var spell_offset: int = 20
var projectile_speed = 0
var spell_idle = false

func _ready() -> void:
	super._ready()
	visible = false
	radius = 10

func _process(delta) -> void:
	super._process(delta)
	
	if equipped_spell:
		print(equipped_spell.types.PROJECTILE)
		print(equipped_spell.type)
		if equipped_spell.type == equipped_spell.types.PROJECTILE:
			set_spell_pos()
	
	set_weapon_pos()
	
	check_z_index()

func set_spell_pos() -> void:
	if visible and equipped_spell:
		var player_pos = player.global_position
		var mouse_pos = get_global_mouse_position()
		var direction = mouse_pos - player_pos
		var angle = direction.angle()
		var x_spell = player_pos.x + (radius + spell_offset) * cos(angle)
		var y_spell = player_pos.y + (radius + spell_offset) * sin(angle)
		equipped_spell.global_position = Vector2(x_spell, y_spell)
		equipped_spell.rotation = angle + PI / 2
		equipped_spell.look_at(get_global_mouse_position())

func set_weapon_pos() -> void:
	if visible:
		var mouse_pos = get_global_mouse_position()
		var player_pos = player.global_position
		var direction = mouse_pos - player_pos
		var angle = direction.angle()

		var x = player_pos.x + radius * cos(angle)
		var y = player_pos.y + radius * sin(angle)

		global_position = Vector2(x, y)
		rotation = angle + PI / 2

func check_z_index() -> void:
	if player.global_position.y > global_position.y:
		z_index = player.z_index - 1
	else:
		z_index = player.z_index

func _on_attack() -> void:
	super._on_attack()
	spell_idle = false
	if equipped_spell and visible:
		if is_charged:
			equipped_spell.fire.emit()
		else:
			equipped_spell.despawn.emit()
	is_charged = false

func instantiate_spell() -> void:
	equipped_spell = equipped_spell_scene.instantiate()
	player.get_parent().add_child.call_deferred(equipped_spell)
	equipped_spell.visible = false
	charge_time = equipped_spell.charge_time

func _on_weapon_hide() -> void:
	super._on_weapon_hide()
	if equipped_spell:
		equipped_spell.queue_free()
	equipped_spell = null
	#print("weapon hidden")

func _on_weapon_out() -> void:
	if equipped_spell_scene:
		instantiate_spell()
	play("Page_Flip")
	#print("weapon drawn")
