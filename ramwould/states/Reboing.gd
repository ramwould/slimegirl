extends "res://slimegirl/ramwould/states/SlimeState.gd"

var force_x = "0"
var force_y = "0"
export var speed = "0"
export var x_modifier = "1"
export var y_modifier = "1"
export var x_speed_preserved = "0.5"
export var snagtrik = false

func _enter():
	var dir_x = "0.5"
	var dir_y = "-0.6"
	if data is Dictionary:
		
		if data.x == 0 and data.y == -1:
			dir_x = "0.3"
			dir_y = "-1"
		if abs(data.x) == 1 and data.y == -1:
			dir_x = "0.85"
			dir_y = "-0.88"
		if abs(data.x) == 1 and data.y == 0:
			dir_x = "1"
			dir_y = "-0.6"
		if abs(data.x) == 1 and data.y == 1:
			dir_x = "0.85"
			dir_y = "0.88"
			
	force_x = fixed.mul(fixed.mul(dir_x, speed), x_modifier)
	force_y = fixed.mul(fixed.mul(dir_y, speed), y_modifier)
	if !snagtrik:
		host.start_throw_invulnerability()

func _frame_0():
	if snagtrik:
		interruptible_on_opponent_turn = host.initiative
	
func _frame_3():
	jump()
	
func _frame_4():
	if host.initiative and not snagtrik:
		host.start_aerial_attack_invulnerability()

func _frame_16():
	host.end_aerial_attack_invulnerability()
	
func jump():
	host.end_throw_invulnerability()
	host.update_data()
	var vel = host.get_vel()
	host.set_grounded(false)
	
	var y_vel = "0"
	if snagtrik:
		y_vel = fixed.div(vel.y, "2")
	host.set_vel(fixed.mul(vel.x, x_speed_preserved), y_vel)
	
	spawn_particle_relative(particle_scene, Vector2(), Vector2(float(force_x), float(force_y)))
	host.end_throw_invulnerability()
	host.apply_force_relative(force_x, force_y)
	
#	if sign(float(force_x)*host.get_facing_int()) != host.get_opponent_dir():
#		host.add_penalty( 8 )
	
func can_land_cancel():
	if snagtrik:
		return .can_land_cancel()
	return current_tick > 3 and .can_land_cancel()
	
func _tick():
	if current_tick % 2 == 0:
		host.create_speed_after_image( host.color_else_slime("style_2"), Utils.frames(9) )

