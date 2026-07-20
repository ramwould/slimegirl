extends "res://slimegirl/ramwould/states/SLOPPY STANCE/SlopState.gd"

const JUMP_POWER = "-7.0"

func _frame_2():
	if data:
		host.update_data()
		var vel = host.get_vel()
		
		if fixed.ge(vel.y, JUMP_POWER):
			host.set_vel( host.get_vel().x, JUMP_POWER)
			
func _on_hit_something(o, h):
	
	if o is Fighter:
		if o.is_grounded():
			host.update_data()
			host.set_vel(host.get_vel().x, "-3.0")
			host.set_grounded( false )

	._on_hit_something(o, h)
