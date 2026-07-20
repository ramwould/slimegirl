extends "res://slimegirl/ramwould/states/SlimeState.gd"

var force_applied = false
const MINIMUM_TO_BOUNCE = "-2"

func _frame_6():
	if host.initiative:
		host.start_projectile_invulnerability()
	
func _frame_11():
	host.end_projectile_invulnerability()

func _enter():
	force_applied = false
	
func _exit():
	host.end_projectile_invulnerability()

func on_got_blocked_by(who):
	if who is Fighter and not force_applied:
		bounce_fighter()

func _on_hit_something(obj, hitbox):
	._on_hit_something(obj, hitbox)
	if obj is Fighter and not force_applied:
		bounce_fighter()
	
func bounce_fighter():
	var consecutive_force = "-6"
	host.update_data()
	if fixed.ge( host.get_vel().y, MINIMUM_TO_BOUNCE ):
		force_applied = true
		host.set_vel(fixed.div(host.get_vel().x,"2"), "0")
		host.apply_force_relative("0", consecutive_force)
	
	spawn_particle_relative(particle_scene, Vector2(0, -6), Vector2.UP)
	queue_state_change("AllearsJump")
	
func detect(obj):
	if not (obj is Fighter):
		if host.has_bounced_projectile(obj):
			return
			
		var consecutive_force = "-5.5"
		
		if not force_applied:
			host.update_data()
			if fixed.ge( host.get_vel().y, MINIMUM_TO_BOUNCE ):
				force_applied = true
				host.set_vel(host.get_vel().x, "0")
				host.apply_force_relative("0", consecutive_force)
		
		obj.update_data()
		if fixed.lt( obj.get_vel().y,"0" ):
			obj.set_vel( obj.get_vel().x, fixed.mul(obj.get_vel().y,"-1") )
		
		var obj_state = obj.current_state()
		if obj_state and obj_state.has_method("move") and obj.movable:
			if obj_state.move_y < 0:
				obj_state.move_y *= -1
			if fixed.lt( obj_state.move_y_string,"0" ):
				var new_y_string = fixed.mul(obj_state.move_y_string,"-1")
				obj_state.move_y_string = new_y_string
				
		host.append_bounced_projectile(obj)
		host.hitlag_ticks += 2
		
		spawn_particle_relative(particle_scene, Vector2(0, -6), Vector2.UP)
		queue_state_change("AllearsJump", {"proj_immunity":true})
		

