extends CharacterState

var game_time = 3600
var state_variables = {}

const HEAL_AMOUNT = 1

func _enter():
	game_time = Global.current_game.time
	
func _frame_0():
	for v in host.opponent.state_variables:
		state_variables[v] = host.opponent.get(v)

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

func _frame_17():
	host.play_sound("Whiff")
	host.play_sound("Swish")

func _frame_24():
	host.play_sound("TP")

func _frame_34():
	host.play_sound("Whiff")
	host.play_sound("Swish")

func _frame_41():
	host.play_sound("TP")

func _frame_54():
	host.play_sound("Whiff")
	host.play_sound("Swish")

func _frame_62():
	host.play_sound("TP")

func _frame_92():
	host.play_sound("EatSomething")
	
	if not host.one_hit_ko:
		host.hp += HEAL_AMOUNT
	
func _frame_111():
	host.play_sound("GoopApplied2")
	
	
	
