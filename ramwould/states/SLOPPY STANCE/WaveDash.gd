extends "res://slimegirl/ramwould/states/SLOPPY STANCE/SlopState.gd"

const SPEED_FORWARD = "14.0"
const SPEED_BACKWARD = "-8.0"

func _frame_0():
	if data is Dictionary:
		backdash_iasa = (data["Direction"].x != host.get_opponent_dir())
		if data["Stance"]:
			host.change_stance_to("Normal")
			
	if host.initiative and not backdash_iasa:
		host.start_projectile_invulnerability()
		
	if backdash_iasa:
		host.start_throw_invulnerability()
		anim_name = "WaveDash_Backward"
	else:
		anim_name = "WaveDash_Forward"
		
func _frame_1():
	host.reset_momentum()	
	var dir_force = SPEED_FORWARD
	if backdash_iasa:
		dir_force = SPEED_BACKWARD
		
	else:
		host.colliding_with_opponent = false
		
	if host.stance == "Normal":
		dir_force = fixed.mul(dir_force, "1.5")
		
	host.apply_force_relative(dir_force, "0.0")
	
func _frame_7():
	host.end_projectile_invulnerability()
	host.end_throw_invulnerability()
	
func _tick():
	host.apply_forces_no_limit()
	host.limit_speed("22.0")
	
	if current_tick > 1:
		host.apply_fric()
		host.apply_fric()
