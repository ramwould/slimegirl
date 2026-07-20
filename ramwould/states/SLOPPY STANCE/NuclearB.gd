extends "res://slimegirl/ramwould/states/SLOPPY STANCE/SlopState.gd"

func _frame_2():
	started_in_air = not host.is_grounded()
	if started_in_air:
		host.apply_force_relative("-2.0", "-3.0")
	
	else:
		host.apply_force_relative("-3.0", "0.0")
	
func _frame_5():

	if started_in_air:
		host.apply_force_relative("10.0", "0.0")
		
	else:
		host.apply_force_relative("16.0", "-3.0")
		if host.reverse_state:
			host.add_penalty( 6 )
			
func _tick():
	host.apply_forces_no_limit()
	host.limit_x_speed("20.0")
	if host.is_grounded():
		host.apply_fric()
		
func _on_hit_something(o, h):
	._on_hit_something(o, h)
	
	host.update_data()
	host.set_vel("0.0", host.get_vel().y)
	host.apply_force_relative("-2.0", "-2.0")
	host.move_directly_relative(6, -8)
		
	host.block_pulse()
