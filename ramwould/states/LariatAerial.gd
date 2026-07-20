extends "res://slimegirl/ramwould/states/SlimeState.gd"

const FRIC = "0.33"

func _frame_6():
	host.apply_x_fric(FRIC)
	host.apply_y_fric(FRIC)
