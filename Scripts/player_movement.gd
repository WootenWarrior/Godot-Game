extends CharacterBody2D

@export var move_speed: float = 75.0
@export var charge_speed: float = 35.0
@export var sprint_multiplier: float = 2
@export var sprint_bar_decrease_multiplier = 0.8
@export var sprint_bar_increase_multiplier = 0.5
@export var sprint = 100
@export var external_force_decay = 0.9   #Bounce damping factor on player (will affect all force sources)
@export var roll_force = 400

@onready var player_sprite = $AnimatedSprite2D
@onready var sprint_bar = $UI/SprintBar
@onready var camera = $Camera2D

var speed: float
var can_be_hit = true
var is_facing_up = false
var external_forces = Vector2.ZERO
var is_dead = false
var speed_temp = 0
var speed_reduction_multiplier = 0.5

signal roll(direction)
signal hit(damage:int)
signal attack

func _ready() -> void:
	speed = move_speed
	
	print("player position start = ",global_position)

func _physics_process(_delta) -> void:
	if not is_dead:
		if Input.is_action_just_pressed("fire"):
			attack.emit()
		
		var mouse_pos = get_global_mouse_position()
		var raw_direction = handle_movement_input()
		var direction = raw_direction.normalized()
		var _sprint_multiplier = handle_sprint_input()
		
		velocity = Vector2.ZERO
		
		handle_player_sprite_direction(mouse_pos)
		handle_charge_input()
		handle_roll_input(direction)
		
		velocity = ((direction*speed) + external_forces) * _sprint_multiplier
		move_and_slide()
		external_forces = external_forces*external_force_decay

func handle_movement_input() -> Vector2:
	var raw_direction = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		Signals.change_player_state.emit(Enums.States.WALK)
		raw_direction.y -= 1
	if Input.is_action_pressed("move_down"):
		Signals.change_player_state.emit(Enums.States.WALK)
		raw_direction.y += 1
	if Input.is_action_pressed("move_left"):
		Signals.change_player_state.emit(Enums.States.WALK)
		raw_direction.x -= 1
	if Input.is_action_pressed("move_right"):
		Signals.change_player_state.emit(Enums.States.WALK)
		raw_direction.x += 1
	
	if raw_direction == Vector2.ZERO:
		if is_facing_up:
			player_sprite.play("idle_up")
			Signals.change_player_state.emit(Enums.States.IDLE)
		elif !is_facing_up:
			player_sprite.play("idle_down")
			Signals.change_player_state.emit(Enums.States.IDLE)
	else:
		if is_facing_up:
			player_sprite.play("walk_up")
			Signals.change_player_state.emit(Enums.States.IDLE)
		else:
			player_sprite.play("walk_down")
			Signals.change_player_state.emit(Enums.States.IDLE)
	
	return raw_direction

func handle_sprint_input() -> float:
	var sprint_multiplier_temp = 1
	if Input.is_action_pressed("sprint"):
		Signals.change_player_state.emit(Enums.States.SPRINT)
		if sprint_bar.value > 0:
			sprint_multiplier_temp = sprint_multiplier
		sprint_bar.set_sprint(sprint_bar.value-sprint_bar_decrease_multiplier)
	else:
		sprint_bar.set_sprint(sprint_bar.value+sprint_bar_increase_multiplier)
	return sprint_multiplier_temp

func handle_player_sprite_direction(_mouse_pos) -> void:
	var mouse_pos = _mouse_pos
	if mouse_pos.y > global_position.y:
		is_facing_up = true
		if mouse_pos.x > global_position.x:
			player_sprite.flip_h = true
		else: 
			player_sprite.flip_h = false
	else:
		is_facing_up = false
		if mouse_pos.x > global_position.x:
			player_sprite.flip_h = true
		else:
			player_sprite.flip_h = false

func handle_charge_input() -> void:
	if Input.is_action_pressed("charge"):
		speed = charge_speed
	elif Input.is_action_just_released("charge"):
		speed = move_speed

func handle_roll_input(direction:Vector2) -> void:
	if Input.is_action_just_pressed("roll"):
		roll.emit(direction)
