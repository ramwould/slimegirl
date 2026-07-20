extends DefaultFireball

const BOUNCE_Y_MODIFIER = "-0.7"
var stuck = false

func _tick():
	var slimegirl = host.get_fighter()
	
	host.update_data()
	var pos = host.get_pos()
	var vel = host.get_vel()
	
	host.update_grounded()
	if host.is_grounded() and slimegirl.object_on_trail(host):
		if fixed.gt(vel.y, "1"):
			host.set_vel(vel.x, fixed.mul(vel.y,BOUNCE_Y_MODIFIER))
			host.set_grounded(false)
			host.play_sound("SpawnTrail")
			host.has_projectile_parry_window = false
			
			return
	
	if not hit_something and ((host.is_grounded() and fizzle_on_ground) or (fizzle_on_walls and (pos.x <= - host.stage_width or pos.x >= host.stage_width))):
		fizzle()
		host.hurtbox.width = 0
		host.hurtbox.height = 0
		
		if host.is_grounded():
			host.get_fighter().create_slime_trail(pos)
			host.play_sound("SpawnTrail")
		pass
	if current_tick >= lifetime:
		fizzle()
	var lifetime_onfire = lifetime/7
	if current_tick >= lifetime_onfire and host.on_fire:
		fizzle()
	
	host.sprite.rotation = float(fixed.vec_to_angle(fixed.mul(vel.x, str(host.get_facing_int())), vel.y))

func _on_hit_something(obj, hit):
	if (obj is Fighter) and obj.id == host.id:
		return
		
	if obj is BaseObj:
		if host.get_fighter().gooped_obj() != host:
			._on_hit_something(obj, hit)
			return
		host.get_fighter().stick_goop_to_obj(obj, true)
		stuck = true
	
	._on_hit_something(obj, hit)
	
func fizzle():
	if not stuck:
		if host.get_fighter().gooped_obj() != host:
			.fizzle()
			return
		
		host.update_data()
		var pos = host.get_hurtbox_center()
		host.get_fighter().stick_goop_to_pos(pos.x, pos.y, true)
	.fizzle()
