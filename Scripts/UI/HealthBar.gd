extends ProgressBar

@onready var damage_bar = $DamageBar
var health = 0 : set = set_health
var health_decrease_val = 0.3

func _process(delta):
	if health < damage_bar.value:
		damage_bar.value -= health_decrease_val
	else:
		damage_bar.value = health

func set_health(new_health):
	health = min(max_value,new_health)
	value = health

func init_health(_health):
	health = _health
	max_value = _health
	value = _health
	damage_bar.max_value = _health
	damage_bar.value = _health
