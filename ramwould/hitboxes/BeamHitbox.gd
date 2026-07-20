tool
extends SweptHitbox

const IS_BEAM = true

enum trail_type{None, Slime, Fire}
export(trail_type) var create_trail = trail_type.None
export(Vector2) var beam_direction = Vector2.DOWN
export var stop_at_ground = true
export var show_base = true
export var can_shockwave = true
export var startup_ticks :int= 0
export var melee_hitbox = true

func init():
	.init()
	
	#	Fixes some weird projectile stupidity with how I like to code my knockback directions
	var normalized_dir = host.fixed.normalized_vec(dir_x, dir_y)
	dir_x = normalized_dir.x
	dir_y = normalized_dir.y
	
func spawn_particle(particle, obj, dir):
	if hit_particle and particle == hit_particle:
		var color 										= "style_2"
		if create_trail == trail_type.Slime: color		= "slime"
		if create_trail == trail_type.Fire: color		= "style_1"
		host.spawn_particle_effect(particle, get_hit_particle_location(obj.hurtbox), dir, color)
	
func tick():
	.tick()
	

func activate():
	.activate()
