extends "res://slimegirl/ramwould/states/SlimeState.gd"

var is_hustle = true

func _enter():
	_set_status()
	
func _frame_7():
	host.apply_force_relative("2.0", "0.0")
	
func _frame_33():
	host.apply_force_relative("-2.0", "0.0")
	host.move_directly_relative(-9, 0)

func _frame_40():
	host.play_sound("SpongeWalk_1")
	
func _frame_44():
	if is_hustle:
		host.gain_super_meter_raw(host.MAX_SUPER_METER)
		host.unlock_achievement("ACH_HUSTLE", true)

func _on_hit_something(obj, hitbox):
	._on_hit_something(obj, hitbox)
	if (obj is Fighter) and is_hustle:
		host.achiev_counter("landed_hustle")
		host.unlock_achiev("achivement_hustle")

func _set_status():
	is_hustle = not host.has_carrotmine()
	if is_hustle:
		iasa_at = -1
		interruptible_on_opponent_turn = true
		next_state_on_hold = false
		
	else:
		iasa_at = 25
		interruptible_on_opponent_turn = false
		next_state_on_hold = true

func get_last_action_text():
	if not is_hustle:
		return "Detonated Carrot"
	return .get_last_action_text()
