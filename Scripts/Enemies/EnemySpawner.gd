extends Node2D

@onready var timer = $Timer
@onready var spawn_area = $Area2D
@export var enemy_node : PackedScene = null
@export var spawn_timer_seconds = 0

func _ready() -> void:
	timer.wait_time = spawn_timer_seconds
	timer.start()

func _on_timer_timeout() -> void:
	if enemy_node and is_spawn_area_empty():
		var enemy = enemy_node.instantiate()
		add_child(enemy)

func is_spawn_area_empty() -> bool:
	return spawn_area.get_overlapping_bodies().is_empty()
