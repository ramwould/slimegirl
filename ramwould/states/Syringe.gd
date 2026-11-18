extends "res://slimegirl/ramwould/states/SlimeState.gd"

#SYRINGE
#SYRINGE
#SYRINGE

export var extend_tick = 0
export var extend_time = 0
export var syringe_all_round = false

var pos_x = "0"
var pos_y = "0"
var saved_radius_center_x:int = 0
var saved_radius_center_y:int = 0
var midpoint: Vector2

func is_usable():
	if not .is_usable(): return false
	
	if any_cooldown(): return false
		
	if (is_projectile() or not host.is_grounded()) and syringe_all_round:
		return true
					
	elif not is_projectile() and host.is_grounded() and not syringe_all_round:
		return true
					
				
	return false
	
func copy_to(s):
	.copy_to(s)
	s.pos_x = pos_x
	s.pos_y = pos_y
	s.saved_radius_center_x = saved_radius_center_x
	s.saved_radius_center_y = saved_radius_center_y
	s.midpoint = midpoint
	
func _frame_0():
	pos_x = "0"
	pos_y = "0"
	if data is Dictionary:
		if data.has("x"):
			var vec01 = xy_to_dir(data.x, data.y, host.current_radiation_radius)
			pos_x = vec01.x
			pos_y = vec01.y
		if data.has("Position"):
			var vec01 = xy_to_dir(data["Position"].x, data["Position"].y, host.current_radiation_radius)
			pos_x = vec01.x
			pos_y = vec01.y
			
	midpoint = Vector2.ZERO
			
func set_saved_snag_position():
	var main = host
	if is_projectile():
		main = host.lassail_projectile()
		
	main.update_data()
	saved_radius_center_x = host.radius_center().x+get_current_vel_position(main).x
	saved_radius_center_y = host.radius_center().y+get_current_vel_position(main).y
	
func get_saved_snag_position()->Vector2:
	return Vector2(int(saved_radius_center_x), int(saved_radius_center_y)) 
	
func get_local_aimed_position()->Vector2:
	return Vector2(int(pos_x), int(pos_y))

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
	if is_projectile():
		main = host.lassail_projectile()
				
	var pos = get_saved_snag_position()
	var vec = get_local_aimed_position()
	
	if current_tick == extend_tick-1:	
		set_saved_snag_position()

		pos = get_saved_snag_position()
		vec = get_local_aimed_position()
		
		var combined_vec = vec+pos
		host.syringe_extend(extend_time, combined_vec)
	
	host.apply_grav()
		
	var hitbox_pos = host.to_local(vec)+pos
	for node in get_children():
		if node is CollisionBox:
			if host.turn_frames > 1:
				node.x = hitbox_pos.x * host.get_facing_int()
				node.y = hitbox_pos.y
				
				if midpoint == Vector2.ZERO:
					var fixedVec = fixed.vec_div(str(vec.x), str(vec.y), "2.25")
					midpoint.x = int(fixedVec.x)
					midpoint.y = int(fixedVec.y)

		if node is Hitbox:				
			main.update_data()
			
			var dir = fixed.normalized_vec(pos_x, pos_y)
			node.dir_x = fixed.mul( str(dir.x), str(host.get_facing_int()) )
			node.dir_y = str(dir.y)
			
			if node is SweptHitbox:
				node.to_x = -int(midpoint.x) * host.get_facing_int()
				node.to_y = -int(midpoint.y)
	
func any_cooldown()->bool:
	return host.syringe_is_out() or host.snagtrik_is_out()

func _on_hit_something(obj, hitbox):
	._on_hit_something(obj, hitbox)
	
	if obj is Fighter:
		if is_projectile():
			host.lassail_projectile().hitlag_ticks += hitbox.hitlag_ticks
