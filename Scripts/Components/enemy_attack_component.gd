class_name EnemyAttack extends Node2D

@export var detection_region: DetectionRegion
@export var cast_point: Node2D
@export var attack_damage: float = 10
@export var fire_rate: float = 1: 
	set(new_fire_rate):
		fire_rate = new_fire_rate
		if timer:
			timer.wait_time = fire_rate

var spell = load("res://Scenes/Projectiles/enemy_blast.tscn")
var timer: Timer = null
var can_attack = true

func _ready() -> void:
	if not timer:
		timer = Timer.new()
		add_child(timer)
	timer.wait_time = fire_rate
	timer.connect("timeout", _on_timeout)
	timer.autostart = true
	timer.start()

func attack():
	var spell_scene = spell.instantiate()
	add_child(spell_scene)
	spell_scene.spawn_pos = cast_point.global_position
	spell_scene.target = detection_region.target.global_position
	pass

func _on_timeout():
	if can_attack and detection_region.target:
		attack()
