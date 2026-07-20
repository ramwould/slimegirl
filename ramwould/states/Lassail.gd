extends "res://slimegirl/ramwould/states/SlimeState.gd"

var throw_x = "0.0"
var throw_y = "0.0"

const POWER = "10.5"

onready var hitbox = $Hitbox

func _enter():
	anim_name = "Lassail"+aerial_state()
	loop_animation = true
	ticks_per_frame = 3
	
	if data is Dictionary:
		var dir = xy_to_dir(data.x, data.y, POWER)
		throw_x = dir.x
		throw_y = dir.y
	interruptible_on_opponent_turn = false

#func _tick():
#	if not fixed.eq(throw_x,"0"):
#		host.set_facing( fixed.sign(throw_x) )
	
func _frame_12():
	anim_name = "LassailThrow"+aerial_state()
	loop_animation = false
	ticks_per_frame = 4
	animation_tick = 0
	
	var obj = host.spawn_object(preload("res://slimegirl/ramwould/projectiles/LassailObj.tscn"), 0, -14)
	obj.set_grounded( false )
	obj.apply_force(throw_x, throw_y)
	interruptible_on_opponent_turn = true
	host.lassail_proj = obj.name
	if host.on_fire_this_state:
		host.append_fiery_projectile(obj)
	
	var x_force = 1
	var y_force = 0
	if is_aerial():
		x_force = -1
		if not host.is_grounded():
			y_force = -2
			host.update_data()
			var vel = host.get_vel()
			if vel and fixed.gt(vel.y, "0"):
				host.set_vel(vel.x, "0")
				
	host.apply_force_relative(x_force, y_force)
	host.add_penalty(8)
	
func update_sprite_frame():
	if not host.sprite.frames.has_animation(anim_name):
		return
	if host.sprite.animation != anim_name:
		host.sprite.animation = anim_name
		host.sprite.frame = 0
	var sprite_tick = animation_tick / ticks_per_frame

	if loop_animation and absolute_loop:
		sprite_tick = host.current_tick / ticks_per_frame
	elif loop_animation and not refresh_loop:
		if same_as_last_state:
			sprite_tick = (animation_tick + exit_tick) / ticks_per_frame

		
	var frame = (sprite_tick % (sprite_anim_length - animation_loop_start) + animation_loop_start) if (loop_animation and sprite_tick > animation_loop_start) else Utils.int_min(sprite_tick, sprite_anim_length)
	host.sprite.frame = frame

func is_aerial():
	return air_type == AirType.Aerial

func aerial_state()->String:
	return "Aerial" if is_aerial() else ""
