extends "res://slimegirl/ramwould/states/SlimeState.gd"

const VENO_IASA = 16

func is_usable():
	return .is_usable() and host.is_poisoned()

func _enter():
	anim_name = sprite_animation
	iasa_at = -1
	
func _frame_0():
	var pos = host.radius_center()
	var obj = host.spawn_object(preload("res://slimegirl/ramwould/projectiles/VenocacheProjectile.tscn"), pos.x, pos.y, false, null, false)
	
func _tick():
	var pos =  host.to_local( host.radius_center() )
	$"%VenocacheWind".position = Vector2(pos.x*host.get_facing_int(), pos.y)
	
func _exit():
	host.stop_venocache_wind()

func on_venocache_hit():
	anim_name = "VenocacheBurst"
	iasa_at = VENO_IASA
