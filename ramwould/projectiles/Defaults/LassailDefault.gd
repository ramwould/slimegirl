extends ObjectState

const PULL_BACK_TICK = 50
const PULL_BACK_TICK_ON_BLOCK = 38
const PULL_BACK_SPEED = "10"
const PULL_BACK_SPEED_ON_WHIFF = "19"
const PULL_BACK_PICKUP_DIST = "50"
const BASE_DAMAGE = 22

var last_y_vel
var pulling = false
var activated_hitbox = true
var blocked = false
var hit_opponent = false
var push_blocked = false

export var detached = false

const MAX_NUM_BOUNCES = 3

onready var hitbox = $Hitbox
onready var beam = $"%BeamHitbox"

var num_bounces = 0

func copy_to(s):
	.copy_to(s)
	s.last_y_vel = last_y_vel
	s.num_bounces = num_bounces
	
func _enter():
	apply_forces = true
	pulling = false
	activated_hitbox = true
	hit_opponent = false
	blocked = false
	push_blocked = false
	
func _tick():
	host.update_grounded()
	host.update_data()
	var pos = host.get_pos()
	var vel = host.get_vel()
	
#	if not fixed.eq(vel.y, "0"):
#		last_y_vel = vel.y
	
	if host.is_grounded():
		host.set_vel(vel.x, fixed.mul(host.last_vel_y, "-1.0"))
		_on_floor_bounce()
#		host.set_grounded(false)
#		host.move_directly(0, - 1)
#		if vel and last_y_vel:
#			host.set_vel(vel.x, fixed.mul(fixed.abs(last_y_vel), "-1.0"))
	host.last_vel_y = vel.y
			
	if (Utils.int_abs(pos.x) >= host.stage_width):
		host.set_vel(fixed.mul(fixed.abs(vel.x), str(Utils.int_sign(pos.x) * - 1)), vel.y)
#			host.move_directly(fixed.mul(vel.x, "-1"), "0")
		_on_wall_bounce()
	
	hitbox.damage = BASE_DAMAGE*2 if not host.on_fire else BASE_DAMAGE
	beam.damage = hitbox.damage*2
	
	if not detached:
		if (current_tick > PULL_BACK_TICK_ON_BLOCK) and blocked:
			pulling = true
			
		if (current_tick > PULL_BACK_TICK) or pulling or host.venocache_used:
			if host.on_fire:
				host.disable()
				return
			apply_forces = false
			pulling = true
			
			var host_pos = host.obj_local_center( host.get_fighter() )
			var speed = PULL_BACK_SPEED if hit_opponent else PULL_BACK_SPEED_ON_WHIFF
			var dir = fixed.normalized_vec_times(str(host_pos.x), str(host_pos.y), speed)
			host.move_directly(dir.x, dir.y)
			host.set_vel(dir.x, dir.y)
			
			if fixed.lt( host.obj_distance(host.get_fighter()), PULL_BACK_PICKUP_DIST ):
				host.disable()
		
			if host.get_opponent().combo_count > 0:
				if activated_hitbox:
					terminate_hitboxes()
					activated_hitbox = false
			else:
				if not activated_hitbox:
					activate_hitbox(hitbox)
					activated_hitbox = true

func on_got_blocked_by(who):
	hit_opponent = true
	blocked = true
	if detached:
		if who.current_state().get("IS_NEW_PARRY") and who.current_state().push:
			push_blocked = true

func _on_hit_something(o, h):
	._on_hit_something(o, h)
	
	if o is Fighter:
		hit_opponent = true

func _on_floor_bounce():
	if detached:
		num_bounces+=1
		
#		var center = host.get_hurtbox_center_float().x
		beam.create_trail = beam.trail_type.Fire if host.on_fire else beam.trail_type.None
		host.get_fighter().spawn_basic_beam(0, -1000, beam, host)
		
		if num_bounces >= MAX_NUM_BOUNCES or push_blocked:
#			host.get_fighter().create_slime_trail(host)
			host.disable()
			return
		
			
func _on_wall_bounce():
	pass
		
	
