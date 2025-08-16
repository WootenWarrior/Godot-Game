class_name DetectionRegion extends Area2D

@export var radius = 300
@export var pathfind_component: PathfindComponent
@export var target: Node2D

func _ready() -> void:
	var shape = CircleShape2D.new()
	update_shape(radius, shape)

func update_shape(radius: int, shape: Shape2D):
	shape.radius = radius
	if !$CollisionShape2D:
		add_child(CollisionShape2D.new())
	$CollisionShape2D.shape = shape

func _on_body_entered(body: Node2D) -> void:
	target = body
	pathfind_component.target = body
	pass

func _on_body_exited(body: Node2D) -> void:
	target = null
	pathfind_component.target = null
