extends Spell

class_name Projectile_Spell

var direction = Vector2()
var speed = 0 : set = set_speed
var max_speed = 100
var has_spell_area = false
var moving = false

func _ready() -> void:
	super._ready()
	type = types.PROJECTILE

func _process(delta) -> void:
	if moving:
		position += direction * speed * delta

func set_speed(_speed) -> void:
	speed = _speed

func _on_fire():
	set_speed(max_speed)
