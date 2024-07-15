extends Projectile_Spell

func _ready() -> void:
	super._ready()
	set_area($Area2D)
	set_collider($Area2D/CollisionShape2D)
	connect_to_area_signal()
	set_speed(20)
	collider.disabled = true
	damage = 10
	knockback_strength = 20
	max_speed = 100

func _on_fire() -> void:
	super._on_fire()
	play("Fire")
	pass

func _on_animation_finished() -> void:
	if get_animation() == "Spawn":
		play("Idle")

func _on_idle():
	visible = true
	play("Spawn")
	pass
