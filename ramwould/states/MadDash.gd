extends CharacterState

const MAX_SPEED = "20"
const MAX_GO_SPEED = "2.5"
const COMBO_IASA = 12

export var accel = "0"
export var burst_speed = "0"

var walkvar = 2

func play_enter_sfx():
	if not same_as_last_state:
		.play_enter_sfx()

func _enter():
	iasa_at = -1
	
	if not host.sprite.is_connected("frame_changed", self, "on_sprite_frame_changed"):
		host.sprite.connect("frame_changed", self, "on_sprite_frame_changed")
		
	host.update_data()
	var current_vel = host.get_vel()
	if current_vel:
		if fixed.sign(current_vel.x) != host.get_facing_int() and fixed.gt(fixed.abs(current_vel.x), MAX_GO_SPEED) and _previous_state_name() != "MadBrake":
			queue_state_change("MadBrake")
			return
			
		if not same_as_last_state and fixed.lt(fixed.abs(current_vel.x), burst_speed):
			host.set_vel(fixed.mul(burst_speed, str(host.get_facing_int())), current_vel.y)

func _frame_0():
	if host.combo_count > 0:
		iasa_at = COMBO_IASA
	
func on_sprite_frame_changed():
	if not active:
		return 
	if walkvar == 2:
		walkvar = 1
	else:
		walkvar = 2
	
	if host.sprite.frame == 1:
		host.play_sound("SpongeWalk_%s" % walkvar)
		.spawn_enter_particle()
		
func get_hold_restart():
	return state_name

func _tick():
	host.apply_grav()
	host.apply_forces_no_limit()
	host.apply_force_relative(accel, "0")
	host.limit_speed(MAX_SPEED)

