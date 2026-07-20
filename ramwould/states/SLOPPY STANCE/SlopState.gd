extends "res://slimegirl/ramwould/states/SlimeState.gd"

export var ignore_whiff_punish = false
export var ignore_poison_reduction = false

const POWER_HITLAG = 2

var powered_up = false
var hit_once = false
var blocked_once = false
var latest_hitbox = 0
#var latest_hitbox_node

const POISON_REDUCED_PER_HIT_PERCENT = "0.12"

func setup_hitboxes():
	.setup_hitboxes()
	var latest = 0
	for hitbox in all_hitbox_nodes:
		if hitbox.start_tick > 0:
			var detect = hitbox.hitbox_type == Hitbox.HitboxType.Detect
			if not detect:
				if hitbox.start_tick > latest:
					latest = hitbox.start_tick + hitbox.active_ticks + 1
	latest_hitbox = latest
	
func _enter_shared():
	._enter_shared()
	hit_once = false
	blocked_once = false
	powered_up = host.has_sloppy_power()
	if powered_up:
		host.pause_poison_ticks = true

func _tick_before():
	if not powered_up:
		host.change_stance_to("Normal")

func _tick_shared():
	._tick_shared()
	
func can_interrupt():
	if host.infinite_resources or feinting: return .can_interrupt()
		
	if (!hit_or_blocked() and has_hitboxes and current_tick > latest_hitbox) and not ignore_whiff_punish:
		host.change_stance_to("Normal")
		
	return .can_interrupt()
	
func _on_hit_something(o, h):
	._on_hit_something(o, h)
	
	if powered_up:
		if !hit_or_blocked():
			take_poison(o)
			hit_once = true
			
		if o:
			if o.get("IS_SLIMECLONE"):
				host.stick_goop_to_obj(o, host.copybuny_active)
				
			elif not host.copybuny_active and (o is Fighter):
				host.stick_goop_to_obj(o, false)

func on_got_blocked_by(who):
	.on_got_blocked_by(who)
	
	if powered_up:
		if !hit_or_blocked():
			take_poison(who)
			blocked_once = true
		
func hit_or_blocked():
	return hit_once or blocked_once
	
func take_poison(opp):
	if ignore_poison_reduction:
		return
	if not (opp is Fighter):
		return
	var me = opp.opponent
	me.hitlag_ticks += POWER_HITLAG
	opp.hitlag_ticks += POWER_HITLAG
	
	var takes = fixed.round(fixed.mul(str(host.poison_on_slop_stance_enter), POISON_REDUCED_PER_HIT_PERCENT))
	host.apply_poison(-takes)
