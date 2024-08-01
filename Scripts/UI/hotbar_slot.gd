extends ColorRect

@onready var image = $TextureRect
@onready var label = $Label
var spell = null

func set_image(_image):
	image = _image

func set_label_text(_text:String):
	label.text = _text
