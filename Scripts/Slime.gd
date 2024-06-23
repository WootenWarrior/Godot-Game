extends Physical_enemy

func _ready():
	super._ready()
	health = 20
	damage = 5
	set_collision_shape($RigidBody2D/Damage_collider)
	set_enemy_reference($".")

func _on_rigid_body_2d_body_entered(body):
	print("hit")
	if body.is_in_group("Player"):
		print("hit player")
		body.hit.emit(damage)

