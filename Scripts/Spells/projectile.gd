class_name Projectile extends Node2D

@export var hitbox: Hitbox = null
@export var animation_source: AnimationPlayer = null
@export var velocity = 0
var target: Vector2

func _ready() -> void:
	if hitbox:
		hitbox.connect("_on_area_2d_body_entered", _on_collision)
	pass

func _physics_process(delta: float) -> void:
	if target:
		pass
	pass

func _on_collision():
	queue_free()
	pass
