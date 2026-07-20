extends "res://slimegirl/ramwould/states/SlimeState.gd"

var dir_x = "0"
var dir_y = "0"
const SPEED_MOD = "16"
var goop = false

func _enter():
	dir_x = "1"
	dir_y = "0"
	goop = false
	if data is Dictionary:
		var dir = xy_to_dir(data["Direction"].x, data["Direction"].y, SPEED_MOD)
		dir_x = dir.x
		dir_y = dir.y
		goop = data["Goop"]

func _frame_5():
	host.apply_force_relative("2", "0")

func _frame_7():
	var obj :BaseProjectile= host.spawn_object(preload("res://slimegirl/ramwould/projectiles/Slimeball.tscn"), 4, -30, true, null, true)
	obj.set_grounded(false)
	obj.set_facing( host.get_facing_int() )
	obj.apply_force(dir_x, dir_y)
	if host.on_fire_this_state:
		host.append_fiery_projectile(obj)
	if goop:
		obj.damages_own_team = true
		host.stick_goop_to_obj(obj, true)

