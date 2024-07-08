extends Physical_enemy

@onready var navigation_agent = $NavigationAgent2D as NavigationAgent2D
var knockback_force = 250
var is_colliding_with_player = false

func _ready():
	super._ready()
	health = 20
	attack_damage = 15
	speed = 50
	aggro_radius = 200
	set_collision_shape($PlayerCollisionArea/CollisionShape2D)
	set_animated_sprite_2d($AnimatedSprite2D)
	set_aggro_radius(aggro_radius,$DetectionRange/CollisionShape2D)
	set_health_bar($HealthBar)
	health_bar.init_health(health)

func _process(delta):
	if not dead:
		super._process(delta)
		if target:
			move_towards_target()
		
		if is_colliding_with_player:
			player.hit.emit(attack_damage)
		
		if velocity > Vector2.ZERO:
			AnimatedSprite.play("Walk")
		else:
			AnimatedSprite.play("Idle")
		
		if health <= 0:
			die()

func make_path() -> void:
	navigation_agent.target_position = player.global_position
	
	#print("moving towards = ",navigation_agent.target_position)
	#print("target_global_position = ",target.global_position)

func move_towards_target() -> void:
	var next_position = to_local(navigation_agent.get_next_path_position())
	var direction = next_position.normalized()
	velocity = (direction * speed) + external_forces
	
	#print("Next Path Position: ", next_position)
	#print("Direction: ", direction)
	#print("Velocity: ", velocity)
	
	move_and_slide()
	external_forces *= damping_factor

func _on_detection_range_body_entered(body) -> void:
	target = body
	make_path()

func _on_detection_range_body_exited(_body) -> void:
	target = null

func _on_timer_timeout() -> void:
	if target:
		make_path()

func _on_player_collision_area_body_entered(body):
	if body.is_in_group("Player"):
		is_colliding_with_player = true
		var direction = body.global_position - global_position
		body.apply_force(direction,knockback_force)

func _on_player_collision_area_body_exited(body):
	if body.is_in_group("Player"):
		is_colliding_with_player = false
