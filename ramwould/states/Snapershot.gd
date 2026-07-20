extends "res://slimegirl/ramwould/states/SlimeState.gd"

onready var beam = $BeamHitbox

func can_beam_spawn():
	return .can_beam_spawn() and data
#	return .can_beam_spawn() and host.queued_beam_shockwave and host.combo_count > 0

func on_beam_shot():
	host.apply_force_relative("-5.0", "0.0")
	host.use_beam_charge()
	
func _frame_0():
	if data is Dictionary:
		var dir = xy_to_dir(data.x, data.y)
		beam.beam_direction.x = float(dir.x)*host.get_facing_int()
		beam.beam_direction.y = float(dir.y)
		beam.dir_x = fixed.mul(dir.x, str(host.get_facing_int()))
		beam.dir_y = fixed.mul(dir.y, "0.5")
		
	extra_parrylag_with_distance = host.queued_beam_shockwave
	
func _frame_2():
	host.apply_force_relative("4.0", "0")
