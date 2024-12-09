extends Weapon

class_name Magic_weapon

var charging_held_time = 0
var charge_time = 0
var is_charged = false
var equipped_spell = null
var equipped_spell_scene = null

signal charged

func _ready() -> void:
	super._ready()

func _process(delta) -> void:
	if player:
		super._process(delta)
		if visible and not is_charged:
			if Input.is_action_pressed("charge"):
				charging_held_time += delta
				charge_bar.value = charging_held_time*100
			if Input.is_action_just_released("charge"):
				charging_held_time = 0
				charge_bar.value = 0
			
			if charge_time < charging_held_time:
				complete_charge()

func set_spell(new_spell_scene : Resource) -> void:
	if equipped_spell:
		equipped_spell.queue_free()
	
	if new_spell_scene and player:
		equipped_spell_scene = new_spell_scene
		equipped_spell = equipped_spell_scene.instantiate()
		charge_time = equipped_spell.spell_config.charge_time
		#print(charge_time)

func instantiate_spell() -> void:
	equipped_spell = equipped_spell_scene.instantiate()
	get_tree().root.add_child(equipped_spell)
	if equipped_spell.type == Enums.spell_types.AREA:
		equipped_spell.visible = false

func _on_attack() -> void:
	if is_charged and visible:
		Signals.toggle_spell_area.emit()

func complete_charge() -> void:
	if equipped_spell_scene:
		instantiate_spell()
	if equipped_spell.type == Enums.spell_types.AREA:
		Signals.toggle_spell_area.emit()
	equipped_spell.idle.emit()
	#print("charged")
	charging_held_time = 0
	is_charged = true

func _on_weapon_hide() -> void:
	Signals.toggle_spell_area.emit()
	is_charged = false
