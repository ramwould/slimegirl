extends "res://slimegirl/ramwould/states/SlimeState.gd"

const BACKWARDS_LUNGE_BOOST_THRESHOLD = "2.0"
const BACKWARDS_LUNGE_BOOST_MOD = "3.2"

var got_blocked = false
var lunge_boost_possible = true
var x_vel_on_enter

export var x_force = "3.0"

func _enter():
	apply_fric = true
	got_blocked = false
	lunge_boost_possible = false
	
	host.update_data()
	var vel = host.get_vel()
	x_vel_on_enter = vel.x
	if (fixed.sign(x_vel_on_enter) == -host.get_facing_int() and fixed.ge(fixed.abs(x_vel_on_enter), BACKWARDS_LUNGE_BOOST_THRESHOLD)):
		lunge_boost_possible = true
	
func _frame_2():
	if host.initiative:
		host.start_projectile_invulnerability()
	host.apply_force_relative("2", "0")
	
func _frame_6():
	apply_fric = false

	var x_speed = x_force
	if lunge_boost_possible:
		host.reset_momentum()
		host.global_hitlag(3, false)
		host.play_sound("IntroBarrelExplosion")
		x_speed = fixed.mul(x_speed, BACKWARDS_LUNGE_BOOST_MOD)
		if host.initiative:
			host.start_grounded_attack_invulnerability()
			
	host.colliding_with_opponent = false
	host.opponent.colliding_with_opponent = false
	host.apply_force_relative(x_speed, "-3.8")

func _frame_10():
	host.end_grounded_attack_invulnerability()
	
func _frame_19():
	host.end_projectile_invulnerability()

func _tick():
	host.apply_forces_no_limit()
	
	land_cancel_state = "Tumble"
	if got_blocked:
		land_cancel_state = "Landing"
		host.colliding_with_opponent = true
		host.opponent.colliding_with_opponent = true
		
func on_got_blocked():
	got_blocked = true
	lunge_boost_possible = false
	
func on_got_hit():
	lunge_boost_possible = false
	
func on_got_perfect_parried():
	lunge_boost_possible = false
	
func is_usable():
	if not .is_usable():
		return false
		
	var cur_state = host.current_state().state_name
	if cur_state == "MadDash" or cur_state == "MadBrake" or cur_state == "SlopdropLanding" or cur_state == "Landing":
		return true
	var prev :CharacterState= _previous_state()
	if prev:
		if prev.started_in_air and host.is_grounded() and !got_blocked:
			return true
			
	return false
