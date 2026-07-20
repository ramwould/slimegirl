extends "res://slimegirl/ramwould/states/SLOPPY STANCE/SlopState.gd"

func _frame_0():
	if host.queued_beam_shockwave:
		var center = host.get_hurtbox_center_float()
		center.y = 0
		host.spawn_shockwave(center, false)
