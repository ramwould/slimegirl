extends "res://slimegirl/ramwould/states/SlimeState.gd"

onready var hitbox = $Hitbox
const ADDITIONAL_FRAMES_FOR_SLOPDROP_LANDING = 4
const LANDING_RECOVERY_FORCE_FALL = 7
const MAX_FALL_SPEED = "20.0"
const MAX_FALL_SPEED_FORCE_FALL = "30.0"
const FORCE_FALL_SPEED = "12.0"

var anti_grav_for = 0
var projectile_invul = false
var interrupted = false
var force_fall = false

func _enter():
	interrupt_into.append_array([
		"Grounded",
		"Aerial",
		])
	anti_grav_for = 0
	projectile_invul = false
	interruptible_on_opponent_turn = false
	interrupted = false
	force_fall = false
	
	if data is bool:
		if not host.is_grounded():
			data = {"force_fall": data}
			
	if data is Dictionary:
		if data.has("projectile_invul"):
			interrupt_into.append("SnagtrikFollowup")
			host.start_projectile_invulnerability()
			projectile_invul = true
		
		if data.has("force_fall"):
			force_fall = data["force_fall"]
			data.merge({
				"no_grav":10,
				})
			
		if data.has("no_grav"):
			anti_grav_for = data["no_grav"]
				
	allow_framecheat = projectile_invul
			
func _exit():
	interrupt_into.clear()
	
func _frame_1():
	if force_fall and not host.noxipaste_this_turn:
		do_force_fall()

func _frame_2():
	if force_fall and host.noxipaste_this_turn:
		do_force_fall()
		
	if anti_grav_for <= 0 and not force_fall:
		host.apply_force_relative("0", "-2")
		
func _frame_5():
	activate_hitbox(hitbox)
	
func _frame_6():
	if projectile_invul:
		interruptible_on_opponent_turn = true
		
func _frame_10():
	host.end_projectile_invulnerability()
	if (projectile_invul) and not interrupted:
		interrupted = true
		enable_interrupt()

func _frame_11():
	interrupt_into.erase("SnagtrikFollowup")
	
func on_interrupt():
	interrupted = true
	interruptible_on_opponent_turn = false
	
func _tick():
	host.update_data()
	var vel = host.get_vel()
	if vel:
		hitbox.dir_x = fixed.mul(vel.x,str(host.get_facing_int()))
		hitbox.dir_y = vel.y
	apply_grav = current_tick > anti_grav_for
		
	land_cancel_state = landing_state()
	if current_tick % 10 == 0:
		host.play_sound("Swish")
	
	if current_tick % 2 == 0 and landing_state()=="SlopdropLanding":
		host.create_speed_after_image( host.color_else_slime("style_2"), Utils.frames(9) )
	
	host.limit_speed(MAX_FALL_SPEED if !force_fall else MAX_FALL_SPEED_FORCE_FALL)
	
func can_land_cancel():
	return .can_land_cancel() and (current_tick > 3 or force_fall)
	
func landing_state():
	landing_recovery = -1
	if (current_tick > hitbox.start_tick+ADDITIONAL_FRAMES_FOR_SLOPDROP_LANDING) or projectile_invul or force_fall:
		landing_recovery = LANDING_RECOVERY_FORCE_FALL-2
		if force_fall:
			landing_recovery = LANDING_RECOVERY_FORCE_FALL
		return "SlopdropLanding"
	return "Landing"

func is_usable():
	return .is_usable() and not host.opponent.blocked_last_turn
	
func do_force_fall():
	host.update_data()
	var vel = host.get_vel()
	var set_speed = FORCE_FALL_SPEED 
	if fixed.ge(vel["y"], FORCE_FALL_SPEED):
		set_speed = vel["y"]
	host.set_vel(vel["x"], set_speed)
	
	host.play_sound("Yank")
	
	
	
	
