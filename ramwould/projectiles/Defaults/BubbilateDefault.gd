extends ObjectState

export var lifetime = 0

export var chasing = false
export var home_speed = "0.0"
export var friction = "0.0"
export var boom_range = "0.0"

const SLIME_SPEED = "9.0"


func _tick():	
	host.update_grounded()

	if chasing:
		if current_tick > lifetime:
			fizzle()
			return
		var opponent = host.get_opponent()
		var dir_2_opp = fixed.vec_sub(
			str(opponent.get_hurtbox_center().x),
			str(opponent.get_hurtbox_center().y),
			str(host.get_hurtbox_center().x),
			str(host.get_hurtbox_center().y)
			)
		var fire_speed = fixed.mul(home_speed, "2.5")
		var dir = fixed.normalized_vec_times(dir_2_opp.x, dir_2_opp.y, fire_speed if host.on_fire else home_speed)
		
		host.update_data()
		
		host.move_directly(dir.x, dir.y)
		host.apply_x_fric(friction)
		host.apply_y_fric(friction)
		
		if not host.storing_projectile:
			for obj in host.get_fighter().objs_map.values():
				if obj is BaseProjectile:

					if not fixed.lt(host.distance_to(obj), boom_range):
						continue
					if not check_objs(obj):
						continue
						
					obj.update_data()
					
					var vec = host.get_object_dir_vec(obj)
					var push = fixed.vec_mul(vec.x, vec.y, "-6.0")
					host.apply_force(push.x, push.y)
					host.storing_projectile = true
					if obj.get("on_fire"):
						host.on_fire = obj.on_fire
					
					obj.current_state().fizzle()
					break
						
		if fixed.lt(host.distance_to(opponent), boom_range):
			fizzle( false )
			
	else:
		pass
	
		
func fizzle(spawn=true):
	if host.storing_projectile and spawn:
		var opponent = host.get_opponent()
		var dir_2_opp = fixed.vec_sub(
			str(opponent.get_hurtbox_center().x),
			str(opponent.get_hurtbox_center().y),
			str(host.get_hurtbox_center().x),
			str(host.get_hurtbox_center().y)
			)
		var dir = fixed.normalized_vec_times(dir_2_opp.x, dir_2_opp.y, SLIME_SPEED)
		
		var proj = host.spawn_object(preload("res://slimegirl/ramwould/projectiles/Slimeball.tscn"), 0, 0)
		proj.set_grounded( false )
		proj.apply_force(dir.x, dir.y)
		
	host.disable()

func destroy_obj(objs):
	if (objs is BaseProjectile) and objs.current_state():
		var obj_state = objs.current_state()
		if obj_state.has_method("fizzle") and (obj_state.get("clash") or obj_state.get("fizzle_on_ground") or obj_state.get("fizzle_on_walls") or obj_state.get("fizzle_on_hit_opponent")) and not objs.invulnerable:
			return true
			
	return false

func projectile_banned_for_use(obj)->bool:
	var _char = host.get_fighter().getCharacterName(host.get_fighter().opponent.id)
	if _char in host.get_fighter().PROJECTILES_SLIMEGIRL_CANNOT_ASSIMILATE.keys():
		var ban_list = host.get_fighter().PROJECTILES_SLIMEGIRL_CANNOT_ASSIMILATE[_char]
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

func check_objs(obj)->bool:

	if not is_instance_valid(obj):
		return false
	if obj is BaseProjectile:
		if obj.obj_name == host.obj_name:
			return false
		if obj.get("IS_BUBBLE"):
			return false
		if obj.disabled:
			return false
		if obj.invulnerable:
			return false
		if projectile_banned_for_use(obj):
			return false
		if obj.get_hurtbox_center().y > 0:
			return false
		if not destroy_obj(obj):
			return false
			
	return true
