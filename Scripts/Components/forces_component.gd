class_name ForcesComponent extends Node2D

@export var body: CharacterBody2D = null
@export var external_force_decay = 0.9

var external_forces = Vector2.ZERO

func _physics_process(delta: float) -> void:
	external_forces = external_forces * external_force_decay

func apply_force(force_direction: Vector2, force_strength: float):
	external_forces += force_direction.normalized() * force_strength
