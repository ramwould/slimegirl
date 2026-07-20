extends "res://slimegirl/ramwould/states/SlimeState.gd"

const SCALED_POWER = "16"
var power = "0.5"

func _enter():
	land_cancel_state = "Landing"
#	land_cancel = false
	apply_grav = true
	power = "0.5"
	if data:
		power = str(data.x/100.0)

func _frame_0():
	host.apply_force_relative("-2", "-4")
	
func _frame_7():
	apply_grav = false
	var dir = fixed.normalized_vec_times("6", "4.5", fixed.mul(power,SCALED_POWER))
	host.reset_momentum()
	host.apply_force_relative(dir.x, dir.y)

func _frame_8():
	land_cancel_state = "Tumble"
