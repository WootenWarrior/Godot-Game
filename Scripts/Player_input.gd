extends CharacterBody2D

@export var move_speed: float = 75.0
@export var charge_speed: float = 35.0
@export var sprint_multiplier: float = 2
@export var sprint_bar_decrease_multiplier = 0.8
@export var sprint_bar_increase_multiplier = 0.5
@export var health = 100
@export var sprint = 100
@export var external_force_decay = 0.9   #Bounce damping factor on player (will affect all force sources)
@export var roll_force = 400
@export var dev_active = true

@onready var spell_area_scene = preload("res://Scenes/UI/SpellArea.tscn")
@onready var weapon = null

@onready var player_sprite = $AnimatedSprite2D
@onready var hit_timer = $InvulnerabilityTimer
@onready var health_bar = $CanvasLayer/HealthAndSprint/HealthBar
@onready var sprint_bar = $CanvasLayer/HealthAndSprint/SprintBar
@onready var camera = $Camera2D

var speed: float
var charging = false
var can_be_hit = true
var spell_area = null
var is_facing_up = false
var external_forces = Vector2.ZERO
var is_dead = false
var speed_temp = 0
var speed_reduction_multiplier = 0.5

signal roll(direction)
signal hit(damage:int)

func _ready() -> void:
	speed = move_speed
	
	InventoryManager.set_player_reference(self)
	SpellInventoryManager.set_player_reference(self)
	
	spell_area = spell_area_scene.instantiate()
	
	add_child(spell_area)
	spell_area.visible = false
	
	health_bar.init_health(health)
	sprint_bar.init_sprint(sprint)
	
	#Debug
	if dev_active:
		$CanvasLayer.add_child(load("res://Scenes/UI/dev_menu.tscn").instantiate())
	set_weapon(load("res://Scenes/Weapons/DevSpellbook.tscn"))
	
	print("player position start = ",global_position)
	
	Signals.connect("player_dead", Callable(self, "_on_player_dead"))

func _physics_process(_delta) -> void:
	if not is_dead:
		if Input.is_action_just_pressed("fire"):
			Signals.player_attack.emit()
		
		var mouse_pos = get_global_mouse_position()
		var raw_direction = handle_movement_input()
		var direction = raw_direction.normalized()
		var _sprint_multiplier = handle_sprint_input()
		
		spell_area.global_position = mouse_pos
		velocity = Vector2.ZERO
		
		handle_player_sprite_direction(mouse_pos)
		handle_charge_input()
		handle_roll_input(direction)
		
		velocity = ((direction*speed) + external_forces) * _sprint_multiplier
		move_and_slide()
		external_forces = external_forces*external_force_decay
		
		if health <= 0:
			Signals.player_dead.emit()

func damage(damage_value:float) -> void:
	health-=damage_value
	health_bar.health = health

func apply_force(force_direction: Vector2, force_strength: float) -> void:
	external_forces = force_direction.normalized() * force_strength
	#print("force applied: ", external_forces)

func set_weapon(new_weapon:Resource) -> void:
	weapon = new_weapon.instantiate()
	add_child(weapon)
	Signals.connect("toggle_spell_area", Callable(self, "_on_toggle_spell_area"))

func set_weapon_spell(spell) -> void:
	weapon.set_spell(spell)

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
		speed = charge_speed
	elif Input.is_action_just_released("charge") and weapon.visible:
		speed = move_speed

func handle_roll_input(direction:Vector2) -> void:
	if Input.is_action_just_pressed("roll"):
		roll.emit(direction)

func handle_movement_input() -> Vector2:
	var raw_direction = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		raw_direction.y -= 1
	if Input.is_action_pressed("move_down"):
		raw_direction.y += 1
	if Input.is_action_pressed("move_left"):
		raw_direction.x -= 1
	if Input.is_action_pressed("move_right"):
		raw_direction.x += 1
	
	if raw_direction == Vector2.ZERO:
		if is_facing_up:
			player_sprite.play("idle_up")
		elif !is_facing_up:
			player_sprite.play("idle_down")
	else:
		if is_facing_up:
			player_sprite.play("walk_up")
		else:
			player_sprite.play("walk_down")
	
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
	return global_position.distance_to(weapon.global_position)

func _on_toggle_spell_area() -> void:
	var prev_visibility = spell_area.visible
	var spell_area_animation = "Idle_Small"
	spell_area.visible = !prev_visibility
	
	if spell_area.visible:
		spell_area.play(spell_area_animation)

func _on_hit(damage_value:float) -> void:
	if not is_dead:
		if can_be_hit:
			damage(damage_value)
			can_be_hit = false
			hit_timer.start()
			print(health)

func _on_timer_timeout() -> void:
	can_be_hit = true

func _on_player_dead() -> void:
	print("player died")
	player_sprite.play("Die")
	is_dead = true
	spell_area.visible = false
	weapon.visible = false

func _on_roll(direction) -> void:
	apply_force(direction,roll_force)
