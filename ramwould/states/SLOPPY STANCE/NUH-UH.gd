extends "res://slimegirl/ramwould/states/SLOPPY STANCE/SlopState.gd"

func _enter():
	if data is Dictionary:
		if data["y"] == -1:
			return "NUH-UH_U_GRAB"

func _on_hit_something(obj, hitbox):
	._on_hit_something(obj, hitbox)
	
	if obj is Fighter:
		host.disable_goop_visual = true
