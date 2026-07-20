extends ObjectState

onready var hitbox = $Hitbox
const BASE_DAMAGE = 45
export var poison_2_damage_mod = "1.00"

func _enter():
	var slimegirl = host.get_fighter()
	slimegirl.stop_venocache_wind()
	
	var poison_intake = slimegirl.poison_time
	if poison_intake > slimegirl.MAX_VENOCACHE_POISON_INTAKE:
		slimegirl.unlock_achiev("achivement_cache")
		poison_intake = slimegirl.MAX_VENOCACHE_POISON_INTAKE
		
	var added_damage = fixed.round( 
		fixed.mul(
			fixed.mul(
				slimegirl.calculate_poison_damage(),
				str(poison_intake)), 
			poison_2_damage_mod)
		)
		
	var damage = BASE_DAMAGE+added_damage
	hitbox.damage = damage
	hitbox.minimum_damage = damage / 3
	
func _frame_0():
	var slimegirl = host.get_fighter()
	slimegirl.start_venocache()
	
func _frame_5():
	host.disable()
