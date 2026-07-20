extends Node2D

export(String, "Line", "Circle") var type
export var start_position:Vector2
export var end_position:Vector2
export var line_size_multiplier:float = 1
export var line_size:Curve
export var blend_beam:bool = false
export var duration:float = 5.0
export var to_ground:bool = false

var time_alive = 0
var real_ticks = 0
var override_visibility = false

onready var tint = $"%Tint"

func _process(delta):
	var d:float = clamp(time_alive/duration, 0, 1)
	visible = d < 1 and not override_visibility
	if blend_beam and real_ticks<=0:
		visible = false
	update()
	
func _draw():
	var d:float = clamp(time_alive/duration, 0, 1)
	var size = line_size.interpolate_baked(d)*line_size_multiplier
	if blend_beam:
		var tint_color = tint.modulate
		var white = Color.white
		
		var rd = abs(d-1)
		white.a = 0.6*rd
		self_modulate = tint_color.blend(white)
		self_modulate.a = 1
		
	match type:
		"Line":
			if to_ground:
				end_position.x = -global_position.y
			if blend_beam:
				size *= 0.6
			draw_line(start_position, end_position, Color.white, size)
		
		"Circle":
			if blend_beam:
				size *= 0.65
			draw_circle(start_position, size, Color.white)
