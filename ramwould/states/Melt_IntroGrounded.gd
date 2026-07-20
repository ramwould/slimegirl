extends "res://slimegirl/ramwould/states/SlimeState.gd"

const TELEPORT_COMBO_TICK_REDUCTION = 7
const TELEPORT_SLOPDROP_TICK_REDUCTION = 4
var to_first = false
var to_lassail = false
var no_invulnerability = false

func _enter():
	to_first = false
	no_invulnerability = false
	if data:
		to_first = data.get("First")
		to_lassail = data.get("Lassail")
		
	if air_type == AirType.Aerial:
		host.airmelt_ticks = anim_length
		host.airmelt_max = anim_length
		host.airmelt.show()
		host.sprite.hide()
	fallback_state = "Melt_Outro"
	
	if _previous_state() and _previous_state_name() == "SlopdropLanding":
		current_tick = TELEPORT_SLOPDROP_TICK_REDUCTION
		no_invulnerability = true
		
	elif host.combo_count > 0:
		current_tick = TELEPORT_COMBO_TICK_REDUCTION
		no_invulnerability = true

func _frame_7():
	if not no_invulnerability:
		host.start_invulnerability()
		
func _tick():
	var center_x = 0
	var center_y = 0
	
	if host.can_teleport_or_lassail() and not host.can_teleport():
		to_lassail = true
		
	host.airmelt.scale = Vector2.ONE * (1.0-host.airmelt_length_ratio)
	if current_tick >= anim_length:
		host.update_slime_trail_pos()
		center_x = host.first_trail_center_x if to_first else host.last_trail_center_x

		host._spawn_particle_effect(
			preload("res://slimegirl/ramwould/FX/MeltFX.tscn"), 
			host.get_hurtbox_center_float(), 
			Vector2(), 
			host.color_else_slime()
			)
		var lassail:BaseProjectile = host.lassail_projectile()
		if to_lassail:
			if lassail:
				lassail.update_data()
				var lass_center = lassail.get_hurtbox_center()
				var vel = lassail.get_vel()
				
				center_x = (lass_center.x) - host.hurtbox.width
				center_y = (lass_center.y-13) + host.hurtbox.height
				fallback_state = "Melt_OutroAerial"
			
				host.set_vel(fixed.div(vel.x,"2"), fixed.div(vel.y,"2"))

				lassail.disable()
				
			else:
				host.update_data()
				var lass_center = host.get_hurtbox_center()
				center_x = lass_center.x
				center_y = lass_center.y-13

		queue_state_change(fallback_state)
		host.set_pos(center_x, center_y)
		host.add_penalty(5)
		return

func _exit():
	if air_type == AirType.Aerial:
		host.airmelt.hide()
		host.airmelt.scale = Vector2.ONE
		host.sprite.show()
