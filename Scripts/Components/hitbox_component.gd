class_name Hitbox extends Area2D

@export var attack_component: Attack = null

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.has_method("damage") and attack_component):
		body.damage(attack_component.attack_damage)
	pass # Replace with function body.
