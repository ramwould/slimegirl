extends "res://slimegirl/ramwould/states/SlimeState.gd"

func _enter():
	if data and data is Dictionary:
		if data.has("proj_immunity"):
			host.start_projectile_invulnerability()

func _frame_6():
	host.end_projectile_invulnerability()
