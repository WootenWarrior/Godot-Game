extends Projectile_Spell

func _ready() -> void:
	super._ready()
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

func _on_idle():
	visible = true
	play("Spawn")
	pass

func _on_area_2d_body_entered(body):
	if body.name != "TileMap":
		knockback(body,direction)
		body.damage(damage)
	play("Hit")
	set_speed(0)
