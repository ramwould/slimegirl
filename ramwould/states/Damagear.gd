extends "res://slimegirl/ramwould/states/SlimeState.gd"

func _frame_0():
	if not host.is_gooped():
		host.apply_x_fric("0.5")
		host.update_data()
