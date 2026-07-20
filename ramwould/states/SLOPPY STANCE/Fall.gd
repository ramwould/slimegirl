extends "res://characters/states/Fall.gd"

func _enter():
	var power = host.has_sloppy_power()
	host.pause_poison_ticks = power
	anim_name = "FallSloppy" if power else "Fall"

func _exit():
	host.pause_poison_ticks = false
