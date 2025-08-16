class_name PathfindComponent extends Node2D

@export var navigation_agent: NavigationAgent2D
@export var body: CharacterBody2D
@export var timer: Timer

var target: CharacterBody2D = null: 
	set(new_target):
		target = new_target
		if not target:
			body.target_position = Vector2.ZERO

func _ready() -> void:
	timer.connect("timeout", _on_timer_timeout)
	timer.autostart = true
	timer.start()
	make_path()

func _physics_process(delta: float) -> void:
	#print(target)
	move_towards_target()

func move_towards_target() -> void:
	if navigation_agent && body && target:
		body.target_position = navigation_agent.target_position

func make_path():
	if (target):
		navigation_agent.target_position = target.global_position

func _on_timer_timeout() -> void:
	make_path()
