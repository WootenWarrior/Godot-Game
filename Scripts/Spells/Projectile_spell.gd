extends Spell

class_name Projectile_Spell

var direction = Vector2.ZERO
var speed = 0 : set = set_speed
var max_speed = 100
var has_spell_area = false
var moving = false
var charging_radius = 20
var focus_point = Vector2.ZERO
var sprite = null

func _ready() -> void:
	super._ready()
	type = types.PROJECTILE

func _process(delta) -> void:
	if not moving:
		set_charging_position()
		look_at(focus_point)
		#print(focus_point)
	else:
		position += direction * speed * delta
		#print(direction)
		#print(speed)

func set_speed(_speed) -> void:
	speed = _speed

func set_direction(_direction) -> void:
	direction = _direction

func calculate_direction(_focus_point:Vector2) -> Vector2:
	var _direction = _focus_point - global_position
	_direction = _direction.normalized()
	return _direction

func set_charging_position() -> void:
	var player_pos = player.global_position
	var mouse_pos = get_global_mouse_position()
	var _direction = mouse_pos - player_pos
	var angle = _direction.angle()
	var radius = player.get_weapon_radius()
	var x_spell = player_pos.x + (radius + charging_radius) * cos(angle)
	var y_spell = player_pos.y + (radius + charging_radius) * sin(angle)
	focus_point.x = player_pos.x + (radius + charging_radius + 1) * cos(angle)
	focus_point.y = player_pos.y + (radius + charging_radius + 1) * sin(angle)
	global_position = Vector2(x_spell, y_spell)
	rotation = angle + PI / 2
	#print("focus_point: ",focus_point)
	#print("global_pos: ", global_position)

func _on_fire() -> void:
	print("fired")
	collider.disabled = false
	set_direction(calculate_direction(focus_point))
	moving = true

func _on_area_2d_body_entered(body):
	if body.name != "TileMap":
		knockback(body,direction)
		body.damage(damage)
	play("Hit")
	set_speed(0)
