extends CharacterBody2D

@export var speed: float = 75.0
@export var sprint_multiplier: float = 2
@export var sprint_bar_decrease_multiplier = 0.8
@export var sprint_bar_increase_multiplier = 0.5
@export var health = 100
@export var sprint = 100
@export var external_force_decay = 0.9   #Bounce damping factor on player (will affect all force sources)
@export var roll_force = 400
@onready var player_sprite = $PlayerCharacter
@onready var spell_area_scene = preload("res://Scenes/Spells/SpellArea.tscn")
@onready var weapon = null
@onready var hit_timer = $InvulnerabilityTimer
@onready var health_bar = $CanvasLayer/PlayerUI/HealthBar
@onready var sprint_bar = $CanvasLayer/PlayerUI/SprintBar
@onready var spell_reach_radius = $SpellReachRadius/CollisionShape2D
var can_be_hit = true
var spell_area = null
var is_facing_up = false
var external_forces = Vector2.ZERO
var is_dead = false
var speed_temp = 0
var speed_reduction_multiplier = 0.5
var area_spell_max_reach = 10

signal roll(direction)
signal hit(damage:int)
signal dead

func _ready() -> void:
	WorldManager.set_player(self)
	InventoryManager.set_player_reference(self)
	SpellInventoryManager.set_player_reference(self)
	spell_area = spell_area_scene.instantiate()
	add_child(spell_area)
	spell_area.visible = false
	add_to_group("Player")
	health_bar.init_health(health)
	sprint_bar.init_sprint(sprint)
	speed_temp = speed
	
	#Debug
	set_weapon(load("res://Scenes/Weapons/DevSpellbook.tscn"))
	weapon.set_spell(load("res://Scenes/Spells/Fireball.tscn"))

func _physics_process(_delta) -> void:
	if not is_dead:
		var mouse_pos = get_global_mouse_position()
		var raw_direction = handle_movement_input()
		var direction = raw_direction.normalized()
		var sprint_multiplier = handle_sprint_input()
		
		spell_area.global_position = mouse_pos
		velocity = Vector2.ZERO
		
		handle_player_sprite_direction(mouse_pos)
		check_if_idle(raw_direction)
		handle_charge_input()
		handle_roll_input(direction)
		
		velocity = ((direction*speed) + external_forces) * sprint_multiplier
		move_and_slide()
		external_forces = external_forces*external_force_decay

func damage(damage_value:float) -> void:
	health-=damage_value
	health_bar.health = health

func apply_force(force_direction: Vector2, force_strength: float) -> void:
	external_forces = force_direction.normalized() * force_strength
	#print("force applied: ", external_forces)

func set_weapon(new_weapon:Resource) -> void:
	weapon = new_weapon.instantiate()
	add_child(weapon)
	weapon.connect("toggle_spell_area", Callable(self, "_on_toggle_spell_area"))

func set_area_spell_max_reach(radius:float) -> void:
	spell_reach_radius.shape.radius = radius

func handle_sprint_input() -> float:
	var sprint_multiplier_temp = 1
	if Input.is_action_pressed("sprint"):
		if sprint_bar.value > 0:
			sprint_multiplier_temp = sprint_multiplier
		sprint_bar.set_sprint(sprint_bar.value-sprint_bar_decrease_multiplier)
	else:
		sprint_bar.set_sprint(sprint_bar.value+sprint_bar_increase_multiplier)
	return sprint_multiplier_temp

func handle_charge_input() -> void:
	if Input.is_action_pressed("charge") and weapon.visible:
		speed = speed_temp*speed_reduction_multiplier
	if Input.is_action_just_released("charge"):
		speed = speed_temp

func handle_roll_input(direction:Vector2) -> void:
	if Input.is_action_just_pressed("roll"):
		roll.emit(direction)

func check_if_idle(direction:Vector2) -> bool:
	if direction == Vector2.ZERO:
		if is_facing_up:
			player_sprite.play("Up_Idle")
		elif !is_facing_up:
			player_sprite.play("Down_Idle")
	return direction == Vector2.ZERO

func handle_movement_input() -> Vector2:
	var raw_direction = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		raw_direction.y -= 1
		if is_facing_up:
			player_sprite.play("Up_Walk")
		else:
			player_sprite.play("Down_Walk")
	if Input.is_action_pressed("move_down"):
		raw_direction.y += 1
		if is_facing_up:
			player_sprite.play("Up_Walk")
		else:
			player_sprite.play("Down_Walk")
	if Input.is_action_pressed("move_left"):
		raw_direction.x -= 1
		if is_facing_up:
			player_sprite.play("Up_Walk")
		else:
			player_sprite.play("Down_Walk")
	if Input.is_action_pressed("move_right"):
		raw_direction.x += 1
		if is_facing_up:
			player_sprite.play("Up_Walk")
		else:
			player_sprite.play("Down_Walk")
	
	return raw_direction

func handle_player_sprite_direction(_mouse_pos) -> void:
	var mouse_pos = _mouse_pos
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

func get_weapon_radius() -> float:
	return weapon.radius

func _on_toggle_spell_area(_visible:bool) -> void:
	var spell_area_animation = "Idle_Small"
	spell_area.visible = _visible
	
	if spell_area.visible:
		spell_area.play(spell_area_animation)

func _on_hit(damage_value:float) -> void:
	if not is_dead:
		if can_be_hit:
			damage(damage_value)
			can_be_hit = false
			hit_timer.start()
			print(health)
		
		if health <= 0:
			dead.emit()

func _on_timer_timeout() -> void:
	can_be_hit = true

func _on_dead() -> void:
	print("player died")
	player_sprite.play("Die")
	is_dead = true
	spell_area.visible = false
	weapon.visible = false

func _on_roll(direction) -> void:
	apply_force(direction,roll_force)
