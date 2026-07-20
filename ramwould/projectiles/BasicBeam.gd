extends "res://slimegirl/ramwould/projectiles/PoisonProjectile.gd"

var stop_at_ground:bool
var beam_direction:Vector2
var show_base:bool
var hitbox_data:HitboxData
var beam_size:float
var loop_active_ticks:int = 1
var loop_inactive_ticks:int = 1
var active_ticks:int = 1
var startup_time:int = 0
var hit_particle:PackedScene
var can_shockwave = false
var create_trail = 0
var melee = true

onready var swept:SweptHitbox = $StateMachine/Default/SweptHitbox
onready var beam_fx = $"%BeamFX"
const POISON_STRING = "poison"
const BEAM_SIZE_MOD = 1.75
const BEAM_SIZE_ADD = 0.05

func copy_to(b):
	.copy_to(b)
	
	b.stop_at_ground = stop_at_ground
	b.show_base = show_base
	b.beam_direction = Vector2(beam_direction.x*get_facing_int(), beam_direction.y)
	b.hitbox_data = hitbox_data
	b.beam_size = beam_size
	b.loop_active_ticks = loop_active_ticks
	b.loop_inactive_ticks = loop_inactive_ticks
	b.active_ticks = active_ticks
	b.hit_particle = hit_particle.duplicate(true)
	b.startup_time = startup_time
	b.create_trail = create_trail
	b.can_shockwave = can_shockwave
	b.melee = melee
	
func setup_hitbox(hitbox:Hitbox, d:HitboxData):
	if d == null:
		return
	hitbox.hit_height = d.hit_height
	hitbox.hitstun_ticks = d.hitstun_ticks
	hitbox.facing = d.facing
	hitbox.knockback = d.knockback
	hitbox.dir_x = d.dir_x
	hitbox.dir_y = d.dir_y
	hitbox.x = 0
	hitbox.y = 0
	hitbox.can_counter_hit = true
	hitbox.knockdown = d.knockdown
	hitbox.hitlag_ticks = d.hitlag_ticks
	hitbox.victim_hitlag = d.victim_hitlag
	hitbox.disable_collision = d.disable_collision
	hitbox.aerial_hit_state = d.aerial_hit_state
	hitbox.grounded_hit_state = d.grounded_hit_state
	hitbox.air_ground_bounce = d.air_ground_bounce
	hitbox.hits_otg = d.hits_otg
	hitbox.damage = d.damage
	hitbox.parriable = d.parriable
	hitbox.launch_reversible = d.reversible
	hitbox.width = beam_size
	hitbox.height = beam_size
#	hitbox
#	var name
	hitbox.throw = d.throw
	hitbox.knockdown_extends_hitstun = d.knockdown_extends_hitstun
	hitbox.rumble = d.rumble
	hitbox.host = get_fighter().obj_from_name( d.host ) if melee else self
	hitbox.screenshake_frames = d.screenshake_frames
	hitbox.screenshake_amount = d.screenshake_amount
	hitbox.minimum_damage = d.minimum_damage
	hitbox.sdi_modifier = d.sdi_modifier
	hitbox.di_modifier = d.di_modifier
	hitbox.meter_gain_modifier = d.meter_gain_modifier
	hitbox.increment_combo = d.increment_combo
	hitbox.ignore_armor = d.ignore_armor
	hitbox.damage_proration = d.damage_proration
	hitbox.parry_meter_gain = d.parry_meter_gain
	hitbox.force_grounded = d.force_grounded
	hitbox.hitbox_type = d.hitbox_type
	hitbox.hard_knockdown = d.hard_knockdown
	hitbox.damage_in_combo = d.damage_in_combo
	hitbox.wall_slam = d.wall_slam
	hitbox.hits_vs_dizzy = d.hits_vs_dizzy
