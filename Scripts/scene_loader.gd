extends Node2D

@export var root: Node2D = null
var current_scene = null

func load_scene(scene_name: String):
	var path = "res://Scenes/%s.tscn" % scene_name
	var resource = load(path)
	if resource and root:
		current_scene = resource.instance()
		root.add_child(current_scene)
	else:
		print("Failed to load: " + path)
	pass

func unload_current_scene():
	if is_instance_valid(current_scene):
		current_scene.queue_free()
	current_scene = null
	pass
