extends "res://slimegirl/ramwould/states/SlimeState.gd"

#SNAGTRIK
#SNAGTRIK
#SNAGTRIK

export var extend_tick = 0
export var extend_time = 0
export var syringe_all_round = false

var pos_x = "0"
var pos_y = "0"
var saved_radius_center_x:int = 0
var saved_radius_center_y:int = 0
var can_bash = false
var influence_x = "0"
var influence_y = "0"

const BASH_TICKS = 20
const BASH_Y_MODIFIER = "0.66"
const AURA_DIVISOR = "5.0"

onready var hitboxGB = $Guardbreak
onready var hitbox = $Hitbox

func is_usable():
	if not .is_usable(): return false
	
	if any_cooldown(): return false
		
	if not is_projectile(): return true
				
	return false
	
func copy_to(s):
	.copy_to(s)
	s.pos_x = pos_x
	s.pos_y = pos_y
	s.saved_radius_center_x = saved_radius_center_x
	s.saved_radius_center_y = saved_radius_center_y
	s.can_bash = can_bash
	
func _frame_0():
	pos_x = "0"
	pos_y = "0"
	can_bash = false
	if data is Dictionary:
		if data.has("x"):
			var vec01 = xy_to_dir(data.x, data.y, host.current_radiation_radius)
			pos_x = vec01.x
			pos_y = vec01.y
		if data.has("Position"):
			var vec01 = xy_to_dir(data["Position"].x, data["Position"].y, host.current_radiation_radius)
			pos_x = vec01.x
			pos_y = vec01.y
			
			var di_infl = xy_to_dir(host.current_di.x, host.current_di.y, "1.0")
			influence_x = di_infl.x
			influence_y = di_infl.y
	hitbox.activated = true
	hitboxGB.activated = true
			
func set_saved_snag_position():
	var main = host
	main.update_data()
	saved_radius_center_x = host.radius_center().x+get_current_vel_position(main).x
	saved_radius_center_y = host.radius_center().y+get_current_vel_position(main).y
	
func get_saved_snag_position()->Vector2: return Vector2(int(saved_radius_center_x), int(saved_radius_center_y)) 
	
func get_local_aimed_position()->Vector2: return Vector2(int(pos_x), int(pos_y))

func get_current_vel_position(obj:BaseObj)->Dictionary:
	obj.update_data()
	return {
		"x":int(obj.get_vel().x),
		"y":int(obj.get_vel().y),
		}

func is_projectile()->bool:
	return host.lassail_projectile() and host.lassail_connected()
	
func _tick():
	var main = host
	var pos = get_saved_snag_position()
	var vec = get_local_aimed_position()
	
	if current_tick == extend_tick-1:	
		set_saved_snag_position()

		pos = get_saved_snag_position()
		vec = get_local_aimed_position()
		
		var combined_vec = vec+pos
		host.snagtrik_extend(extend_time, combined_vec)

	host.apply_grav()
		
	var hitbox_pos = host.to_local(vec)+pos
	for node in get_children():
		if node is CollisionBox:
			if host.turn_frames > 1:
				node.x = hitbox_pos.x * host.get_facing_int()
				node.y = hitbox_pos.y

		if node is Hitbox:				
			main.update_data()
			
#			var dir = main.obj_local_center(host.opponent)
			var dir = fixed.normalized_vec(pos_x, pos_y)
			node.dir_x = fixed.mul( str(dir.x), str(host.get_facing_int()) )
			node.dir_y = str(dir.y)
		
			if node.hitbox_type == Hitbox.HitboxType.Detect:
				if host.air_movements_left <= 0:
					continue
					
				if not node.enabled:
					continue
					
				for opp_hitbox in host.opponent.get_active_hitboxes():
					var opp :BaseObj= opp_hitbox.host
					
#					for snagging another snaghook
					if (opp == host.opponent) and node.overlaps(opp_hitbox) and opp_hitbox.hitbox_type == Hitbox.HitboxType.Detect:
						if opp.get("charname") and opp.charname == "Slimegirl" and opp.current_state().state_name == state_name:
							slimegirl_bash(opp)
							return
					
				for obj in host.objs_map.values():
					if (obj is BaseObj) and not (obj is Fighter):
						if not obj.disabled and node.overlaps(obj.hurtbox):
							slimegirl_bash(obj)
							return
		
func slimegirl_bash(hit_obj:BaseObj, selfSnag=false):
	hitbox.activated = false
	hitboxGB.activated = false
	
	var bash_fighter = false
	if (hit_obj is Fighter):
		bash_fighter = true
		
	if hit_obj is BaseProjectile:
		if (not hit_obj.movable or hit_obj.invulnerable) and hit_obj.id != host.id:
			return
	
	if hit_obj.get_hurtbox_center().y > 0: return
	
	host.spooderman_tracker += 1
	host.play_sound("SlimebashCatch")
	host.use_air_movement()
	
	var hitlag = 9
	if not bash_fighter:
		host.add_penalty(5)
		host.global_hitlag(hitlag)
		hit_obj.hitlag_ticks += BASH_TICKS
	
	host.screen_bump(Vector2(), 13.0, Utils.frames(hitlag))
	
	var obj_vec = host.get_object_dir_vec(hit_obj)
	var pull_force = fixed.div( fixed.vec_len(pos_x,pos_y), AURA_DIVISOR)
	var obj_force = fixed.normalized_vec_times(obj_vec.x, obj_vec.y, pull_force)
	if fixed.lt(obj_force.y,"0"):
		obj_force.y = fixed.mul(obj_force.y,BASH_Y_MODIFIER)
	var force = fixed.vec_add(obj_force.x, obj_force.y, "0", "-5")
	
	if not (influence_x == "0" and influence_y == "0"):
		var opposing_force = fixed.div( fixed.vec_len(pos_x,pos_y), fixed.mul(AURA_DIVISOR,"3") )
		var opposing_dir = fixed.normalized_vec_times(influence_x, influence_y, opposing_force)
		if fixed.lt(opposing_dir.y,"0"):
			opposing_dir.y = fixed.mul(opposing_dir.y, BASH_Y_MODIFIER)
			
		force = fixed.vec_add(force.x, force.y, opposing_dir.x, opposing_dir.y)
	
	if bash_fighter:
		force = fixed.vec_div(force.x, force.y, "2")
		
	if fixed.sign(force.x) != host.get_opponent_dir():
		host.add_penalty(10)
		
	host.snag_cooldown = 0
	
	queue_state_change("Slopdrop", {"projectile_invul":true, "no_grav":BASH_TICKS})
	host.reset_momentum()
	host.apply_force(force.x, force.y)
	host.play_sound("Whip")
	
func any_cooldown()->bool:
	return host.syringe_is_out() or host.snagtrik_is_out()

func _on_hit_something(obj, hitbox):
	._on_hit_something(obj, hitbox)
	
	if obj is Fighter:
		if is_projectile():
			host.lassail_projectile().hitlag_ticks += hitbox.hitlag_ticks
