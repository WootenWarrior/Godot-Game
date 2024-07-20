extends Node

class_name Interactable

@export var interact_radius = 1
var collision_shape = null

func _ready():
	collision_shape.radius = interact_radius

func set_interact_collision_shape(_collision_shape):
	collision_shape = _collision_shape
