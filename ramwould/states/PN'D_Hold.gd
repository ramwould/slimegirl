extends ThrowState

func _tick():
	var opp = host.opponent
	if current_tick > 11:
		opp.current_state().anim_name = "Knockdown"

func _enter():
	._enter()
	host.pause_poison_ticks = true
	
func _exit():
	._exit()
	host.pause_poison_ticks = false
