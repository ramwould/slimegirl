extends CharacterState

var game_time = 3600
var state_variables = {}

const SLAM_FX = preload("res://slimegirl/ramwould/FX/SmashFX.tscn")

func _enter():
	game_time = Global.current_game.time
	
func _frame_0():
	for v in host.opponent.state_variables:
		state_variables[v] = host.opponent.get(v)

func _frame_44():
	host.play_sound("TP")
	
func _frame_69():
	host.play_sound("Whiff")
	host.play_sound("GroundSlam")
	spawn_particle_relative(SLAM_FX, Vector2(30, 0))
	host.screen_bump(Vector2(), 12.0, Utils.frames(18))
	
func _frame_80():
	host.play_sound("Swish")

func _frame_101():
	host.play_sound("Whip")
	
func _tick():
	host.penalty = 0
	host.opponent.penalty = 0
	var game = Global.current_game
	if(game.time-game.current_tick<game_time):
		game.time+=1
	if host.opponent.stance != "Intro" and current_tick < 119:
		for v in state_variables.keys():
			host.opponent.set(v,state_variables[v])
		host.opponent.hitlag_ticks = 1
		host.opponent.state_interruptable = false
	if current_tick == 119:
		host.opponent.state_interruptable = true
		host.state_interruptable = true
		host.stance = "Normal"
		return "Wait"
