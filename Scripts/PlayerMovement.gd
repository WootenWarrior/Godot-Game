extends CharacterBody2D


@export var speed: float = 200.0
@onready var playerSprite = $PlayerCharacter
@onready var spellArea = $SpellArea
@onready var weapon = $Spellbook
var isFacingUp = false

func _ready():
	spellArea.visible = false

func _physics_process(delta):
	var mousePos = get_global_mouse_position()
	spellArea.global_position = mousePos
	velocity = Vector2()
	var direction = Vector2.ZERO
	
	if mousePos.y > position.y:
		isFacingUp = false
		if mousePos.x > position.x:
			playerSprite.flip_h = false
		else: 
			playerSprite.flip_h = true
	else:
		isFacingUp = true
		if mousePos.x > position.x:
			playerSprite.flip_h = true
		else: 
			playerSprite.flip_h = false
	
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
		if isFacingUp:
			playerSprite.play("Up_Walk")
		else:
			playerSprite.play("Down_Walk")
	if Input.is_action_pressed("move_down"):
		direction.y += 1
		if isFacingUp:
			playerSprite.play("Up_Walk")
		else:
			playerSprite.play("Down_Walk")
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
		if isFacingUp:
			playerSprite.play("Up_Walk")
		else:
			playerSprite.play("Down_Walk")
	if Input.is_action_pressed("move_right"):
		direction.x += 1
		if isFacingUp:
			playerSprite.play("Up_Walk")
		else:
			playerSprite.play("Down_Walk")

	if isFacingUp and direction == Vector2.ZERO:
		playerSprite.play("Up_Idle")
	elif !isFacingUp and direction == Vector2.ZERO:
		playerSprite.play("Down_Idle")
	
	velocity = direction*speed
	move_and_slide()


func _on_spellbook_show_spell_area(spellAreaAnimation:StringName):
	spellArea.play(spellAreaAnimation)
	if !spellArea.visible:
		spellArea.visible = true
	else:
		spellArea.visible = false
