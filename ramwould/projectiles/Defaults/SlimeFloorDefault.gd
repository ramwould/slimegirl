extends ObjectState

export  var lifetime = 60
const MULTIPLIER = "100"

func _tick():
	host.set_y(0)
	var slimegirl = host.get_fighter()
	
	if current_tick >= get_total_lifetime():
		host.disable()
	
	if (slimegirl.current_state().state_name.begins_with("Goodrider")) and current_tick > (get_total_lifetime()/2):
		current_tick -= 1
	
	else:
		var fixed_d = fixed.div(str(current_tick+$"%SlimeDraw".offset), str(get_total_lifetime()))
		if fixed.lt(fixed_d,"0.0"): fixed_d = "0.0"
		if fixed.gt(fixed_d,"1.0"): fixed_d = "1.0"
		
		var x_length:int = $"%SlimeDraw".x_scale.interpolate(float(fixed_d)) * int(MULTIPLIER)
		var size:int = x_length * (host.slime_length - 5)
		
		var slimegirl_occupies_space = false
		while x_length == int(MULTIPLIER) and current_tick > (get_total_lifetime()/2):
			slimegirl_occupies_space = slimegirl.is_grounded() and fixed.lt( slimegirl.obj_distance(host), fixed.div(str(size), MULTIPLIER) )
			if slimegirl_occupies_space:
				current_tick = (get_total_lifetime()/2)
			else: break
			
func get_total_lifetime()->int:
	return host.slime_lifetime_extra + lifetime
