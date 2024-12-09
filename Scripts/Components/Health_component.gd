extends Node2D
class_name Health

@export var MAX_HEALTH : float
var health

func _ready():
	health = MAX_HEALTH

func damage(attack : Attack):
	health -= attack.damage
