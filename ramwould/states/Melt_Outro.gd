extends "res://slimegirl/ramwould/states/SlimeState.gd"


func _enter():
	if air_type == AirType.Aerial:
		host.airmelt_ticks = anim_length
		host.airmelt_max = anim_length
		host.airmelt.show()
		host.sprite.hide()
		
	host._spawn_particle_effect(
		preload("res://slimegirl/ramwould/FX/MeltFX.tscn"), 
		host.get_hurtbox_center_float(), 
		Vector2(), 
		host.color_else_slime()
		)
	
	if _previous_state() and _previous_state().get("no_invulnerability") is bool:
		if _previous_state().get("no_invulnerability") == false:
			host.start_invulnerability()
	
func _frame_1():
	host.end_invulnerability()

func _tick():
	host.airmelt.scale = Vector2.ONE * (host.airmelt_length_ratio)
	
func _exit():
	host.airmelt.hide()
	host.airmelt.scale = Vector2.ONE
	host.sprite.show()
