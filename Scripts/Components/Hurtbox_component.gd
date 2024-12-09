extends Area2D
class_name Hurtbox

@export var attack : Attack

func set_inactive():
	monitorable = false
	monitoring = false

func set_active():
	monitorable = true
	monitoring = true

func _on_body_entered(body):
	if body is Hitbox:
		body.damage(attack)
