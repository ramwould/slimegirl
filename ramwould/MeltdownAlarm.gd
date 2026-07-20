extends ColorRect

onready var host = get_parent()
const MAX_TIME = 20.0
var meltdown_alpha:float = 0.0

func _process(delta):
	visible = meltdown_alpha > 0
	var game:Game = Global.current_game
	if game and game.game_paused:
		visible = false
	meltdown_alpha -= 1
	update()

func _draw():
	var d = clamp(meltdown_alpha/MAX_TIME, 0, 1)
	var meltdown_lerp = lerp(0.0, 1.0, d)
	color = host.color_else_slime("style_2")
	modulate.a = meltdown_lerp
	self_modulate.a = 0.45

func _on_meltdown_alarm():
	meltdown_alpha = MAX_TIME
