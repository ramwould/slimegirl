extends "res://slimegirl/ramwould/states/SLOPPY STANCE/SlopState.gd"

const FRIC = "0.6"
const FORCE = "14.0"

var dashing = false
var dir_x = "0"
var dir_y = "0"

onready var hitbox_up = $HitboxU
onready var hitbox_upfwd = $HitboxUF
onready var hitbox_fwd = $HitboxF

func _enter():
	dashing = false
	anim_name = "24Karot_U"
	fallback_state = "24Karot_Aerial"
	land_cancel_state = "24Karot_Grounded"
	
	apply_forces_no_limit = false
	
	hitbox_up.activated = true
	hitbox_upfwd.activated = false
	hitbox_fwd.activated = false
	
	dir_x = hitbox_up.dir_x
	dir_y = hitbox_up.dir_y
	
	if data is Dictionary:
		if Utils.int_abs(data.x) == 1 and data.y == 0:
			anim_name = "24Karot_F"
			hitbox_up.activated = false
			hitbox_upfwd.activated = false
			hitbox_fwd.activated = true
			
			dir_x = hitbox_fwd.dir_x
			dir_y = hitbox_fwd.dir_y
			
		elif Utils.int_abs(data.x) == 1 and data.y == -1:
			anim_name = "24Karot_UF"
			hitbox_up.activated = false
			hitbox_upfwd.activated = true
			hitbox_fwd.activated = false
			
			dir_x = hitbox_upfwd.dir_x
			dir_y = hitbox_upfwd.dir_y
		
func _frame_0():
	pass
	
func _frame_3():
	host.apply_x_fric(FRIC)
	host.apply_y_fric(FRIC)
	host.update_data()
	
func _frame_6():
	dashing = true
	
func _frame_8():
	apply_forces_no_limit = true
	
	host.reset_momentum()
	
	var force = fixed.normalized_vec_times(dir_x, dir_y, FORCE)
	host.apply_force_relative(force.x, force.y)
	
func _tick():
#	if current_tick > 10:
#		can_followup = true
#	if host.is_grounded():
#		fallback_state = "24Karot_Grounded"
		pass
		
func can_interrupt():
	return false

func can_land_cancel():
	return .can_land_cancel() and dashing
