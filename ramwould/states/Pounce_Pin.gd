extends ThrowState

const SPEED_THRESHOLD = "5.30"

func _frame_0():
	host.tween_camera_zoom(0.99, 0.80, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	fallback_state = "Pounce_ThrowSlow"
	
	host.update_data()
	var vel = host.get_vel()
	if vel:
		if fixed.ge(fixed.abs(vel.x), SPEED_THRESHOLD) and not host.has_carrotmine() and not host.increased_friction:
			fallback_state = "Pounce_ThrowFast"
			
func _tick():
	host.apply_forces_no_limit()
