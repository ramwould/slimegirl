extends "res://slimegirl/ramwould/states/SlimeState.gd"

export var signaling = false
var zoomed_out = false

func is_usable():
	return .is_usable() and not host.signaling_helix and host.in_meltdown()
	
func _enter():
	zoomed_out = false
	interruptible_on_opponent_turn = false
	if not signaling:
		host.signaling_helix = false
		if host.helix_direction is Vector2:
			if host.is_grounded() and host.helix_direction.y > 0.0:
				host.helix_direction.y = 0.0
		else:
			return fallback_state
		
		for hitbox in get_children():
			if hitbox is host.BEAMBOX:
				hitbox.beam_direction = host.helix_direction
				hitbox.active_ticks = host.helix_duration
		
		zoom_in()
		
	else:
		host.helix_duration = 30
		host.signaling_helix = true
		if data is Dictionary:
			data["Angle"].y *= 0.33
			host.helix_direction = Vector2(1.0, data["Angle"].y)

			host.helix_ticks = data["Arm Time"].count
			host.helix_duration = Utils.map_int(data["Arm Time"].count, host.MIN_HELIX_TICK, host.MAX_HELIX_TICK, 25, 40)
			
func _frame_16():
	if not signaling:
		host.apply_force_relative("-5", "0")
		zoom_out()
		
func _exit():
	if not signaling:
		zoom_out()

func can_beam_spawn():
	var in_meltdown = host.in_meltdown()
	
	return .can_beam_spawn() and in_meltdown

func on_beam_shot():
	var hitbox :Hitbox
	for h in get_children():
		if h is host.BEAMBOX:
			hitbox = h
	
	host.super_effect(super_freeze_ticks_)
	host.hitlag_ticks += hitbox.active_ticks/3
	host.meltdown_ticks = 0
#	if not host.in_chernobyl():
#		host.start_chernobyl()
		
	interruptible_on_opponent_turn = true
	host.helix_direction = null

func zoom_in():
	host.grab_camera_focus()
	host.tween_camera_zoom(1.0, 0.67, Utils.frames(18), Tween.TRANS_CUBIC, Tween.EASE_IN)
	
func zoom_out():
	if not zoomed_out:
		zoomed_out = true
		host.release_camera_focus()
		host.tween_camera_zoom(0.67, 1.0, Utils.frames(10), Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
