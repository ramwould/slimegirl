extends "res://slimegirl/ramwould/states/SlimeState.gd"

#	!! DO NOT CHANGE !!
const DISTANCE_TO_SPEED_DIV = "22.5"
const JUMP_SPEED = "-7.5"

const MIN_CATCH_DISTANCE = "50"
const JUMP_SCENE = preload("res://fx/JumpParticle.tscn")

func _frame_0():
#	host.reset_momentum()
	var opponent_distance = distance_from_opponent_center()
	var x_speed = fixed.div(opponent_distance, DISTANCE_TO_SPEED_DIV)
	
	host.apply_force_relative(x_speed, JUMP_SPEED)
	spawn_particle_relative(JUMP_SCENE, Vector2.ZERO, Vector2( float(x_speed)*host.get_facing_int(), float(JUMP_SPEED) ))
	
func _on_land_cancel():
	._on_land_cancel()
	if land_cancel_state == "Tumble":
		host.apply_force_relative(5, -3)

		
func _tick():
	var opponent = host.opponent
	var opponent_distance = distance_from_opponent_center()
	
	land_cancel_state = "Tumble"
	if fixed.le(opponent_distance, MIN_CATCH_DISTANCE) and opponent.is_otg() and host.object_on_trail(opponent):
		land_cancel_state = "Goodrider_Skate"
		
	if opponent.is_otg():
		opponent.current_state().current_tick = 0
	
	if current_tick % 2 == 0:
		host.create_speed_after_image( host.color_else_slime("style_2"), Utils.frames(9) )

func distance_from_opponent_center():
	var opponent = host.opponent
	
	var my_pos = host.get_hurtbox_center_float()
	var obj_pos = opponent.get_hurtbox_center_float()
	
	return fixed.vec_dist(str(my_pos.x), str(my_pos.y), str(obj_pos.x), str(obj_pos.y))
