extends "res://slimegirl/ramwould/states/SlimeState.gd"

export var snagtrik_followup = false

func _frame_0():
	endless = not started_in_air
	apply_grav = true

func _frame_2():
	if snagtrik_followup and host.initiative:
		apply_grav = false
		host.start_projectile_invulnerability()
		
func _frame_3():
	if snagtrik_followup:
		host.update_data()
		host.set_vel(fixed.div(host.get_vel().x, "2"), "0")
		host.apply_force_relative("9.0", "0")
		
func _frame_5():
	if not snagtrik_followup:
		host.apply_force_relative("8", "-4")

func _tick():
	host.colliding_with_opponent = true
	if current_tick > 5 and host.is_grounded():
		return "Landing"

	if snagtrik_followup:
		host.limit_speed("20")
		if current_tick % 2 == 0 and !apply_grav:
			host.create_speed_after_image( host.color_else_slime("style_2"), Utils.frames(9) )

func _frame_13():
	if snagtrik_followup:
		apply_grav = true

func _frame_25():
	host.end_projectile_invulnerability()
		
func _on_hit_something(obj, hitbox):
	._on_hit_something(obj, hitbox)
	
	host.play_sound("GroundSlam")
	
	if (obj is Fighter) and snagtrik_followup:
		host.enable_beam_charge()
