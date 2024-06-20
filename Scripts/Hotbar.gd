extends Control

@onready var hotbar_container = $HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func clear_hotbar():
	while(hotbar_container.get_child_count() > 0):
		var child = hotbar_container.get_child(0)
		hotbar_container.remove_child(child)
		child.queue_free()

