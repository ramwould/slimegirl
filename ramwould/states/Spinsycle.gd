extends "res://slimegirl/ramwould/states/SlimeState.gd"

const MAX_DISTANCE_COMBO = "75"
const MAX_DISTANCE_NEUTRAL = "150"
const FORCE = "5"
const MAX_DISTANCE_STALL = 3

var stall_frames = 0

func _tick():
	if current_tick > 5:
		host.apply_fric()
		host.apply_grav()
	
func _enter():
	interruptible_on_opponent_turn = false
	
	stall_frames = 0

	var stall_value_with_distance = fixed.lerp_string("0", "1", fixed.div( get_x_distance(), MAX_DISTANCE_NEUTRAL ))
	stall_frames += int(float(stall_value_with_distance)*MAX_DISTANCE_STALL)
	
func _frame_0():
	pass

func _frame_2():
	if stall_frames > 0:
		current_tick -= 1
		stall_frames -= 1
	
func _frame_3():
	var old_position = host.get_pos_visual()
	host.reset_momentum()
	
	host.move_directly_relative(get_x_distance(), "0")
	host.apply_force_relative(FORCE, "0")
	host.update_data()
	
	var IMAGE_COUNT:float = 6
	for i in IMAGE_COUNT:
		var aftertrail_pos = lerp(host.to_local(old_position), host.to_local(host.get_pos_visual()), i / IMAGE_COUNT)
		aftertrail_pos.x *= -1
		var color:Color = host.color_else_slime("style_2")
		color.a = 0.7
		host.create_speed_after_image(color, Utils.frames(11), aftertrail_pos)
		
func get_x_distance():
	var pos = host.get_pos()
	var opp_pos = host.opponent.get_pos()
	var x_dist = str(abs(opp_pos.x - pos.x))
	if fixed.gt(x_dist,MAX_DISTANCE_NEUTRAL):
		x_dist = MAX_DISTANCE_NEUTRAL
	return x_dist

func _on_hit_something(obj, hitbox):
	._on_hit_something(obj, hitbox)
	
	interruptible_on_opponent_turn = true
