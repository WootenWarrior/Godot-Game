extends Node2D

@export var health: float = 100
@export var health_bar: Node2D = null

func damage(damage_value: float):
	health -= damage_value
	if (health_bar):
		health_bar.set_value(health)
	pass
