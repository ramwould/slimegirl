extends "res://slimegirl/ramwould/projectiles/PoisonProjectile.gd"

func _draw():
	sprite.set_material( get_fighter().sprite.get_material() )
	$"%Trail".modulate = get_fighter().color_else_slime()

func tick():
	.tick()
	
	if on_fire:
		if current_state():
			current_state().lifetime = 48
			current_state().move_x = 23
			current_state().fizzle_on_hit_opponent = true
			
	create_speed_after_image( get_fighter().color_else_slime("outline"), Utils.frames(9) )
		
func create_speed_after_image(color:Color = Color.white, lifetime = 0.2, offset = Vector2.ZERO):
	if is_ghost or ReplayManager.resimulating:
		return 
	call_deferred("_create_speed_after_image", color, lifetime, offset)

func _create_speed_after_image(color:Color = Color.white, lifetime = 0.2, offset = Vector2.ZERO):
	var speed_image_effect = preload("res://fx/SpeedImageEffect.tscn")
	var texture = sprite.frames.get_frame(sprite.animation, sprite.frame)
	var effect = _spawn_particle_effect(speed_image_effect, get_pos_visual() + sprite.offset + offset)
	effect.set_texture(texture)
	effect.lifetime = lifetime
	effect.set_color(color)
	effect.sprite.flip_h = get_facing_int() == - 1

func hit_by(hitbox):
	.hit_by(hitbox)
	if hitbox.hitbox_type == Hitbox.HitboxType.Flip and hitbox.host == get_fighter().name:
		turn_around()
		refresh_hitboxes()
		has_projectile_parry_window = false
		get_fighter().feinting = true
