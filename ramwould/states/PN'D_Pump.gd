extends ThrowState

const POISON_TICKS_APPLIED = 30
const MIN_PUMP_TIME = 7.0
const MAX_PUMP_TIME = 18.0

export var pump = true

func _enter():
	host.pause_poison_ticks = true
	
	var opp = host.opponent
	opp.current_state().anim_name = "Knockdown" if pump else "Grabbed"
	if pump:
		anim_length = int( Utils.map(float(host.pnd_pump_times), 0.0, float(host.PND_PUMP_MAX), MIN_PUMP_TIME, MAX_PUMP_TIME) )
		if super_level_ > 0:
			fallback_state = state_name if (host.supers_available > 0 and host.pnd_pump_times <= host.PND_PUMP_MAX) else "PN'D_Dump"
			
		else:
			if host.supers_available > 0:
				interrupt_into.append("PN'D_Pump")
	
func _frame_6():
	if pump:
		host.screen_bump(Vector2.DOWN, 16, 0.2)
		var multiplier = 1
		
		if ("Followup" in state_name):
			multiplier = 2
			host.enable_beam_charge()
			host.play_sound("GoopApplied")
			
		var poison = POISON_TICKS_APPLIED*multiplier
		host.apply_poison(poison)
		spawn_particle_relative(preload("res://slimegirl/ramwould/FX/AssimilatedObjectFX.tscn"), Vector2.ZERO, Vector2.UP)
		if super_level_ > 0:
			host.pnd_pump_times += 1
			pass
		
func _exit():
	host.pause_poison_ticks = false
	
	if not pump:
#		host.stick_goop_to_obj(host.opponent, true)
		host.pnd_pump_times = 0
	else:
		interrupt_into.clear()
