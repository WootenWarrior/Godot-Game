extends CharacterBody2D

@export var speed = 60
@export var range = 100
@export var force_component: ForcesComponent = null
@export var animation_source: AnimatedSprite2D

var target_position: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if target_position != Vector2.ZERO:
		var distance = global_position.distance_to(target_position)
		
		if distance + 1 >= range:
			var direction = global_position.direction_to(target_position)
			velocity = (direction * speed) + force_component.external_forces
			move_and_slide()
		
		if distance < range:
			var direction = -global_position.direction_to(target_position)
			velocity = (direction * speed) + force_component.external_forces
			move_and_slide()
		
		handle_sprite_direction(target_position)
		#print(target_position)
		look_at(target_position)
	pass

func handle_sprite_direction(pos: Vector2):
	if pos.y > global_position.y:
		if pos.x > global_position.x:
			animation_source.flip_h = true
			animation_source.flip_v = false
		else: 
			animation_source.flip_h = true
			animation_source.flip_v = true
	else:
		if pos.x > global_position.x:
			animation_source.flip_h = true
			animation_source.flip_v = false
		else:
			animation_source.flip_h = true
			animation_source.flip_v = true
			
