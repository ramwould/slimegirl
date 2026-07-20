extends "res://slimegirl/ramwould/states/SLOPPY STANCE/SlopState.gd"

func _frame_2():
	host.move_directly_relative(0, -2)
	
func _frame_3():
	host.move_directly_relative(2, 0)
	host.apply_force_relative("5.0", "-10.0")
