extends "res://slimegirl/ramwould/projectiles/PoisonProjectile.gd"

var set_pos_x = 0
var set_pos_y = 0

func disable():
	
	update_data()
	.disable()
	
	get_fighter().carrotmine = null

func tick():
	.tick()
	
	on_fire = true
	var opp_pos = get_opponent().get_center_position_float()
	
	set_pos_x = int(opp_pos.x)
	set_pos_y = int(opp_pos.y)
	set_pos(set_pos_x, set_pos_y)
