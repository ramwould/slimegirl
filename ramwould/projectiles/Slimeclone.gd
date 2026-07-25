extends "res://slimegirl/ramwould/projectiles/PoisonProjectile.gd"

const IS_SLIMECLONE = true
const SLIME_FRIC = "0.085"
const SLIME_KNOCKBACK_MOD = "1.2"
const SLIME_KNOCKBACK_MOD_OPPONENT = "1.0"
const SLIME_KNOCKBACK_MOD_SLOPPY = "1.6"
const SLIME_KNOCKBACK_UPWARDS_Y_REDUCTION = "0.6"
const SLIME_MAX_UPWARDS_Y_SPEED = "-12.0"
const SLIME_DI_MOD = "2.8"

var DISABLED_COLOR = Color.white

var safely_disable = true
var clone_disabled = false
var primed = 0
var queue_disabled = false
var attack_pushed_by_slimegirl = 0
var bounced = false
var last_vel_y = "0"
var aerial_clone = false

onready var name_label = $"%NameLabel"

func copy_to(c):
	.copy_to(c)
	
	c.sprite = sprite.duplicate()
	
func disable():
	if primed > 0:
		queue_disabled = true
		return
		
	var index = 0
	for data in get_fighter().slimeclone_data:
		if data.has("clone_name"):
			if data.clone_name == name:
				break
		index += 1
	get_fighter().slimeclone_data.remove(index)
	
	if not safely_disable and not get_fighter().is_in_hurt_state(false):
		var box = get_hurtbox_center_float()
		var box_relative = hurtbox_pos_relative()
		_spawn_particle_effect(on_fire_explosion_fx, box, Vector2())
		var explosion :BaseProjectile= spawn_object(on_fire_explosion, box_relative.x, box_relative.y, true, null, true)
		explosion.allow_host_hit_cancelling = allow_host_hit_cancelling
		explosion.immunity_susceptible = not allow_host_hit_cancelling
		
	.disable()
		
func _draw():
	sprite.set_material( get_fighter().reversed_material )
	
	var radius = max((hurtbox.width + hurtbox.height) / 2.0, 7.0)
	if Global.mouse_world_position.distance_to(get_hurtbox_center_float()) < max(32.0, radius):
		$"%DisabledLabel".modulate.a = 1.0
		$"%NameLabel".modulate.a = 1.0
	else:
		$"%DisabledLabel".modulate.a = 0.15
		$"%NameLabel".modulate.a = 0.15
			
func _process(delta):
	$"%NameLabel".hide()
	$"%DisabledLabel".hide()
	
	var game = Global.current_game
	if game and game.game_paused and not disabled and not is_ghost:
		$"%NameLabel".show()
		if _inactive(): $"%DisabledLabel".show()
	
	update()

func tick():
	.tick()
	if queue_disabled and primed > 0:
		primed-=1
		disable()
		
	DISABLED_COLOR = get_fighter().MELTDOWN_COLOR_DISABLED
	afterimage_fx()
	
	if get_fighter().slimeclone_data.size() >= slimeclone_index()+1:
		name_label.text = str(slimeclone_index()+1)+": "+get_fighter().slimeclone_data[slimeclone_index()]["state_visual"]
	
	update_data()
	var vel = get_vel()
	if fixed.lt(vel.y, SLIME_MAX_UPWARDS_Y_SPEED):
		set_vel(vel.x, SLIME_MAX_UPWARDS_Y_SPEED)
	var vel_len = fixed.vec_len(vel.x, vel.y)
	
	if attack_pushed_by_slimegirl > 0:
		attack_pushed_by_slimegirl -= 1
		
	elif not fixed.eq(vel_len,"0"):
		apply_x_fric(SLIME_FRIC)
		apply_y_fric(SLIME_FRIC)
		
		if fixed.lt(vel_len,"0.5"):
			reset_momentum()
			return
	
	update_data()
	var pos = get_pos()
	
	if disabled: return
	if bounced:
		bounced = false
		
	elif last_vel_y and pos.y >= 0 and fixed.gt(last_vel_y,"0"):
		set_y(-1)
		set_vel(
			vel.x, 
			fixed.mul(last_vel_y,"-0.67")
			)
		bounced = true
		
	elif Utils.int_abs(pos.x) >= stage_width:
		set_facing( get_facing_int()*-1 )
		move_directly_relative(1, 0)
		set_vel(
			fixed.mul(vel.x,"-1"), 
			vel.y
			)
		var new_clone_vel_x = fixed.mul(
			get_fighter().slimeclone_data[slimeclone_index()]["current_vel"].x,
			"-1"
			)
		get_fighter().slimeclone_data[slimeclone_index()]["current_vel"].x = new_clone_vel_x
		
		var old_data = get_fighter().slimeclone_data[slimeclone_index()]["state_data"]
		get_fighter().slimeclone_data[slimeclone_index()]["state_data"] = get_fighter().flip_clone_data_x( old_data )

		bounced = true
	
	last_vel_y = vel.y
	
func afterimage_fx():
	var speed_image_effect = preload("res://slimegirl/ramwould/FX/afterimages/Radioactive01.tscn")
	var texture = sprite.frames.get_frame(sprite.animation, sprite.frame)
	var effect = _spawn_particle_effect(speed_image_effect, get_pos_visual() + sprite.offset)
	effect.set_texture(texture)
	effect.lifetime = Utils.frames(6)
	var length = 3
	effect.position += Vector2(rand_range(-length,length),rand_range(-length,length))
	var new_color = get_fighter().color_else_slime("outline")
	if _inactive():
		new_color = DISABLED_COLOR
	new_color.a = 0.8
	effect.set_color(new_color)
	effect.sprite.flip_h = get_facing_int() == - 1

func _inactive():
	return clone_disabled or queue_disabled

func hit_by(hitbox):
	.hit_by(hitbox)
	
	if _inactive():
		return
	if attack_pushed_by_slimegirl > 0:
		return
		
	if hitbox and hitbox.host:
		if hitbox.throw:
			return
			
		var fighter = obj_from_name(hitbox.host)
		var slimegirl = get_fighter() as Fighter
		if fighter is Fighter:
			hitlag_ticks = 0
			fighter.hitlag_ticks = 0
			
			var kb_mod = SLIME_KNOCKBACK_MOD
			if (fighter == slimegirl and fighter.stance == "Sloppy"):
				kb_mod = SLIME_KNOCKBACK_MOD_SLOPPY
				
			if fighter == get_opponent():
				kb_mod = SLIME_KNOCKBACK_MOD_OPPONENT
				
			var dir = fixed.normalized_vec_times(
				fixed.mul( hitbox.dir_x, str(fighter.get_facing_int()) ), 
				hitbox.dir_y, 
				fixed.mul(hitbox.knockback,kb_mod)
				)
			
			if fighter == slimegirl:
				var DI = xy_to_dir(
					slimegirl.current_di.x, 
					slimegirl.current_di.y,
					SLIME_DI_MOD
					)
				dir = fixed.vec_add(dir.x, dir.y, DI.x, DI.y)
			
			if fixed.lt(dir.y, "0"):
				dir.y = fixed.mul(dir.y, SLIME_KNOCKBACK_UPWARDS_Y_REDUCTION)
			if is_grounded() and not aerial_clone:
				dir.y = "0"
			apply_force(dir.x, dir.y)
			update_data()
			attack_pushed_by_slimegirl = 10
			current_state().current_tick += 20
			
func slimeclone_index()->int:
	var index = 0
	for data in get_fighter().slimeclone_data:
		if data.has("clone_name"):
			if data.clone_name == name:
				break
		index += 1
	return index
