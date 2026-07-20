extends DefaultFireball

func _frame_0():
	pass

func _tick():
	._tick()
	
	var slimegirl = host.get_fighter()
	if current_tick == host.swept.start_tick-1:
		host.swept.activate()
		host.beam_fx.start_emitting()
		host.play_sound("boom")
		
		var direction = host.beam_direction
		direction.x *= slimegirl.get_facing_int()
		var pos = host.get_hurtbox_center_float()
		var intersecting = Geometry.line_intersects_line_2d(pos, direction, Vector2(slimegirl.stage_width, 0), Vector2.LEFT)
		
		if intersecting:
			var global_pos = intersecting
			match host.create_trail:
				1: slimegirl.create_slime_trail(global_pos)
				2: slimegirl.spawn_object(preload("res://slimegirl/ramwould/projectiles/SlimeFire.tscn"), global_pos.x, 0, false, null, false)
		
			if slimegirl.queued_beam_shockwave and host.can_shockwave:
				slimegirl.use_beam_charge()
				slimegirl.spawn_shockwave(global_pos)
