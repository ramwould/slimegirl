extends ObjectState

const DAMAGE = 2
export  var width = 100
export  var lifetime = 60

func _tick():
	
	var fighter = host.get_fighter()
	var opponent = host.get_opponent()
	
	var local_pos = host.obj_local_pos(opponent).x
	if opponent != null and Utils.int_abs(local_pos) < host.fire_length+15:
		if not opponent.invulnerable and opponent.is_grounded():
			if not (opponent.current_state().get("IS_JUMP")):
				fighter.opponent_on_fire = true
				if opponent.get("on_fire_this_state"):
					opponent.opponent_on_fire = true
				
	local_pos = host.obj_local_pos(fighter).x
	if fighter != null and Utils.int_abs(local_pos) < host.fire_length+15:
		if fighter.is_grounded():
			if not (fighter.current_state().get("IS_JUMP")):
				fighter.on_fire_this_state = true

	if current_tick % 20 == 0:
		host.play_sound("Fire")
		
	host.set_y(0)
	if current_tick >= lifetime:
		host.disable()
