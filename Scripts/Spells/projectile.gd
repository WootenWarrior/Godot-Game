class_name Projectile extends CharacterBody2D

@export var hitbox: Hitbox = null
@export var animation_source: AnimationPlayer = null
@export var particles: CPUParticles2D = null
@export var particle_gravity_scale = 0
@export var move_speed = 0
@export var max_bounces = 0
@export var can_bounce = false
@export var primary_color: Color
@export var secondary_color: Color

@onready var explosion = preload("res://Scenes/Effects and Shaders/explosion.tscn")

var target: Vector2i: 
		set(new_target):
			target = new_target
			global_position = spawn_pos
			direction = global_position.direction_to(target)
var direction: Vector2
var spawn_pos: Vector2i

func _ready() -> void:
	if hitbox:
		hitbox.connect("body_entered", _on_collision)
	pass

func _physics_process(delta: float) -> void:
	if target:
		if particles:
			particles.gravity = direction * particle_gravity_scale
		velocity = direction * move_speed
		move_and_slide()
	pass

func _on_collision(body):
	if can_bounce and max_bounces > 0:
		max_bounces -= 1
		calculate_new_direction()
	else:
		var explosion_node = explosion.instantiate()
		explosion_node.global_position = global_position
		EffectManager.add_effect_to_scene(explosion_node)
		queue_free()
	pass

func calculate_new_direction():
	#TODO Raycast?
	pass
