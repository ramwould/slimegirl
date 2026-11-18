extends ThrowState

func _frame_0():
#	._frame_0()
	
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
	
#	var center = Vector2(host.opponent.hurtbox.width, host.opponent.hurtbox.height)/2
	var centerx = fixed.div(str(host.opponent.hurtbox.width), "2")
	var centery = fixed.div(str(host.opponent.hurtbox.height), "2")
	
#	var to_lerp = lerp(from_pos, to_pos, host.snag_length_ratio)+center
	var to_lerpx = fixed.add(fixed.lerp_string(str(from_pos.x), str(to_pos.x), str(host.snag_length_ratio)), centerx)
	var to_lerpy = fixed.add(fixed.lerp_string(str(from_pos.y), str(to_pos.y), str(host.snag_length_ratio)), centery)
	
	host.opponent.set_pos(to_lerpx, to_lerpy)

func _tick():
	if host.snag_length_ratio <= 0:
		return fallback_state

