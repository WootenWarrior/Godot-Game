extends ProgressBar

@onready var sprint_loss_bar = $SprintLossBar
var sprint = 0 : set = set_sprint
var sprint_decrease_val = 0.3

func _process(delta):
	if sprint < sprint_loss_bar.value:
		sprint_loss_bar.value -= sprint_decrease_val
	else:
		sprint_loss_bar.value = sprint

func set_sprint(new_sprint):
	sprint = min(max_value,new_sprint)
	value = sprint

func init_sprint(_sprint):
	sprint = _sprint
	max_value = _sprint
	value = _sprint
	sprint_loss_bar.max_value = _sprint
	sprint_loss_bar.value = _sprint
