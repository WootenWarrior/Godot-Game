extends CharacterBody2D

class_name Enemy

@export var aggro_radius = 0
@onready var Collision_shape = null
@onready var AnimatedSprite = null
var health_bar = null
var player = null
var players = null
var attack_damage = 1
var health = 1
var speed = 1
var external_forces = Vector2.ZERO
var damping_factor = 0.9
var dead = false

func _ready() -> void:
	players = get_tree().get_nodes_in_group("Player")
	player = players[0]

func _process(_delta) -> void:
	pass

func apply_force(force_direction: Vector2, force_strength: float) -> void:
	external_forces = force_direction.normalized() * force_strength

func set_health_bar(_health_bar) -> void:
	health_bar = _health_bar

func set_collision_shape(collision_shape: CollisionShape2D) -> void:
	Collision_shape = collision_shape

func set_animated_sprite_2d(animated_sprite:AnimatedSprite2D) -> void:
	AnimatedSprite = animated_sprite
	AnimatedSprite.connect("animation_finished",Callable(self,"_on_animation_finished"))

func set_aggro_radius(radius: float, collision_shape: CollisionShape2D) -> void:
	if radius < 0:
		radius = 0-radius
	var aggro_circle = collision_shape.shape
	aggro_circle.radius = radius

func damage(damage_value) -> void:
	health-=damage_value
	health_bar.health = health

func die() -> void:
	AnimatedSprite.play("Die")
	dead = true

func _on_animation_finished() -> void:
	if AnimatedSprite.get_animation() == "Die":
		queue_free()
