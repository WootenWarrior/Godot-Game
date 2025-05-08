@tool
extends Control

const sprite_size = Vector2(32,32)

@export var line_color : Color
@export var background_color : Color

@export var line_width : int = 2
@export var inner_radius : int = 50
@export var outer_radius : int = 200

@export var options = []
@export var max_options : int = 6
@export var min_options : int = 3

var selection = 0

func _draw():
	var offset = sprite_size / -2
	
	var num_of_options = clamp(len(options),min_options,max_options)
	
	draw_circle(
		Vector2.ZERO,
		outer_radius,
		background_color
	)
	
	draw_arc(
		Vector2.ZERO,
		inner_radius,
		0,
		TAU,
		128,
		line_color,
		line_width,
		true
	)
	
	for i in range(num_of_options - 1):
		var rads = TAU * i / (num_of_options - 1)
		var point = Vector2.from_angle(rads)
		
		draw_line(
			point * inner_radius,
			point * outer_radius,
			line_color,
			line_width,
			true
		)
	
	#draw_texture_rect_region()

func _process(delta):
	var mouse_pos = get_local_mouse_position()
	var radius = mouse_pos.length()
	
	if radius < inner_radius:
		selection = 0
	else:
		var mouse_rads = fposmod(mouse_pos.angle() * -1, TAU)
		selection = ceil((mouse_rads / TAU) * (len(options) - 1))
	
	#print(selection)
	queue_redraw()
