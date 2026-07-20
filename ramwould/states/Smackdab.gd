extends "res://slimegirl/ramwould/states/SlimeState.gd"

const SPEED_LIMIT = "15"

func _enter():
	self_interruptable = false

func step(walk = 0):
	host.apply_force_relative(5, 0)
	host.move_directly_relative(6, 0)
	if walk > 0:
		host.play_sound("SpongeWalk_%s" % walk)

func _frame_0():
	host.apply_force_relative(9, 0)
	
func _frame_2():
	if host.initiative:
		host.has_projectile_armor = true
	if host.reverse_state and host.combo_count <= 0:
		host.add_penalty(20)
		
func _frame_7():
	step(1)
	
func _frame_10():
	host.has_projectile_armor = false
	self_interruptable = true
	
func _frame_15():
	step(2)
	
func _exit():
	host.has_projectile_armor = false

func _tick():
	host.apply_forces_no_limit()
	host.limit_speed(SPEED_LIMIT)
