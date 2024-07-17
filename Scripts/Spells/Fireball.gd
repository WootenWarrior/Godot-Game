extends Projectile_Spell

func _ready() -> void:
	super._ready()
	set_animated_sprite($".")
	set_area($Area2D)
	set_collider($Area2D/CollisionShape2D)
	connect_to_area_signal()
	set_speed(100)
	collider.disabled = true
	damage = 10
	knockback_strength = 20

func _on_fire() -> void:
	super._on_fire()
	play("Fire")
	pass

func _on_animation_finished() -> void:
	var animation_name = get_animation()
	if animation_name == "Spawn":
		play("Idle")
	elif animation_name == "Hit":
		queue_free()
	elif animation_name == "Fire":
		play("Move")

func _on_idle() -> void:
	visible = true
	play("Spawn")
