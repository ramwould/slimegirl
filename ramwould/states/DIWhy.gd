extends "res://slimegirl/ramwould/states/SlimeState.gd"

const FORWARD_MOMENEMUM = "1.55"

func _enter():
	if host.is_grounded():
		host.reset_momentum()
	host.apply_force_relative("-13.5", "0")
	host.move_directly_relative(-4, 0)

func _frame_3():
	if host.initiative:
		host.start_invulnerability()

func _frame_5():
	host.end_invulnerability()
	
func _frame_7():
	host.apply_force_relative("5", "0")
	host.move_directly_relative(5, 0)

func _tick():
	host.apply_force_relative(FORWARD_MOMENEMUM, "0")
	host.colliding_with_opponent = true
	
	var di = host.opponent.current_di
	if hit_yet and current_tick > 10:
		if sign(di.y) == 0:
			return "DIWhy_DropKick"
			
		elif sign(di.y) == -1 and not host.is_grounded():
			return "DIWhy_DropKick"
			
		elif sign(di.y) == 1 and not host.is_grounded():
			return "DIWhy_Claptrap"
			
		elif sign(di.y) == -1 and host.is_grounded():
			return "DIWhy_DropKick"
			
		elif sign(di.y) == 1 and host.is_grounded():
			return "DIWhy_LowSweep"
			
	if current_tick > 10:
		host.apply_x_fric("0.2")
#		if sign(di.x) == 0:
#			return "DIWhy_DropKick"
#
#		elif sign(di.x) != host.get_facing_int():
#			return "DIWhy_DropKick"
#
#		elif sign(di.x) == host.get_facing_int():
#			return "DIWhy_LowSweep"
		
func _on_hit_something(obj, hitbox):
	._on_hit_something(obj, hitbox)
	if obj is Fighter:
		host.global_hitlag(6, true)
