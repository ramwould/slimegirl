extends "res://slimegirl/ramwould/states/SlimeState.gd"

onready var beam1 = $BeamHitbox

var can_fire_beam = false
var offset_x:int = 0
var opponent_center_x = 0

const OFFSET_MULTIPLIER = 0.90

func _enter():
	can_fire_beam = false
	scale_combo_meter_ = true
	if data:
		offset_x = int(data.x * OFFSET_MULTIPLIER)
		
func _frame_2():
	var opponent_center = host.obj_local_center(host.opponent)
	opponent_center_x = (opponent_center.x*host.get_facing_int()) + offset_x
	
func _frame_4():
	
#	if not host.opponent_in_radius():
#	if host.slimetrail_near_obj( host.opponent ):
	if true:
		host.update_data()
		can_fire_beam = true
		
	if _previous_state() and _previous_state() == self:
		scale_combo_meter_ = false
		return
		
	host.start_chernobyl()
	
#	if can_beam_spawn():
#		host.play_sound("ChernobylCharge")

#func _exit():
#	host.stop_sound("ChernobylCharge")
	
func can_beam_spawn():
	return .can_beam_spawn() and can_fire_beam
	
func get_beam_spawn_position():
	return Vector2(opponent_center_x, -1000)

func setup_hitboxes():
	.setup_hitboxes()
	
	earliest_hitbox = 0
