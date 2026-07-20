extends ThrowState

func _enter():
	._enter()
	host.opponent.current_state().anim_name = "Grabbed"

func _frame_25():
	
	host.tween_camera_zoom(0.80, 0.99, 0.6, Tween.TRANS_BACK, Tween.EASE_OUT)
	host.release_camera_focus()
