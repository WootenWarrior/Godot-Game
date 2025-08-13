extends Node2D

@export var health: float = 100
@export var health_bar: HealthBar = null

func damage(damage_value: float):
	health -= damage_value
	if (health_bar):
		health_bar.set_value(health)
	pass

func damage_over_time(damage_value: float, time: float):
	pass
