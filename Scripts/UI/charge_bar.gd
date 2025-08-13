class_name ChargeBar extends ProgressBar

@export var max_charge_rate = 500
var charging = false
var charge_rate = 100
var decay_rate = 300

func _process(delta: float) -> void:
	if charging and charge_rate > 0 and value <= 100:
		value += delta * 100 * charge_rate
		print("charging; ", value)
	if (not charging) and value > 0:
		value -= delta * decay_rate
	pass

func start_charging(new_charge_rate):
	charging = true
	charge_rate = min(new_charge_rate, max_charge_rate)
	pass

func set_charge(charge_value):
	if ((charge_value < 100) && (charge_value > 0)):
		value = charge_value
	pass
