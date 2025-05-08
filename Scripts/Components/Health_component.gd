extends Node2D
class_name Health

@export var MAX_HEALTH : float
@export var Health_bar : HealthBar
var health : float

func _ready():
	health = MAX_HEALTH

func damage(attack : Attack):
	health -= attack.damage
