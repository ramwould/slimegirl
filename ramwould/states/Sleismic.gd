extends "res://slimegirl/ramwould/states/SlimeState.gd"

onready var beam1 = $BeamHitbox
onready var beam2 = $BeamHitbox2

const BEAM1_INITIAL_X_POSITION = 91
const BEAM2_INITIAL_X_POSITION = 155
const DISTANCE_MOD = 0.9

var beam1_offset_x = 0
var beam2_offset_x = 0
var beam_dir = 1
var can_lose_shockwave = true

func _enter():
	can_lose_shockwave = true
	
	var offset_x = data.Distance.x*DISTANCE_MOD
	beam_dir = -1 if data.ReverseOrder else 1
	beam1.dir_x = str(2.5*beam_dir)
	beam2.dir_x = str(2.5*beam_dir)
	
	beam1.block_pushback_modifier = str(1.5*beam_dir)
	beam2.block_pushback_modifier = str(1.5*beam_dir)
	beam2.can_shockwave = true
	
	if data.ReverseOrder:
		beam1_offset_x = int(BEAM2_INITIAL_X_POSITION + offset_x)
		beam2_offset_x = int(BEAM1_INITIAL_X_POSITION + offset_x)

	else:
		beam1_offset_x = int(BEAM1_INITIAL_X_POSITION + offset_x)
		beam2_offset_x = int(BEAM2_INITIAL_X_POSITION + offset_x)
		
func _frame_5():
	spawn_slam_fx()
	
func _frame_15():
	spawn_slam_fx()
	can_lose_shockwave = false
	
func get_beam_spawn_position():
	var midtick = (beam2.start_tick+beam1.start_tick)/2
	
	var spawn_pos = Vector2(0, -1000)
	if current_tick < midtick:
		spawn_pos.x = beam1_offset_x
		
	else:
		spawn_pos.x = beam2_offset_x
	
	return spawn_pos

func on_got_blocked():
	if can_lose_shockwave:
		beam2.can_shockwave = false

func on_got_perfect_parried():
	if can_lose_shockwave:
		beam2.can_shockwave = false
	
func can_beam_spawn():
	var midtick = (beam2.start_tick+beam1.start_tick)/2
	if current_tick < midtick:
		return .can_beam_spawn() and host.combo_count > 0
	
	return .can_beam_spawn()
	
func _tick():
	for beams in [beam1, beam2]:
		beams.create_trail = 2 if host.on_fire_this_state else 1
	
func spawn_slam_fx():
	spawn_particle_relative(preload("res://slimegirl/ramwould/FX/SmashFX.tscn"), Vector2(56*host.get_facing_int(), -3))
	host.global_hitlag(2, true)
	host.screen_bump(Vector2.DOWN, 12, 0.15)
	host.play_sound("GroundSlam")
	
