extends "res://slimegirl/ramwould/states/SLOPPY STANCE/SlopState.gd"

func _tick():
	if current_tick <= 5:
		host.apply_fric()
		
	else:
		if host.is_grounded():
			return "DiverBomb_Landing"
			
	host.apply_forces_no_limit()
	
func _frame_2():
#	host.reset_momentum()
	pass
	
func _frame_5():
	host.play_sound("Yank")
	if data:
		var dir = {x="1.0", y="1.9"}
		if data.x == host.get_facing_int() and data.y == 0:
			dir = {x="1.9", y="1.0"}
		if data.x == host.get_facing_int() and data.y == 1:
			dir = {x="1.0", y="1.0"}
		dir = fixed.normalized_vec_times(dir.x, dir.y, "19")
		
		host.reset_momentum()
		host.apply_force_relative(dir.x, dir.y)
		var hitbox_dir = fixed.normalized_vec(dir.x, dir.y)
		for box in all_hitbox_nodes:
			(box as Hitbox).dir_x = hitbox_dir.x
			(box as Hitbox).dir_y = hitbox_dir.y
