extends "res://slimegirl/ramwould/projectiles/PoisonProjectile.gd"

export var off_fire_explosion : PackedScene
var storing_projectile = false

const SLIME_KNOCKBACK_MOD = "0.4"
const IS_BUBBLE = true

func tick():
	.tick()
	
	sprite.modulate = get_fighter().color_else_slime("slime")
	$"%Filled".visible = storing_projectile
		
func hit_by(hitbox):
	
	if hitbox and "sharp" in hitbox.misc_data and obj_from_name(hitbox.host).id == get_fighter().id and ("Chase" in current_state().state_name):
		if hitbox.throw:
			return
		.hit_by(hitbox)
		get_fighter().syringe_ticks = 6
		current_state().fizzle()

func try_explode():
	var box = get_hurtbox_center_float()
	var box_relative = hurtbox_pos_relative()

	_spawn_particle_effect(on_fire_explosion_fx, box, Vector2())
	
	var spawn = on_fire_explosion
	if storing_projectile: spawn = off_fire_explosion
	
	var obj = spawn_object(spawn, box_relative.x, box_relative.y, true, null, true)
#	obj.allow_host_hit_cancelling = on_fire_hit_cancel
