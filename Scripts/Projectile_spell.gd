extends AnimatedSprite2D

class_name Projectile_Spell

var direction = Vector2()
var speed = 0
var damage = 10
var max_speed = 100
var has_spell_area = false

func _process(delta):
	if speed > 0:
		position += direction * speed * delta
