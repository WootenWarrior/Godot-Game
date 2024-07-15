extends Weapon

class_name Magic_weapon

var charging_held_time = 0
var charge_time = 0
var is_charged = false
var equipped_spell = null
var equipped_spell_scene = null

signal charged
signal toggle_spell_area(_visible:bool)

func _ready() -> void:
	super._ready()

func _process(delta) -> void:
	super._process(delta)
	if visible and not is_charged:
		if Input.is_action_pressed("charge"):
			charging_held_time += delta
			charge_bar.value = charging_held_time*100
			#print(charge_bar.value)
			#print("charging value = ",charging_held_time)
			#print("charge time = ", charge_time)
		if Input.is_action_just_released("charge"):
			charging_held_time = 0
			charge_bar.value = 0
		
		if charge_time < charging_held_time:
			if equipped_spell:
				equipped_spell.idle.emit()
			complete_charge()

func set_spell(new_spell : Resource) -> void:
	equipped_spell_scene = new_spell

func _on_attack() -> void:
	if is_charged and visible:
		toggle_spell_area.emit(false)

func complete_charge() -> void:
	if equipped_spell.has_spell_area:
		toggle_spell_area.emit(true)
	#print("charged")
	charging_held_time = 0
	is_charged = true

func _on_weapon_hide() -> void:
	toggle_spell_area.emit(false)
	is_charged = false
