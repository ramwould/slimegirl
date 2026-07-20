extends Node2D

onready var host = get_parent()
const MAX_LENGTH = 60

export var x_scale:Curve
var offset:int = 0

func _process(delta):
	if host.disabled:
		visible = false
	update()
	
func _draw():
	var state = host.current_state()
	if state:
		var lifetime:float = state.lifetime
		var d = clamp((state.current_tick+offset) / lifetime, 0.0, 1.0)
		var x_length:int = x_scale.interpolate(d) * MAX_LENGTH
		var pos = to_local( host.get_center_position_float() )
		
		var uses_outline = host.get_fighter().sprite.get_material().get_shader_param("use_outline")		
		if uses_outline:
			draw_line(Vector2(pos.x - x_length, 0), Vector2(pos.x + x_length, 0), host.get_fighter().color_else_slime("outline"), 7.0, false)
		draw_line(Vector2(pos.x - x_length, 0), Vector2(pos.x + x_length, 0), host.get_fighter().color_else_slime(), 4.0, false)
