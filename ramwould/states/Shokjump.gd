extends "res://slimegirl/ramwould/states/SlimeState.gd"

const SHORT_HOP_SPEED = "-3.7"

func _enter():
	pass

func _frame_0():
	host.apply_force_relative("1", SHORT_HOP_SPEED)
	
func _frame_3():
	host.start_aerial_attack_invulnerability()

func _frame_6():
	host.end_aerial_attack_invulnerability()
