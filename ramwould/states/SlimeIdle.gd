extends "res://characters/states/Idle.gd"

func _enter():
	var power = host.has_sloppy_power()
	host.pause_poison_ticks = power
	anim_name = "WaitAnimSloppy" if power else "WaitAnim"
	return ._enter()


func _exit():
	host.pause_poison_ticks = false
