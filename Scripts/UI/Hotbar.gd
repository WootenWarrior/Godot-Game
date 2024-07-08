extends Control

@onready var box_container = $CenterContainer/BoxContainer

func _ready():
	# Adding nodes programmatically if needed
	var label = Label.new()
	label.text = "1"
	box_container.add_child(label)
	
	var label2 = Label.new()
	label2.text = "2"
	box_container.add_child(label2)
	
	var label3 = Label.new()
	label3.text = "3"
	box_container.add_child(label3)

func clear_hotbar():
	for child in box_container.get_children():
		box_container.remove_child(child)
		child.queue_free()
