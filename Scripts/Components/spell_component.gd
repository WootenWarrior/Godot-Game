class_name Spell extends Node2D

@export var body: CharacterBody2D = null
@export var charge_bar: ChargeBar = null

var spells = {}
var active_spell: PackedScene = null
var active_spell_name: String
var charge_time = 0
var charged = false

func _ready() -> void:
	#temp
	spells["fireball"] =  load("res://Scenes/Projectiles/fireball.tscn")
	set_active_spell(spells["fireball"])

func _process(delta: float) -> void:
	if charge_bar.value == 100:
		charged = true
	
	if Input.is_action_pressed("charge"):
		charge_time += delta
		Signals.change_player_state.emit(Enums.States.CHARGING)
		charge_bar.charging = true
	
	if Input.is_action_just_released("charge"):
		charge_time = 0
		Signals.change_player_state.emit(Enums.States.IDLE)
		charge_bar.charging = false
		if charged:
			cast(get_global_mouse_position())
		charged = false
	
	pass

func set_active_spell(spell_scene: PackedScene):
	active_spell = spell_scene

func cast(target: Vector2):
	if (active_spell):
		var spell_node = active_spell.instantiate()
		spell_node.spawn_pos = body.global_position
		var number = get_child_count()
		spell_node.name += str(number)
		add_child(spell_node)
		spell_node.target = target
		spell_node.look_at(target)
		
	pass
