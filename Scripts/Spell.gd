extends AnimatedSprite2D

class_name Spell

var damage = 1
var charge_time = 1
var collider = null
var area = null

signal idle
signal fire
signal despawn

func set_collider(_collider) -> void:
	collider = _collider

func set_area(_area) -> void:
	area = _area
