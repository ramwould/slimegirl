extends ThrowState

const MIN_IASA_SPEED = "7.0"
var interrupted = false

func _enter():
	._enter()
	interrupted = false
	host.opponent.sprite.hide()
	
func _tick():
	host.apply_forces_no_limit()
#	apply_custom_x_fric = host.is_grounded()
	
	host.update_data()
	var vel = host.get_vel()
	if vel:
		if fixed.lt(fixed.abs(vel.x), MIN_IASA_SPEED) and !interrupted and host.is_grounded():
			queue_state_change(fallback_state)
			interrupted = true

func _exit():
	._exit()
	host.opponent.sprite.show()
	host.opponent.current_state().anim_name = "Knockdown"
