extends CharacterState

export var _c_posion_data = 0
export(float, 0.0, 4.0, 0.05) var poison_percent = 1.00
export var apply_poison_on_block = false
export var poison_percent_on_block = "1.0"
export var increased_poison_on_trail = false
export var pause_poison_this_state = false

export var _c_beam_data = 0
export var beam_x = 0
export var beam_y = 0
var beam_hitbox_nodes = []
var parried_this_turn = false

export var _c_extra_data = 0
export var ignore_copybuny_land_cancel = false
export var can_hold_into_helix_beam = true
export var only_extreme_turbo = false
export var extra_parrylag_with_distance = false

var animation_tick = 0

const REVERSE_BRAKE = "0.80"

func _enter_shared():
	._enter_shared()
	animation_tick = 0
	
	parried_this_turn = false
	
	host.pause_poison_ticks = pause_poison_this_state
	
	for hitbox in get_children():
		if hitbox is SweptHitbox:
			if not hitbox.get("IS_BEAM"):
				continue
			beam_hitbox_nodes.append(hitbox)

func _exit_shared():
	._exit_shared()
	beam_hitbox_nodes.clear()
	host.pause_poison_ticks = false
	
func _frame_0_shared():
	._frame_0_shared()
	
	if host.reverse_state and host.on_slimetrail_this_state and not host.increased_friction:
		host.update_data()
		var vel = host.get_vel()
		if vel:
			host.set_vel(fixed.mul(vel.x,REVERSE_BRAKE), vel.y)
	
	
func _tick_shared():
	animation_tick+=1
	for hitbox in beam_hitbox_nodes:
		if current_tick == hitbox.start_tick-3 and can_beam_spawn():
			on_beam_shot()
			host.spawn_basic_beam(get_beam_spawn_position().x, get_beam_spawn_position().y, hitbox)
	
	._tick_shared()
	
	if extra_parrylag_with_distance:
		extra_parry_hitlag = int(host.distance_to(host.opponent)) / 14
		
func can_land_cancel():
	if not ignore_copybuny_land_cancel:
		if air_type != CharacterState.AirType.Both:
			return not host.noxipaste_this_turn
	return .can_land_cancel()

func get_beam_spawn_position()->Vector2:
	return Vector2(beam_x, beam_y)
	
func can_beam_spawn()->bool:
	return not parried_this_turn

func on_got_perfect_parried():
	parried_this_turn = true
	
func on_beam_shot():
	pass

func is_usable():
	if only_extreme_turbo:
		return .is_usable() and host.extremely_turbo_mode
	return .is_usable()


