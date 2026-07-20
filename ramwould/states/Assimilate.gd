extends "res://slimegirl/ramwould/states/SlimeState.gd"

var all_objs_in_radius = []
var assimilation_botched = false
var assimilated_something = false

const SUPER_PER_PROJECTILE = 30

const INITIAL_BOOST_TICKS = 80
const BOOST_PER_PROJECTILE = 20
const BOOST_PER_PROJECTILE_BOTCHED = 50

const SADNESS_PER_PROJECTILE = - 3
const BLOCK_POWER = "14"


func copy_to(state):
	.copy_to(state)
	state.all_objs_in_radius = all_objs_in_radius.duplicate(true)
	
func destroy_obj(objs:BaseObj):
	if objs.current_state():
		var obj_state = objs.current_state()
		
		var fx = preload("res://slimegirl/ramwould/FX/AssimilatedObjectFX.tscn")
		var vec01 = get_dir_vec( objs.get_hurtbox_center_float(), false )
		objs.spawn_particle_effect_relative(fx, Vector2(), Vector2(-vec01.x, -vec01.y))
		
		
		if obj_state.has_method("fizzle") and (obj_state.get("clash") or obj_state.get("fizzle_on_ground") or obj_state.get("fizzle_on_walls") or obj_state.get("fizzle_on_hit_opponent")) and not objs.invulnerable:
			if host.in_meltdown():
				var obj_center = objs.get_hurtbox_center()
				var slimeball:BaseProjectile = host.spawn_object(preload("res://slimegirl/ramwould/projectiles/Slimeball.tscn"), obj_center.x, obj_center.y, false, null, false)
				
				var vec1 = get_dir_vec( objs.get_hurtbox_center_float() )
				var dir1 = fixed.normalized_vec_times(str(vec1.x), str(vec1.y), BLOCK_POWER)
				slimeball.apply_force(dir1.x, dir1.y)
				slimeball.on_fire = host.on_fire_this_state
			objs.current_state().fizzle()
				
		else:
			if objs is BaseProjectile:
				if objs.movable:
					var vec1 = get_dir_vec( objs.get_hurtbox_center_float() )
					var dir1 = fixed.normalized_vec_times(str(vec1.x), str(vec1.y), BLOCK_POWER)
					objs.apply_force(dir1.x, dir1.y)
			assimilation_botched = true

func _frame_4():
	if check_all_objs():
#		interruptible_on_opponent_turn = true
		var total_boost = 0
		for index in all_objs_in_radius.size():
			var obj = all_objs_in_radius[index]
			
			destroy_obj(obj)
			if not assimilation_botched:
				host.gain_super_meter_raw(SUPER_PER_PROJECTILE)
#				host.add_penalty(SADNESS_PER_PROJECTILE)
				self_interruptable = true
				
			if index == 0:
				total_boost += INITIAL_BOOST_TICKS if not assimilation_botched else BOOST_PER_PROJECTILE_BOTCHED
			else:
				total_boost += BOOST_PER_PROJECTILE if not assimilation_botched else BOOST_PER_PROJECTILE_BOTCHED/2
					
		if total_boost > 0:
			if not assimilation_botched:
				host.enable_beam_charge()
			assimilated_something = true
			host.feinting = true
			
		host.boost_poison( total_boost )
		
		if is_projectile():
			pass
			
		else:
			host.start_projectile_invulnerability()
		
	else:
		host.add_penalty(15)
		
func _frame_8():
	started_during_combo = host.combo_count > 0
	if started_during_combo:
		_do_assimilation_reward()
			
func _frame_11():
	if not started_during_combo:
		_do_assimilation_reward()

func _do_assimilation_reward():
	if assimilated_something and host.opponent_in_radius():
		enable_interrupt(false)
	
func _enter():
	assimilation_botched = false
	assimilated_something = false
	self_interruptable = false
	
func _exit():
	all_objs_in_radius.clear()
	host.end_projectile_invulnerability()
#	host.has_projectile_armor = false
							
func get_dir_vec(pos, normalized = true):
	var my_pos = host.radius_center()
	if normalized:
		return fixed.normalized_vec(str(pos.x - my_pos.x), str(pos.y - my_pos.y))
	return {
		"x":pos.x - my_pos.x, 
		"y":pos.y - my_pos.y
	}

func projectile_banned_for_use(obj)->bool:
	var _char = host.getCharacterName(host.opponent.id)
	if _char in host.PROJECTILES_SLIMEGIRL_CANNOT_ASSIMILATE.keys():
		var ban_list = host.PROJECTILES_SLIMEGIRL_CANNOT_ASSIMILATE[_char]
		if ban_list is Array:
			for path in ban_list:
				match _char:
					"Crossbones":
						if obj.current_state() and (obj.current_state().get("on_ground") is bool):
							return true
					"Big Sword":
						return true
		else:
			return false
			
	return false

func check_all_objs()->bool:
	var any_objs = false
	all_objs_in_radius.clear()
	for obj in host.objs_map.values():
		if not is_instance_valid(obj):
			continue
		if obj is BaseProjectile:
			if obj.id == host.id:
				continue
			if obj.disabled:
				continue
			if obj.invulnerable:
				continue
			if projectile_banned_for_use(obj):
				continue
			if obj.get_hurtbox_center().y > 0:
				continue
			if host.obj_in_radius(obj):
				any_objs = true
				all_objs_in_radius.append(obj)
	return any_objs

func is_projectile()->bool:
	return host.lassail_projectile() and host.lassail_connected()
