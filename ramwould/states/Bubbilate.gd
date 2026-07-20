extends "res://slimegirl/ramwould/states/SlimeState.gd"

var dir_x = "0"
var dir_y = "0"
const SPEED_MOD = "7.0"


func _enter():
	dir_x = "1"
	dir_y = "0"

	if data is Dictionary:
		var dir = xy_to_dir(data["Direction"].x, data["Direction"].y, SPEED_MOD)
		dir_x = dir.x
		dir_y = dir.y
		
func _frame_5():
	host.apply_force_relative("2", "0")

func _frame_7():
	var obj :BaseProjectile= host.spawn_object(preload("res://slimegirl/ramwould/projectiles/Bubbilate.tscn"), 4, -30, true, null, true)
	obj.apply_force(dir_x, dir_y)
	if host.on_fire_this_state:
		host.append_fiery_projectile(obj)
	
