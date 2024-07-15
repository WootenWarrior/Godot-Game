extends Node

var player = null : set = set_player , get = get_player

func set_player(_player) -> void:
	player = _player

func get_player() -> Node2D:
	return player
