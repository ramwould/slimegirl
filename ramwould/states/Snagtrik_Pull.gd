extends ThrowState

func _enter():
	._enter()
	
	host.grab_camera_focus()
	host.enable_beam_charge()
	host.reset_goop( true )
	
func _exit():
	._exit()
	
	host.release_camera_focus()
	host.stick_goop_to_obj(host.opponent, true)
	if host.randi_percent_static(33):
		host.play_sound("Cat")
		
func _tick_after():
	._tick_after()
	var from_pos = host.get_hurtbox_center_float()
	var to_pos = Vector2(host.snag_pos_global_x, host.snag_pos_global_y)
	var center = Vector2(host.opponent.hurtbox.width, host.opponent.hurtbox.height)/2
	var to_lerp = lerp(from_pos, to_pos, host.snag_length_ratio)+center
	
	host.opponent.set_pos(str(to_lerp.x), str(to_lerp.y))

func _tick():
	if host.snag_length_ratio <= 0:
		return fallback_state

