extends CharacterState

var game_time = 3600
var state_variables = {}

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
	
func _frame_7():
	host.play_sound("CountdownSound3")
	spawn_countdown(3)

func _frame_42():
	host.play_sound("CountdownSound2")
	host.play_sound("IntroBarrelHit")
	host.play_sound("HitBass")
	host.screen_bump(Vector2.LEFT*host.get_facing_int(), 11.0, Utils.frames(7))
	spawn_countdown(2)
	spawn_particle_relative(preload("res://slimegirl/ramwould/FX/BarrelHitFX.tscn"), Vector2(-21*host.get_facing_int(), -24), Vector2.LEFT*host.get_facing_int())

func _frame_77():
	host.play_sound("CountdownSound1")
	host.play_sound("IntroBarrelHit2")
	host.play_sound("HitBass")
	host.screen_bump(Vector2.RIGHT*host.get_facing_int(), 11.0, Utils.frames(7))
	spawn_countdown(1)
	spawn_particle_relative(preload("res://slimegirl/ramwould/FX/BarrelHitFX.tscn"), Vector2(11*host.get_facing_int(), -14), Vector2.RIGHT*host.get_facing_int())

func _frame_95():
	host.play_sound("IntroBounce")
	host.play_sound("IntroBarrelExplosion")
	host.play_sound("HitBass")
	host.screen_bump(Vector2.UP, 15.0, Utils.frames(15))
	
	var pos = Vector2(26*host.get_facing_int(), -17)+host.get_pos_visual()
	host._spawn_particle_effect(preload("res://slimegirl/ramwould/FX/BarrelExplosionFX.tscn"), pos, Vector2(), host.color_else_slime())
	
	var pos2 = Vector2(26*host.get_facing_int(), -17)
	spawn_particle_relative(preload("res://fx/JumpParticle.tscn"), pos2, Vector2.UP)

func _frame_111():
#	host.play_sound("Landing")
	spawn_particle_relative(preload("res://fx/LandingParticle.tscn"))

func _frame_112():
	host.play_sound("CountdownSoundGo")
	spawn_countdown(0)
	

	


func spawn_countdown(num):
	var rnd_vec:Vector2 = Vector2(-5*host.get_facing_int(), -100)
	match num:
		3:
#			rnd_vec.x = -100*host.get_facing_int()
			spawn_particle_relative(preload("res://slimegirl/ramwould/FX/CountdownFX_Three.tscn"), rnd_vec)
		2:
#			rnd_vec.x = -50*host.get_facing_int()
			spawn_particle_relative(preload("res://slimegirl/ramwould/FX/CountdownFX_Two.tscn"), rnd_vec)
		1:
#			rnd_vec.x = 10*host.get_facing_int()
			spawn_particle_relative(preload("res://slimegirl/ramwould/FX/CountdownFX_One.tscn"), rnd_vec)
		_:
#			rnd_vec.x = 50*host.get_facing_int()
			spawn_particle_relative(preload("res://slimegirl/ramwould/FX/CountdownFX_Go.tscn"), rnd_vec)
			
