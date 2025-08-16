class_name Health extends Node2D

@export var health: float = 100
@export var health_bar: HealthBar = null

signal dead

func damage(damage_value: float):
	health -= damage_value
	if (health_bar):
		health_bar.set_value(health)
	if health <= 0:
		dead.emit()
	pass

func damage_over_time(damage_value: float, time: float):
	pass
