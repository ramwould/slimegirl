extends "res://slimegirl/ramwould/states/SlimeState.gd"

onready var hitbox = $Hitbox

const FULL_TIME = 20
const EXTRA_TICKS = 6

var pos_x = "0"
var pos_y = "0"

func _enter():
	pos_x = "0"
	pos_y = "0"
	
	if data:
		var vec01 = xy_to_dir(data.x, data.y, host.current_radiation_radius)
		pos_x = vec01.x
		pos_y = vec01.y

func _frame_8():
	host.update_data()
	
	var vec = Vector2(float(pos_x), float(pos_y))
	var pos:Vector2 = host.radius_center()
	var pos_local = host.to_local(pos)
	
	var max_time = FULL_TIME + EXTRA_TICKS
	host.syringe_extend(max_time, vec+pos)

	if host.lassail_projectile():
		var proj = host.lassail_projectile()
		var pos_lassail = proj.to_local(pos)

		hitbox.x = (vec.x*host.get_facing_int()) + ((pos_local.x-pos_lassail.x)*host.get_facing_int())
		hitbox.y = (vec.y) + (pos_local.y-pos_lassail.y)
		
		var dir = proj.obj_local_center(host.opponent)
		hitbox.dir_x = fixed.mul( str(dir.x), str(host.get_facing_int()) )
		hitbox.dir_y = str(dir.y)

	else:
		hitbox.x = (vec.x*host.get_facing_int()) + pos_local.x
		hitbox.y = (vec.y) + pos_local.y
		
		var dir = host.obj_local_center(host.opponent)
		hitbox.dir_x = fixed.mul( str(dir.x), str(host.get_facing_int()) )
		hitbox.dir_y = str(dir.y)
		
#	var dir = fixed.normalized_vec(fixed.abs(pos_x), pos_y)
#	hitbox.dir_x = dir.x
#	hitbox.dir_y = dir.y
