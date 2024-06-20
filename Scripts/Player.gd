extends CharacterBody2D


@export var speed: float = 75.0
@export var sprint_multiplier: float = 2
@onready var player_sprite = $PlayerCharacter
@onready var spell_area_scene = preload("res://Scenes/spell_area.tscn")
@onready var weapon = $Spellbook
var spell_area = null
var fireball = preload("res://Scenes/Fireball.tscn")
var lightning = preload("res://Scenes/Lightning_strike.tscn")
var is_facing_up = false

signal roll

func _ready():
	InventoryManager.set_player_reference(self)
	SpellInventoryManager.set_player_reference(self)
	spell_area = spell_area_scene.instantiate()
	add_child(spell_area)
	spell_area.visible = false

func _physics_process(delta):
	var mouse_pos = get_global_mouse_position()
	
	spell_area.global_position = mouse_pos
	velocity = Vector2()
	var direction = Vector2.ZERO
	
	if mouse_pos.y > position.y:
		is_facing_up = false
		if mouse_pos.x > position.x:
			player_sprite.flip_h = false
		else: 
			player_sprite.flip_h = true
	else:
		is_facing_up = true
		if mouse_pos.x > position.x:
			player_sprite.flip_h = true
		else: 
			player_sprite.flip_h = false
	
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
		if is_facing_up:
			player_sprite.play("Up_Walk")
		else:
			player_sprite.play("Down_Walk")
	if Input.is_action_pressed("move_down"):
		direction.y += 1
		if is_facing_up:
			player_sprite.play("Up_Walk")
		else:
			player_sprite.play("Down_Walk")
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
		if is_facing_up:
			player_sprite.play("Up_Walk")
		else:
			player_sprite.play("Down_Walk")
	if Input.is_action_pressed("move_right"):
		direction.x += 1
		if is_facing_up:
			player_sprite.play("Up_Walk")
		else:
			player_sprite.play("Down_Walk")

	if is_facing_up and direction == Vector2.ZERO:
		player_sprite.play("Up_Idle")
	elif !is_facing_up and direction == Vector2.ZERO:
		player_sprite.play("Down_Idle")
	
	var sprint_multiplier_temp = 1
	if Input.is_action_pressed("sprint"):
		sprint_multiplier_temp = sprint_multiplier
	
	if Input.is_action_just_pressed("roll"):
		roll.emit()
	
	velocity = direction*speed*sprint_multiplier_temp
	move_and_slide()

func _on_spellbook_toggle_spell_area(_visible):
	var spell_area_animation = "32x32"
	spell_area.visible = _visible
	
	if spell_area.visible:
		spell_area.play(spell_area_animation)

