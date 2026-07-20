extends "res://slimegirl/ramwould/states/SlimeState.gd"

const PUSH_FORCE = "6.0"

func _frame_0():
	iasa_at = - 1
	next_state_on_hold = true
	next_state_on_hold_on_opponent_turn = true

func hit_literally_anything():
	next_state_on_hold = false
	next_state_on_hold_on_opponent_turn = false
	iasa_at = 14
	
func _on_hit_something(obj, hitbox):
	._on_hit_something(obj, hitbox)
	
	hit_literally_anything()
	
	if obj is Fighter:
		obj.apply_force(fixed.mul(str(host.get_facing_int()), PUSH_FORCE), "0")
		
	else:
		if obj is BaseProjectile and not obj.movable:
			return
		host.play_sound("BatterUp")
		if obj.id == host.id:
			obj.refresh_hitboxes()
		if obj == host.lassail_projectile():
			host.update_data()
			var vel = obj.get_vel()
			obj.set_vel("0", vel.y)
			obj.current_state().current_tick -= 18
			if obj.current_state().current_tick < 0:
				obj.current_state().current_tick = 0
		obj.apply_force(fixed.mul(str(host.get_facing_int()), PUSH_FORCE), "0")
	pass

func detect(obj):
	if obj.is_in_group("BaseObj"):
		if host.on_fire_this_state:
			if host.append_fiery_projectile(obj):
				obj.turn_around()
				hit_literally_anything()
		
