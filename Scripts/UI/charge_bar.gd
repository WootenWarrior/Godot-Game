class_name ChargeBar extends ProgressBar

@export var max_charge_rate = 500
var charging = false
@export var charge_rate = 100
var decay_rate = 300

func _process(delta: float) -> void:
	if charging and charge_rate > 0 and value <= 100:
		value += delta * 100 * charge_rate
		#print("charging: ", value)
		#print("charge rate: ", charge_rate)
	if (not charging) and value > 0:
		value -= delta * decay_rate
	pass

func set_charge(charge_value):
	if ((charge_value <= max_charge_rate) && (charge_value > 0)):
		value = charge_value
	pass
