extends "res://characters/states/Dash.gd"

var walkvar = 2

func spawn_dash_particle():
	if not same_as_last_state:
		.spawn_dash_particle()

func spawn_enter_particle():
	if not same_as_last_state:
		.spawn_enter_particle()

func play_enter_sfx():
	if not same_as_last_state:
		.play_enter_sfx()

func _enter():
	reset_momentum = _previous_state_name() != "ChargeDashForward"
		
	._enter()
	
	if dir_x == 1 and (data == null):
		data = {"x": 100}
	
	if not host.sprite.is_connected("frame_changed", self, "on_sprite_frame_changed"):
		host.sprite.connect("frame_changed", self, "on_sprite_frame_changed")

func on_sprite_frame_changed():
	if not active:
		return 
	if walkvar == 2:
		walkvar = 1
	else:
		walkvar = 2
	
	if host.sprite.frame == 1:
		host.play_sound("SpongeWalk_%s" % walkvar)

func get_hold_restart():
	if (data and data.has("charged")):
		return "ChargeDashForward"
	return .get_hold_restart()
