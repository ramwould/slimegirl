extends HurtAerial

func set_anim():
	anim_name = "HurtAerial_Forward"
	
	var normalized = fixed.normalized_vec(hitbox.dir_x, hitbox.dir_y)
	host.update_data()
	var vel = host.get_vel()
	if fixed.gt( normalized.y, "0.7" ) and vel and fixed.gt(vel.y,"0"):
		anim_name = "HurtAerial_Down"
		
	if fixed.lt( normalized.y, "-0.7" ) and vel and fixed.lt(vel.y,"0"):
		anim_name = "HurtAerial_Up"
	
	if fixed.gt( hitbox.knockback, "15" ) or hitbox.wall_slam or ground_bounced:
		anim_name = "HurtAerial_Hard"
		
func _enter():
	._enter()
	
	set_anim()
	
	
func _tick():
	var state = ._tick()
	if state:
		return state
		
	else:
		if anim_name == "HurtAerial":
			set_anim()
