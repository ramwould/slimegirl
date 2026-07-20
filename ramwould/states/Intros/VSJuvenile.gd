extends CharacterState

var game_time = 3600
var state_variables = {}

var dist = 0
const PUSHD_BACK_DIST = -55

func _enter():
	game_time = Global.current_game.time
	
func _frame_0():
	for v in host.opponent.state_variables:
		state_variables[v] = host.opponent.get(v)
	
	dist = PUSHD_BACK_DIST + (Global.current_game.char_distance*2)
	host.move_directly_relative( dist, 0 )

func _frame_54():
	var offset = host.get_pos_visual()
	var amount = 4.0
	for i in range(amount):
		host.create_speed_after_image(host.color_else_slime("style_2"), Utils.frames(4), offset)
		offset.x += (dist / amount)*host.get_facing_int()
	
	host.move_directly_relative( -dist, 0)
	host.play_sound("TP")
	
	spawn_particle_relative(preload("res://fx/DashParticle.tscn"), Vector2(7*host.get_facing_int(), -2), Vector2.RIGHT*host.get_facing_int())
	
	
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
	

	if current_tick > animation_loop_start:
		if current_tick % 8 == 0:
			host.play_sound("Whiff")
