extends "res://slimegirl/ramwould/projectiles/PoisonProjectile.gd"

var detached = false
var venocache_used = false
var last_vel_y

func disable():
	.disable()
	get_fighter().lassail_proj = null
	
func _draw():
	sprite.set_material( get_fighter().sprite.get_material() )
	$"%Trail".modulate = get_fighter().color_else_slime("outline")
	
func hit_by(hitbox):
	if hitbox:
		if hitbox.host == get_fighter().obj_name:
			return
	.hit_by(hitbox)

func detach():
	detached = true
	change_state("Detached")

func retach():
	detached = false
	change_state("Default")

func tick():
	.tick()
	if get_fighter().gooped_obj() == self:
		get_fighter().reset_goop( true )
		if is_detached():
			retach()
		
func is_detached():
	return detached

func _slimegirl_used_venocache():
	if not detached:
		venocache_used = true
