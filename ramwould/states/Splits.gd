extends "res://slimegirl/ramwould/states/SlimeState.gd"

onready var detection_hitbox = $DetectHitbox
var invulnerable_this_state = false

const LUCKY = preload("res://slimegirl/ramwould/FX/LuckyFX.tscn")

func _frame_0():
	invulnerable_this_state = false
	interruptible_on_opponent_turn = false
	
func _tick():
	if not host.on_slimetrail_this_state:
		host.apply_fric()

	if invulnerable_this_state:
		return
		
	var opponent :Fighter= host.get_opponent()
	if opponent == null:
		return
	
	for hb in opponent.get_active_hitboxes():
		if hb is Hitbox:
			if not detection_hitbox.active:
				continue
			if not hb.active:
				continue
			if not hb.overlaps(detection_hitbox):
				continue
			if opponent.last_object_hit == host.obj_name:
				print("skipped, hit already")
				continue
			if host.initiative and opponent.initiative:
#				hb.deactivate()
				host.start_invulnerability()
				if not host.is_ghost and host.MOD_EXTRA_NOISE:
					host.global_hitlag(3, false)
					host.spawn_particle_effect_relative(LUCKY, Vector2(0, -30))
				invulnerable_this_state = true
				interruptible_on_opponent_turn = true
				host.unlock_achiev("achivement_lucky")
				break
				
func get_hold_restart():
	if invulnerable_this_state:
		return "Wait"
	return .get_hold_restart()

func _frame_5():
	host.colliding_with_opponent = false
	
func _frame_16():
	host.end_invulnerability()
	host.colliding_with_opponent = true
	
func _exit():
	host.end_invulnerability()
	
func detect(obj):
	pass

