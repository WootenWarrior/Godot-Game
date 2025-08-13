class_name Spell extends Node2D

var active_spell: Node2D = null
@export var charge_bar: ChargeBar = null
var charge_time = 0

func _process(delta: float) -> void:
	if Input.is_action_pressed("charge"):
		charge_time += delta
		Signals.change_player_state.emit(Enums.States.CHARGING)
		charge_bar.start_charging(0.5)
	
	if Input.is_action_just_released("charge"):
		charge_time = 0
		Signals.change_player_state.emit(Enums.States.IDLE)
		charge_bar.charging = false
	
	pass

func cast(target: Vector2):
	if (active_spell):
		active_spell.target = target
		active_spell.look_at(target)
		
	
	pass
