extends Node

func add_effect_to_scene(effect: Node2D):
	var current_scene = get_tree().current_scene
	var effects_parent = current_scene.get_node_or_null("effects")
	if(effects_parent):
		effects_parent.add_child(effect)
	else:
		effects_parent = Node2D.new()
		effects_parent.name = "effects"
		current_scene.add_child(effects_parent)
		effects_parent.add_child(effect)
	pass
