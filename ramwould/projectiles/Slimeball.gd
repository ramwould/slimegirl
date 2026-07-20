extends "res://slimegirl/ramwould/projectiles/PoisonProjectile.gd"

const IS_SLIMEBALL = true

func _draw():
	sprite.set_material( get_fighter().sprite.get_material() )
	$"%Trail".modulate = get_fighter().color_else_slime()
	
func hit_by(hitbox):
	.hit_by(hitbox)
	objs_map[hitbox.host]
	obj_from_name(hitbox.host)
	
	var target = obj_from_name(hitbox.host)
	if target:
		var di = get_fighter().current_di
		if target.id != id:
			di = get_opponent().current_di
			
		var di_mod = fixed.vec_mul(di.x, di.y, "1.0")
			
		var kb = fixed.vec_mul(hitbox.dir_x, hitbox.dir_y, hitbox.knockback)
		var kb_mod = fixed.vec_add(kb.x, kb.y, di_mod.x, di_mod.y)
			
		set_vel(fixed.mul(kb_mod.x, str(target.get_facing_int())), kb_mod.y)
