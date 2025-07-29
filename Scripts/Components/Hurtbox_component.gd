extends Area2D

@export var health_component: Node2D = null

func _on_body_entered(body: Node2D) -> void:
	if (body.damage and health_component):
		health_component.damage(body.damage)
	pass
