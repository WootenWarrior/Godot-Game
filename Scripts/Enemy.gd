extends CharacterBody2D

class_name Enemy

@export var aggro_radius = 0
@onready var Collision_shape = null
@onready var AnimatedSprite = null
var player = null
var players = null
var damage = 1
var health = 1
var speed = 1

func _ready():
	players = get_tree().get_nodes_in_group("Player")
	player = players[0]

func _process(_delta):
	var player_pos = player.global_position
	
	#if player_pos.y > global_position.y:
		#AnimatedSprite.z_index = player.z_index-2
	#else:
		#AnimatedSprite.z_index = player.z_index+2

func set_collision_shape(collision_shape: CollisionShape2D):
	Collision_shape = collision_shape

func set_animated_sprite_2d(animated_sprite:AnimatedSprite2D):
	AnimatedSprite = animated_sprite

func set_aggro_radius(radius: float, collision_shape: CollisionShape2D):
	if radius < 0:
		radius = 0-radius
	var aggro_circle = collision_shape.shape
	aggro_circle.radius = radius
