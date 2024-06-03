extends AnimatedSprite2D

class_name Projectile

var direction = Vector2()
var speed = 0
var damage = 10
var chargeTime = 1
var max_speed = 100

func _process(delta):
	if speed > 0:
		position += direction * speed * delta

func _on_body_entered(body):
	play("Hit")
	queue_free()

func Fire(directionValue: Vector2):
	play("Fire")
	direction = directionValue
	speed = max_speed
	play("Move")

func Spawn():
	play("Spawn")
	
func Despawn():
	await play_backwards("Spawn")
	queue_free()

func Idle():
	play("Idle")
