extends Spell

class_name Projectile_Spell

var direction = Vector2.ZERO
var speed = 0 : set = set_speed
var max_speed = 100
var has_spell_area = false
var moving = false

func _ready() -> void:
	super._ready()
	type = types.PROJECTILE

func _process(delta) -> void:
	position += direction * speed * delta

func set_speed(_speed) -> void:
	speed = _speed

func set_direction(_direction) -> void:
	direction = _direction

func calculate_direction() -> Vector2:
	var direction = get_global_mouse_position()-global_position
	direction = direction.normalized()
	return direction

func _on_fire():
	collider.disabled = false
	set_direction(calculate_direction())
	moving = true
