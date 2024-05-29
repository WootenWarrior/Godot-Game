extends AnimatedSprite2D

var direction = Vector2()
var speed = 0

func _process(delta):
	if speed > 0:
		position += direction * speed * delta

func Fire():
	play("Fire")

func _body_entered(body):
	
