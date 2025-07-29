extends Node2D

@export var state = Enums.States.IDLE

@export var dev_active = true

func _ready() -> void:
	Signals.connect("change_player_state", Callable(self, "on_change_player_state"))

func on_change_player_state(new_state: Enums.States) -> void:
	state = new_state
