extends Area2D
class_name Hitbox

@export var Health_component : Health

func damage(attack : Attack):
	if Health_component:
		Health_component.damage(attack)
