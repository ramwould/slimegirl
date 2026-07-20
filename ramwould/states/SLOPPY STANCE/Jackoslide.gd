extends "res://slimegirl/ramwould/states/SLOPPY STANCE/SlopState.gd"

const MIN_SPEED = "4.5"
onready var ref_hitbox = $HitboxStart

func _frame_2():
	host.reset_momentum()
	
func _frame_7():
	host.apply_force_relative("23.0", "0.0")
	host.play_sound("IntroBarrelExplosion")
	if host.initiative:
		host.start_projectile_invulnerability()
	host.colliding_with_opponent = false
	
func _frame_16():
	host.end_projectile_invulnerability()
	
func _tick():
	host.apply_forces_no_limit()
	
	if not host.on_slimetrail_this_state:
		host.apply_fric()
		
	else:
		if host.is_grounded():
			if host.increased_friction:
				host.apply_x_fric("0.18")
			else:
				host.apply_x_fric("0.11")
				
	host.update_data()	
	var x_vel = host.get_vel().x
	if fixed.lt(fixed.abs(x_vel), MIN_SPEED) and current_tick > ref_hitbox.start_tick+2:
		return fallback_state

func on_got_perfect_parried():
	.on_got_perfect_parried()
	host.apply_x_fric("0.33")
	queue_state_change(fallback_state)
	
func on_got_blocked():
	.on_got_blocked()
	host.apply_x_fric("0.33")
	queue_state_change(fallback_state)

func can_interrupt():
	.can_interrupt()
	
	return false
