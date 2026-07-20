extends "res://fx/SpeedImageEffect.gd"

var max_size = 2.0
export var effect = "scale"

#var origional_position = position

func _init():
	pass
	
func tick():
	.tick()
	
	match effect:
		"scale":
			scale = Vector2.ONE * Utils.map(Utils.frames(tick), 0, lifetime, 1.0, max_size)
