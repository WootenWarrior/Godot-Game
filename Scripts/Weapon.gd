extends AnimatedSprite2D

class_name Weapon

@export var radius: int = 100
@export var spellOffset: int = 20
@onready var player = get_parent()
var testSpell = preload("res://Scenes/Fireball.tscn")
var equipedSpell = null
var projectileSpeed = 0
var charged = false
var spellIdle = false
var holdTime: float = 0.5
var currentHeldTime: float = 0

signal showSpellArea
var isSpellAreaShown = false

func _ready():
	visible = false

func _process(delta):
	if Input.is_action_just_pressed("get_weapon_out"):
		visible = true
		play("Page_Flip")
	elif Input.is_action_just_pressed("put_weapon_away"):
		visible = false
		equipedSpell.queue_free()
		equipedSpell = null
	
	if visible:
		if spellIdle:
			currentHeldTime += delta
		if currentHeldTime > holdTime:
			if !charged:
				print("fully charged")
			equipedSpell.Idle()
			charged = true
			
		if Input.is_action_just_pressed("charge"):
			InstantiateSpellObject()
			if equipedSpell.hasSpellArea and !isSpellAreaShown:
				showSpellArea.emit(equipedSpell.spellAreaType)
				isSpellAreaShown = true
			spellIdle = true
			equipedSpell.Spawn()
			print("spawning")
		if Input.is_action_just_pressed("fire"):
			spellIdle = false
			if equipedSpell:
				if equipedSpell.hasSpellArea and isSpellAreaShown:
					showSpellArea.emit()
					isSpellAreaShown = false
				if charged:
					var direction = get_global_mouse_position()-player.position
					equipedSpell.Fire(direction.normalized())
					print(direction.normalized())
					print("fired")
				else:
					print("despawning")
					equipedSpell.Despawn()
			equipedSpell = null
			charged = false
			currentHeldTime = 0
		
		if equipedSpell:
			SetSpellPos()
		SetWeaponPos()

func SetSpellPos():
	if visible and equipedSpell:
		var playerPos = player.global_position
		var mousePos = get_global_mouse_position()
		var direction = mousePos - playerPos
		var angle = direction.angle()
		var x_spell = playerPos.x + (radius + spellOffset) * cos(angle)
		var y_spell = playerPos.y + (radius + spellOffset) * sin(angle)
		equipedSpell.global_position = Vector2(x_spell, y_spell)
		equipedSpell.rotation = angle + PI / 2
		equipedSpell.look_at(get_global_mouse_position())

func SetWeaponPos():
	if visible:
		var mouse_pos = get_global_mouse_position()
		var player_pos = player.global_position
		var direction = mouse_pos - player_pos
		var angle = direction.angle()

		var x = player_pos.x + radius * cos(angle)
		var y = player_pos.y + radius * sin(angle)

		global_position = Vector2(x, y)
		rotation = angle + PI / 2
	
		if player.position.y > mouse_pos.y:
			z_index = -2
			if equipedSpell:
				equipedSpell.z_index = -1
		else:
			z_index = 0
			if equipedSpell:
				equipedSpell.z_index = 0

func InstantiateSpellObject():
	if !equipedSpell:
		equipedSpell = testSpell.instantiate()
		player.add_child(equipedSpell)
		equipedSpell.name = "Fireball"
