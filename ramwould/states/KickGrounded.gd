extends "res://slimegirl/ramwould/states/SlimeState.gd"

func _enter():
	if data is Dictionary:
		if data.y != 0:
			return "KickGrounded_FU"
