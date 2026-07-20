extends Node2D

onready var host = $"../../.."

func _process(delta):
	visible = false
	if host.in_meltdown():
		visible = true
		var game:Game = Global.current_game
	update()
	
func _draw():
	rotation_degrees += 2
	scale = Vector2.ONE
	scale *= (float(host.visual_radius)/82.0) * 0.88
	
	modulate = host.color_else_slime("style_2")
	modulate.a = 1.00
	modulate.a *= host.MOD_RADIUS_OPACITY_MULT
