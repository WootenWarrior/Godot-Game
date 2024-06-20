extends AnimatedSprite2D

class_name Weapon

@onready var area = $Area2D
@onready var player = get_parent()
var damage: float = 0.0
var base_z_index = 1

signal attack
signal charge
signal weapon_out
signal weapon_hide

func _ready():
	if area:
		area.connect("body_entered", Callable(self, "_on_area_body_entered"))
		area.connect("body_exited", Callable(self, "_on_area_body_exited"))

func _process(delta):
	if Input.is_action_just_pressed("get_weapon_out") and not visible:
		visible = true
		weapon_out.emit()
	elif Input.is_action_just_pressed("put_weapon_away") and visible:
		visible = false
		weapon_hide.emit()
		
	if visible:
		if Input.is_action_just_pressed("fire"):
			attack.emit()
		if Input.is_action_just_pressed("charge"):
			charge.emit()

func _on_area_body_entered(body):
	if body is TileMap:
		body.set_layer_z_index(1,2)

func _on_area_body_exited(body):
	if body is TileMap:
		body.set_layer_z_index(1,-5)
