extends "res://slimegirl/ramwould/states/SlimeState.gd"

var dir_x = "0"
var dir_y = "0"
const OFFSET_POWER = "3.5"
const X_MOD = "1.5"

func _enter():
	var vector01 = xy_to_dir(data.x, data.y, OFFSET_POWER)
	dir_x = fixed.mul(vector01.x, X_MOD)
	dir_y = vector01.y
	
func _frame_5():
	var total_x = dir_x
	var total_y = fixed.add("-10.0", dir_y)
	host.apply_force(total_x, total_y)
