extends CharacterBody2D


@export var speed: float = 75.0
@export var sprint_multiplier: float = 2
@export var health = 100
@export var external_force_decay = 0.9   #Bounce damping factor on player
@onready var player_sprite = $PlayerCharacter
@onready var spell_area_scene = preload("res://Scenes/spell_area.tscn")
@onready var weapon = null
@onready var hit_timer = $InvulnerabilityTimer
var can_be_hit = true
var spell_area = null
var fireball = preload("res://Scenes/Fireball.tscn")
var lightning = preload("res://Scenes/Lightning_strike.tscn")
var is_facing_up = false
var external_forces = Vector2.ZERO
var is_dead = false

signal roll
signal hit(damage:int)
signal dead

func _ready():
	InventoryManager.set_player_reference(self)
	SpellInventoryManager.set_player_reference(self)
	spell_area = spell_area_scene.instantiate()
	add_child(spell_area)
	spell_area.visible = false
	add_to_group("Player")
	
	#Debug
	set_weapon(load("res://Scenes/Dev_spellbook.tscn"))

func _physics_process(_delta):
	if not is_dead:
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
		
		velocity = (direction*speed*sprint_multiplier_temp) + external_forces
		move_and_slide()
		external_forces = external_forces*external_force_decay

func damage(damage_value) -> void:
	health-=damage_value

func apply_force(force_direction: Vector2, force_strength: float):
	external_forces = force_direction.normalized() * force_strength
	#print("force applied: ", external_forces)

func set_weapon(new_weapon:Resource):
	weapon = new_weapon.instantiate()
	add_child(weapon)
	weapon.connect("toggle_spell_area", Callable(self, "_on_toggle_spell_area"))

func _on_toggle_spell_area(_visible:bool):
	var spell_area_animation = "Idle_Small"
	spell_area.visible = _visible
	
	if spell_area.visible:
		spell_area.play(spell_area_animation)

func _on_hit(damage:int):
	if not is_dead:
		if can_be_hit:
			damage(damage)
			can_be_hit = false
			hit_timer.start()
			print(health)
		
		if health <= 0:
			dead.emit()

func _on_timer_timeout():
	can_be_hit = true

func _on_dead():
	print("player died")
	player_sprite.play("Die")
	is_dead = true
	spell_area.visible = false
	weapon.visible = false
