extends CharacterBody2D


@export var speed: float = 200.0
@onready var animatedSprite = $AnimatedSprite2D
var isFacingUp = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var mousePos = get_global_mouse_position()
	velocity = Vector2()
	var direction = Vector2.ZERO
	
	if mousePos.y > position.y:
		isFacingUp = false
		if mousePos.x > position.x:
			animatedSprite.flip_h = false
		else: 
			animatedSprite.flip_h = true
	else:
		isFacingUp = true
		if mousePos.x > position.x:
			animatedSprite.flip_h = true
		else: 
			animatedSprite.flip_h = false
	
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
		if isFacingUp:
			animatedSprite.play("Up_Walk")
		else:
			animatedSprite.play("Down_Walk")
	if Input.is_action_pressed("move_down"):
		direction.y += 1
		if isFacingUp:
			animatedSprite.play("Up_Walk")
		else:
			animatedSprite.play("Down_Walk")
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
		if isFacingUp:
			animatedSprite.play("Up_Walk")
		else:
			animatedSprite.play("Down_Walk")
	if Input.is_action_pressed("move_right"):
		direction.x += 1
		if isFacingUp:
			animatedSprite.play("Up_Walk")
		else:
			animatedSprite.play("Down_Walk")

	if isFacingUp and direction == Vector2.ZERO:
		animatedSprite.play("Up_Idle")
	elif !isFacingUp and direction == Vector2.ZERO:
		animatedSprite.play("Down_Idle")
	
	velocity = direction*speed
	move_and_slide()
