extends "res://slimegirl/ramwould/projectiles/PoisonProjectile.gd"

func tick():
	.tick()
	var center = get_fighter().radius_center()
	set_pos(int(center.x), int(center.y))
	update_data()
	
	for hitbox in hitboxes:
		hitbox.host = get_fighter()

func _on_hit_something(obj, hitbox):
	._on_hit_something(obj, hitbox)
	
	var state = get_fighter().current_state()
	if state.has_method("on_venocache_hit"):
		state.call("on_venocache_hit")

