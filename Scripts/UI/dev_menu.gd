extends Control

@onready var dev_menu = $DevMenu
@onready var level_choice = $DevMenu/ChangeScene/OptionButton
@onready var spell_choice = $DevMenu/ChangeSpell/OptionButton
@onready var zoom_scroll_bar = $DevMenu/ChangeZoom/ZoomScrollBar
@onready var teleport_x = $DevMenu/Teleport/HBoxContainer/X
@onready var teleport_y = $DevMenu/Teleport/HBoxContainer2/Y
@export var max_zoom = 10
@export var tile_size = 16
var player = null

var level_paths = {}
var spell_paths = {}

func _ready():
	populate_paths("res://Scenes/Levels", level_paths, level_choice)
	populate_paths("res://Scenes/Spells", spell_paths, spell_choice)
	zoom_scroll_bar.max_value = 10
	zoom_scroll_bar.min_value = 0.1
	player = WorldManager.players[0]
	
	if player:
		zoom_scroll_bar.value = player.camera.zoom.x

func populate_paths(directory_path: String, path_dict: Dictionary, option_button):
	var dir = DirAccess.open(directory_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name:
			if file_name.ends_with(".tscn"):
				var _name = file_name.substr(0, file_name.length() - 5)  # Remove the .tscn extension
				path_dict[_name] = directory_path + "/" + file_name
				option_button.add_item(_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Failed to open directory: " + directory_path)

func _on_dev_menu_button_toggled(toggled_on):
	dev_menu.visible = toggled_on

func _on_change_scene_button_pressed():
	var selected_id = level_choice.get_selected_id()
	var scene_name = level_choice.get_item_text(selected_id)
	if scene_name in level_paths:
		var path = level_paths[scene_name]
		if path:
			get_tree().change_scene_to_file(path)
		else:
			print("Failed to load scene: " + path)

func _on_change_spell_button_pressed():
	var selected_id = spell_choice.get_selected_id()
	var scene_name = spell_choice.get_item_text(selected_id)
	if scene_name in spell_paths:
		var path = spell_paths[scene_name]
		if path and player:
			player.set_weapon_spell(load(path))
		else:
			print("Failed to load scene: " + path)

func _on_zoom_scroll_bar_value_changed(value):
	if player:
		player.camera.zoom.x = value
		player.camera.zoom.y = value

func _on_teleport_button_pressed():
	var x = int(teleport_x.text) * tile_size
	var y = int(teleport_y.text) * tile_size
	if player:
		if not y:
			y = 0
		if not x:
			x = 0
		player.global_position = Vector2(x,y)
		print("set player position to x: ",x, " y: ",y)
