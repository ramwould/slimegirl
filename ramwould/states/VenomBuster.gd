extends "res://slimegirl/ramwould/states/SlimeState.gd"

var dir_x = "0"
var dir_y = "0"
#var early_interrupt = false

const JUMP_POWER = "-5"
const X_FACTOR = "1"

onready var beam1 = $BeamHitbox

func is_usable():
	return .is_usable() and host.venobuster_ticks <= 0
	
func _enter():
#	interruptible_on_opponent_turn = false
	var x_power = fixed.div(str(data.x), "10")
	dir_x = fixed.mul(x_power, X_FACTOR)
	dir_y = JUMP_POWER
	
#	var vec02 = xy_to_dir(data.x, data.y)
#	early_interrupt = fixed.le(fixed.vec_len_squared(vec02.x, vec02.y), "0.5")
	beam1.beam_direction.x = -float(dir_x)*host.get_facing_int()*0.25
	if host.combo_count <= 0:
		beam1.beam_direction.x = 0
		
	beam1.beam_direction.y = -float(dir_y)

func on_beam_shot():
	var jump_force_y = dir_y
	host.apply_force(dir_x, jump_force_y)
	host.venobuster_ticks = host.MAX_VENOBUSTER_COOLDOWN

#func _frame_10():
#	if not early_interrupt:
#		interruptible_on_opponent_turn = true
	
func can_interrupt():
	return false

#func on_got_perfect_parried():
#	.on_got_perfect_parried()
#	early_interrupt = false

