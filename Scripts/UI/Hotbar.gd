extends Control

@onready var box_container = $CenterContainer/BoxContainer
@onready var hotbar_slot = load("res://Scenes/UI/hotbar_slot.tscn")
@export var num_of_slots = 5
var hotbar_slots = []
var hotbar_spells = []
var current_selected = null
signal spell_hotbar_updated

func _ready() -> void:
	add_hotbar_spell(load("res://Scenes/Spells/Fireball.tscn"))
	add_hotbar_spell(load("res://Scenes/Spells/LightningStrike.tscn"))
	
	for i in range(num_of_slots):
		var _hotbar_slot = hotbar_slot.instantiate()
		box_container.add_child(_hotbar_slot)
		_hotbar_slot.set_label_text(str(i+1))
		hotbar_slots.append(_hotbar_slot)
	
	set_hotbar_slots()

func _process(delta):
	if Input.is_action_just_pressed("box1select"):
		select_hotbar_slot(1)

func clear_hotbar() -> void:
	for slot in hotbar_slots:
		slot.spell = null
	SpellInventoryManager.clear_hotbar_spells()
	set_hotbar_slots()

func set_hotbar_slots() -> void:
	var hotbar_spells = get_hotbar_spells()
	var i = 0
	for slot in box_container.get_children():
		var image = slot.get_child(0)
		if hotbar_spells.size() > i:
			var hotbar_image = hotbar_spells[i].instantiate().hotbar_image
			image.texture = hotbar_image
			slot.spell = hotbar_spells[i]
		i = i+1

func select_hotbar_slot(slot_num:int):
	var slot_selected = hotbar_slots[slot_num-1]
	var spell = slot_selected.spell
	if slot_selected == current_selected:
		SpellInventoryManager.player_node.weapon.set_spell(null)
	else:
		slot_selected.color = Color(255,255,255,170)
		SpellInventoryManager.player_node.weapon.set_spell(spell)

func add_hotbar_spell(spell_scene:Resource) -> void:
	hotbar_spells.append(spell_scene)

func get_hotbar_spells() -> Array:
	return hotbar_spells

func clear_hotbar_spells() -> void:
	hotbar_spells = []
