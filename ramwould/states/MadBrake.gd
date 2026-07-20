extends CharacterState

const MIN_STOP_SPEED = "1.75"

func _enter():			
	host.play_sound("Slimebrake")

func _exit():
	host.stop_sound("Slimebrake")

func _tick():
	host.apply_grav()
	host.apply_fric()
	host.apply_fric()
	
	host.apply_forces()
	
	host.update_data()
	var current_vel = host.get_vel()
	if current_vel:
		if fixed.lt(fixed.abs(current_vel.x), MIN_STOP_SPEED):
			host.update_facing()
			queue_state_change("MadDash")

