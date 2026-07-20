extends ThrowState

export var skating = false
export var kickflip = false
export var intro = false

var started_skating = false
var started_kickflip = false
var slammed_into_wall = false

const MAX_SPEED = "25"
const ACCEL = "0.6"
const HIT_INTERVAL = 5
	
func _enter():
	._enter()
	started_skating = false
	started_kickflip = false
	slammed_into_wall = false
	
#	if host.reverse_state:
#		host.turn_around()
		
#	if (data is bool):
#		if data: host.turn_around()
		
func _frame_0():

		
	var opp = host.opponent
	if skating or kickflip:
		anim_name = "Goodrider_Landing"
		
	if intro:
		opp.current_state().anim_name = "Grabbed"
		
	if skating:
		opp.current_state().anim_name = "Knockdown"
	
	if kickflip:
		opp.current_state().anim_name = "Grabbed"
		
func _frame_4():
	if skating:
		anim_name = "Goodrider_Skate"
		started_skating = true
		host.apply_force_relative(2, 0)
	
	if kickflip:
		anim_name = "Goodrider_Kickflip"
		started_kickflip = true
		host.apply_force_relative(0, -5)
		
func _tick():
	if skating:
		if started_skating:
			host.apply_forces_no_limit()
			for hb in get_children():
				if hb is Hitbox:
					if current_real_tick % HIT_INTERVAL == 0:
						hb.hit(host.opponent)
						hb.deactivate()
						spawn_particle_relative(preload("res://fx/HitEffect1.tscn"), Vector2(10, -5))
						host.apply_force_relative(ACCEL, "0")
						
			host.limit_x_speed(MAX_SPEED)
#			if not host.object_on_trail(host):
#				host.apply_fric()
			
			var wall = host.touching_which_wall()
			host.update_data()
			if wall == fixed.sign(host.get_vel().x):
				var opp = host.opponent
				opp.current_state().anim_name = "Grabbed"
				
				queue_state_change("TumbleSplat", CharacterHurtState.BOUNCE.LEFT_WALL if wall == - 1 else CharacterHurtState.BOUNCE.RIGHT_WALL)
				_release()
				
				slammed_into_wall = true
				return
				
			if current_tick % 2 == 0:
				host.create_speed_after_image( host.color_else_slime("style_2"), Utils.frames(9) )
		else:
			host.apply_forces()
		
		
	elif kickflip:
		host.apply_forces()
		if started_kickflip:
			host.apply_fric()
			
	else:
		host.apply_forces()

func _exit():
	._exit()
	if (not slammed_into_wall and skating) or (not skating):
		var opp = host.opponent
		if opp.current_state().state_name == "Grabbed":
			opp.current_state().anim_name = "Grabbed" if kickflip else "Knockdown"

