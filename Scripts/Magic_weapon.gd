extends Weapon

class_name Magic_weapon

var charging_held_time = 0
@export var charge_time = 0
var is_charged = false
signal charged
signal toggle_spell_area(_visible:bool)

func _ready():
	super._ready()

func _process(delta):
	super._process(delta)
	if visible:
		if Input.is_action_just_pressed("charge"):
			charging_held_time += delta
		
		if charge_time < charging_held_time:
			if not is_charged:
				charged.emit()
			is_charged = true
			charging_held_time = 0
			charge_time = 0

func _on_attack():
	if is_charged and visible:
		toggle_spell_area.emit(false)

func _on_charged():
	if visible:
		toggle_spell_area.emit(true)
		print("charged")
	charge_time = 0

func _on_weapon_hide():
	toggle_spell_area.emit(false)
	is_charged = false
