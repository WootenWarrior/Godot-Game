extends AnimatedSprite2D

class_name Weapon

@onready var area = $Area2D
@onready var player = null
@onready var charge_bar_scene = preload("res://Scenes/UI/SpellChargeBar.tscn")
var damage: float = 0.0
var base_z_index = 1
var charge_bar = null

signal charge
signal weapon_out
signal weapon_hide

func _ready() -> void:
	Signals.connect("player_attack",Callable(self,"_on_player_attack"))
	player = get_tree().current_scene.get_node("Player")
	
	if player:
		if area:
			area.connect("body_entered", Callable(self, "_on_area_body_entered"))
			area.connect("body_exited", Callable(self, "_on_area_body_exited"))
		else:
			print("Please set an area as child of the root")
		
		initialise_charge_bar()

func _process(_delta) -> void:
	if Input.is_action_just_pressed("get_weapon_out") and not visible:
		visible = true
		charge_bar.visible = true
		weapon_out.emit()
	elif Input.is_action_just_pressed("put_weapon_away") and visible:
		visible = false
		charge_bar.visible = false
		weapon_hide.emit()
		
	if visible:
		if Input.is_action_just_pressed("fire"):
			charge_bar.value = 0
		if Input.is_action_just_pressed("charge"):
			charge.emit()

func initialise_charge_bar() -> void:
	charge_bar = charge_bar_scene.instantiate()
	player.add_child(charge_bar)
	charge_bar.position = Vector2(charge_bar.position.x - 15, charge_bar.position.y + 20)
	charge_bar.scale.x = 0.3
	charge_bar.scale.y = 0.3
	charge_bar.visible = false
	charge_bar.value = 0

func _on_area_body_entered(body) -> void:
	if body is TileMap:
		player.get_child(0).z_index = body.get_layer_z_index(1) - 1
		#print("enter weapon: ",z_index)
		#print("player: ",player.z_index)

func _on_area_body_exited(body) -> void:
	if body is TileMap:
		player.get_child(0).z_index = 0
		#print("exit weapon: ",z_index)
		#print("player: ",player.z_index)

