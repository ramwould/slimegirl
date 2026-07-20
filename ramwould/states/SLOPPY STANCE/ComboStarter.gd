extends "res://slimegirl/ramwould/states/SlimeState.gd"

const ACCEL = "1.3"
const SPEED_FORWARD = "18.0"
const SPEED_BACK = "-13.0"
const SPEED_CAP_WEAVE = "1.5"

var dir = 0
var passed_opponent = false

func _enter():
	dir = data.x
	passed_opponent = false
	
func _frame_2():
	if host.is_grounded():
		host.reset_momentum()
		fallback_state = "Jab"
		
	else:
		fallback_state = "Uppies"
		
	var dir_force = SPEED_BACK
	if dir == host.get_opponent_dir():
		dir_force = SPEED_FORWARD
		host.colliding_with_opponent = false
	host.apply_force_relative(dir_force, "0.0")
	
	if host.initiative:
		host.start_invulnerability()

func _frame_7():
	host.end_invulnerability()
	
func _tick():
	var dir_accel = ACCEL
#	unintentional side effect causing her to WEAVE, lets keep it in >:)
	if dir == host.get_opponent_dir():
		dir_accel = "-"+ACCEL
		
	else:
		if not passed_opponent:
			passed_opponent = true
			
	var the_LIMIT = SPEED_CAP_WEAVE if passed_opponent else SPEED_FORWARD

	host.apply_force_relative(dir_accel, "0.0")
	
	if current_tick > 2:
		host.update_data()
		host.limit_x_speed(the_LIMIT)
		if current_tick % 2 == 0:
			host.create_speed_after_image(host.color_else_slime(), Utils.frames(8))
