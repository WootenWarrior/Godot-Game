extends Area_Spell

@onready var timer = $ColliderEnabledTime

func _ready() -> void:
	super._ready()
	set_area($Area2D)
	set_collider($Area2D/Collider)
	connect_to_area_signal()
	collider.disabled = true
	damage = 10
	knockback_strength = 200
	max_reach = 100

func _on_fire() -> void:
	super._on_fire()
	timer.start()
	play("Strike")

func _on_animation_finished():
	var animation_name = get_animation()
	if animation_name == "Strike":
		queue_free()

func _on_collider_enabled_time_timeout() -> void:
	collider.disabled = true
