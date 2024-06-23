extends Node

class_name Enemy

@onready var Collision_shape = null
@onready var Enemy_reference = null
var damage = 1
var health = 1

func _ready():
	pass

func _process(delta):
	pass

func set_collision_shape(collision_shape: CollisionShape2D):
	Collision_shape = collision_shape

func set_enemy_reference(enemy_reference:Node2D):
	Enemy_reference = enemy_reference
