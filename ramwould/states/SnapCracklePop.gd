extends "res://slimegirl/ramwould/states/SlimeState.gd"

var dir_x = "0"
var dir_y = "0"

func _enter():
	var _range = fixed.mul(host.current_radiation_radius, "0.130")
	var dir = xy_to_dir(data.x, data.y, _range)
	dir_x = dir.x
	dir_y = dir.y
	
func _frame_6():
	var obj:BaseProjectile = host.spawn_object(preload("res://slimegirl/ramwould/projectiles/SnapCracklePopProj.tscn"), 18, -23)
	obj.init(null)
	obj.current_state().move_x = int(dir_x)*host.get_facing_int()
	obj.current_state().move_y = int(dir_y)
	obj.set_snap_to_ground( false )
	obj.set_facing( host.get_facing_int() )
	
	host.play_sound("Snap")
	host.global_hitlag(4, true)
	host.snapcracklpop_ticks = host.MAX_SNAPCRACKLPOP_TICKS
	
func is_usable():
	return .is_usable() and host.snapcracklpop_ticks <= 0