#	hitbox
#	var is_projectile = false
	hitbox.scale_combo = d.scale_combo
	hitbox.combo_scaling_amount = d.combo_scaling_amount
	hitbox.vacuum = false
	hitbox.hits_vs_standing = d.hits_vs_standing
	hitbox.send_away_from_center = false
	hitbox.minimum_grounded_frames = d.minimum_grounded_frames
	hitbox.plus_frames = d.plus_frames
	hitbox.chip_damage_modifier = d.chip_damage_modifier
	hitbox.block_pushback_modifier = d.block_pushback_modifier
	hitbox.ground_bounce_knockback_modifier = d.ground_bounce_knockback_modifier
	hitbox.hits_projectiles = d.hits_projectiles
	hitbox.cancellable = d.cancellable
	hitbox.followup_state = ""
	hitbox.guard_break = d.guard_break
	hitbox.block_punishable = d.block_punishable
	hitbox.guard_break_proration = d.guard_break_proration
	hitbox.ignore_projectile_armor = d.ignore_projectile_armor
	hitbox.looping = d.looping
	hitbox.loop_active_ticks = loop_active_ticks
	hitbox.loop_inactive_ticks = loop_inactive_ticks
	hitbox.active_ticks = active_ticks
	hitbox.block_cancel_allowed = d.block_cancel_allowed
	hitbox.allowed_to_hit_own_team = false
	hitbox.block_pushback_reversible = d.block_pushback_reversible
	hitbox.block_reverse_pushback_modifier = d.block_reverse_pushback_modifier
	hitbox.misc_data = d.misc_data
	hitbox.hit_particle = hit_particle
	
func init(p=null):
	.init(p)
	
	update_beam_fx(true)
	setup_hitbox(swept, hitbox_data)
	
func tick():
	.tick()

	update_beam_fx()
	current_state().lifetime = 9+active_ticks+startup_time
	if get_fighter().is_in_hurt_state(false):
		if beam_fx and beam_fx.visible:
			beam_fx.hide()
		disable()
		
func disable():
	.disable()
	if beam_fx:
		beam_fx.stop_emitting()
		stop_sound("chargeup")
		
func on_state_started(state):
	.on_state_started(state)
	if startup_time>0:
		play_sound("chargeup")
		
func update_beam_fx(initial=false):
	if beam_fx:
		if initial:
			beam_fx.start_tick = -Utils.int_abs(startup_time)
		beam_fx.beam.to_ground = (beam_direction == Vector2.DOWN) and stop_at_ground
		beam_fx.grounded = beam_fx.beam.to_ground
		beam_fx.beam.line_size_multiplier = get_beam_size_visual()
		beam_fx.beam.duration = (0.3)+(Utils.frames(active_ticks))
		
		beam_fx.beam2.to_ground = 				beam_fx.beam.to_ground
		beam_fx.beam2.line_size_multiplier = 	beam_fx.beam.line_size_multiplier
		beam_fx.beam2.duration = 				beam_fx.beam.duration
		
		beam_fx.beam_base.line_size_multiplier = get_beam_size_visual()+0.15
		beam_fx.beam_base.visible = show_base
		beam_fx.beam_base.override_visibility = not show_base
		beam_fx.beam_base.duration = (0.3)+(Utils.frames(active_ticks))
		
		beam_fx.beam_base2.line_size_multiplier = 	beam_fx.beam_base.line_size_multiplier
		beam_fx.beam_base2.visible = 				beam_fx.beam_base.visible
		beam_fx.beam_base2.override_visibility = 	beam_fx.beam_base.override_visibility
		beam_fx.beam_base2.duration = 				beam_fx.beam_base.duration
		
		beam_fx.SMASH.visible = stop_at_ground
		beam_fx.SMASH.emission_rect_extents.x = beam_size
		
		beam_fx.rotation = Vector2(beam_direction.x*get_facing_int(), beam_direction.y).angle()
		
		match create_trail:
			0: beam_fx.tint.modulate = get_fighter().color_else_slime("style_2")	# no trail
			1: beam_fx.tint.modulate = get_fighter().color_else_slime("slime")	# slimetrail
			2: beam_fx.tint.modulate = get_fighter().color_else_slime("style_1")	# slimefire
		

func get_beam_size_visual()->float: return (beam_size*BEAM_SIZE_MOD)+BEAM_SIZE_ADD




