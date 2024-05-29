extends AnimatedSprite2D

@export var radius = 100
@export var spellOffset = 20
@export	var projectileSpeed = 100
@onready var player = get_parent()
var spellIsCast = false
var equipedSpell = preload("res://Scenes/Fireball.tscn")
var castSpell
var canFire = false

func _ready():
	visible = false

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	if Input.is_action_pressed("get_weapon_out"):
		visible = true
	if Input.is_action_pressed("put_weapon_away"):
		visible = false
		
	if player.position.y > mouse_pos.y:
		z_index = -2
		if castSpell and spellIsCast:
			castSpell.z_index = -1
	else:
		z_index = 0
		if castSpell and spellIsCast:
			castSpell.z_index = 0
	
	if player and visible:
		var player_pos = player.global_position
		var direction = mouse_pos - player_pos
		var angle = direction.angle()
		
		var x = player_pos.x + radius * cos(angle)
		var y = player_pos.y + radius * sin(angle)
		
		global_position = Vector2(x, y)
		rotation = angle + PI / 2
		
		if Input.is_action_just_pressed("fire") and visible and !spellIsCast and !castSpell:
			Cast_Spell()
			if castSpell.animation_finished:
				canFire = true
			play("Page_Flip")
			
		if Input.is_action_just_released("fire") and visible and spellIsCast and castSpell:
			if canFire:
				print("fired")
				Fire_Spell()
			else:
				print("reset")
				Reset_Spell()
			
		if castSpell and spellIsCast:
			var x_spell = player_pos.x + (radius + spellOffset) * cos(angle)
			var y_spell = player_pos.y + (radius + spellOffset) * sin(angle)
			castSpell.global_position = Vector2(x_spell, y_spell)
			castSpell.rotation = angle + PI / 2
			castSpell.look_at(get_global_mouse_position())

func Cast_Spell():
	castSpell = equipedSpell.instantiate()
	player.add_child(castSpell)
	castSpell.play("Spawn")
	spellIsCast = true
	await castSpell.animation_finished

func Reset_Spell():
	castSpell.play("Despawn")
	spellIsCast = false
	await castSpell.animation_finished
	castSpell.queue_free()

func Fire_Spell():
	castSpell.Fire()
	
