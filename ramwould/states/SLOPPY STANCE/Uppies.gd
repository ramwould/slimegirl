extends "res://slimegirl/ramwould/states/SLOPPY STANCE/SlopState.gd"

const LIFT_REDUCTION = "-0.70"

func _on_hit_something(o, h):
	
	if o is Fighter:
		if hit_fighter:
			return
		if not host.is_grounded():
			host.update_data()
			host.set_vel(host.get_vel().x, fixed.mul(h.knockback,LIFT_REDUCTION))
			host.set_grounded( false )

	._on_hit_something(o, h)
