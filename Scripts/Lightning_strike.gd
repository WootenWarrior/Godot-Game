extends Area_Spell

func _ready():
	set_area($Area2D)
	set_collider($Area2D/Collider)
	connect_to_area_signal()
	collider.disabled = true
	damage = 10

func _on_fire():
	super._on_fire()
	play("Strike")


