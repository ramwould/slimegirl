extends "res://slimegirl/ramwould/states/SlimeState.gd"

var flip = false

func _enter():
	if data is bool:
		flip = data
	
func _exit():
	if hit_anything:
		host.reset_goop( true )
		if flip:
			host.turn_around()
