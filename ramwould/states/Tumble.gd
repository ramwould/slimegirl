extends "res://slimegirl/ramwould/states/SlimeState.gd"

const VEL_MUL = "2"
onready var tumble_sfx = $"%Tumbling"

func _frame_0():
	host.update_data()
	var vel = host.get_vel()
	if _previous_state_name() != "ChargeDashForward":
		host.set_vel(fixed.mul(vel.x, VEL_MUL), fixed.mul(vel.y, VEL_MUL))
	host.play_sound("Tumbling")

func _process(delta):
	var game:Game = Global.current_game
	if game:
		tumble_sfx.stream_paused = game.game_paused
		
func _tick():
	
	if host.is_grounded():

		if current_tick > 12:
			return "TumbleKnockdown"

	var wall = host.touching_which_wall()
	host.update_data()
	if wall == fixed.sign(host.get_vel().x):
		queue_state_change("TumbleSplat", CharacterHurtState.BOUNCE.LEFT_WALL if wall == - 1 else CharacterHurtState.BOUNCE.RIGHT_WALL)

func _exit():
	host.stop_sound("Tumbling")
