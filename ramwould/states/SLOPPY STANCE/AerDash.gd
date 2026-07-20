extends "res://slimegirl/ramwould/states/SLOPPY STANCE/SlopState.gd"

const BACKDASH_LAG_FRAMES = 4
const Y_MODIFIER = "0.60"
const MIN_IASA = 0
const MAX_IASA = 14
const MAX_EXTRA_LAG_FRAMES = 5
const COMBO_IASA = 7
const NEUTRAL_MIN_IASA = 11

export  var speed = "2.0"
export  var fric = "0.05"

var starting_y = 0
var startup_lag_frames = 0

func _frame_1():
	spawn_particle_relative(preload("res://fx/DashParticle.tscn"), host.hurtbox_pos_relative_float(), Vector2(data["Air Dash Angle"].x, data["Air Dash Angle"].y))

func _frame_0():
	if data["Stance"]:
		host.change_stance_to("Normal")
		
	var force = xy_to_dir(data["Air Dash Angle"].x, data["Air Dash Angle"].y, speed)
	var dir = xy_to_dir(data["Air Dash Angle"].x, data["Air Dash Angle"].y)
	starting_y = host.get_pos().y
	var back = false
	if host.combo_count > 0:
		starting_iasa_at = COMBO_IASA
	else:
		starting_iasa_at = Utils.int_max(fixed.round(fixed.add(fixed.mul(fixed.vec_len(dir.x, dir.y), str(MAX_IASA - MIN_IASA)), str(MIN_IASA))), NEUTRAL_MIN_IASA)
	iasa_at = starting_iasa_at
	if "-" in force.x:
		if host.get_facing() == "Right" and data["Air Dash Angle"].x != 0:
			back = true
			host.turn_around()
	else:
		if host.get_facing() == "Left" and data["Air Dash Angle"].x != 0:
			back = true
			host.turn_around()
			
	if back and host.combo_count <= 0:
		backdash_iasa = true
		beats_backdash = false

		host.hitlag_ticks += BACKDASH_LAG_FRAMES
		host.add_penalty(5)
	else:
		backdash_iasa = false
		beats_backdash = true


	host.apply_force(force.x, fixed.mul(force.y, Y_MODIFIER) if "-" in force.y else force.y)

func _tick():

	host.apply_x_fric(fric)
	host.apply_forces_no_limit()
	if host.is_grounded():
		if host.combo_count > 0:

			pass
		else:


			host.update_data()
			var vel = host.get_vel()
			if host.get_opponent_dir() != fixed.sign(vel.x):
				host.set_vel(fixed.mul(vel.x, "0.6"), vel.y)




