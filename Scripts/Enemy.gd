extends CharacterBody2D

class_name Enemy

@export var aggro_radius = 0
@onready var Collision_shape = null
@onready var AnimatedSprite = null
var player = null
var players = null
var attack_damage = 1
var health = 1
var speed = 1
var external_forces = Vector2.ZERO
var damping_factor = 0.9
var dead = false

func _ready():
	players = get_tree().get_nodes_in_group("Player")
	player = players[0]

func _process(_delta):
	pass

func set_collision_shape(collision_shape: CollisionShape2D):
	Collision_shape = collision_shape

func set_animated_sprite_2d(animated_sprite:AnimatedSprite2D):
	AnimatedSprite = animated_sprite
	AnimatedSprite.connect("animation_finished",Callable(self,"_on_animation_finished"))

func set_aggro_radius(radius: float, collision_shape: CollisionShape2D):
	if radius < 0:
		radius = 0-radius
	var aggro_circle = collision_shape.shape
	aggro_circle.radius = radius

func damage(damage_value) -> void:
	health-=damage_value

func die() -> void:
	AnimatedSprite.play("Die")
	dead = true

func _on_animation_finished():
	if AnimatedSprite.get_animation() == "Die":
		queue_free()
	pass
