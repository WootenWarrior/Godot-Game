extends Weapon

class_name Magic_weapon

var charging_held_time = 0
var charge_time = 0
var is_charged = false

signal charged
signal toggle_spell_area(_visible:bool)

func _ready():
	super._ready()

func _process(delta):
	super._process(delta)
	if visible:
		if Input.is_action_pressed("charge") and not is_charged:
			charging_held_time += delta
			#print("charging value = ",charging_held_time)
			#print("charge time = ", charge_time)
		if Input.is_action_just_released("charge") and not is_charged:
			charging_held_time = 0
		
		if charge_time < charging_held_time:
			reset_charge()

func _on_attack():
	if is_charged and visible:
		toggle_spell_area.emit(false)

func reset_charge():
	toggle_spell_area.emit(true)
	#print("charged")
	charging_held_time = 0
	is_charged = true

func _on_weapon_hide():
	toggle_spell_area.emit(false)
	is_charged = false
