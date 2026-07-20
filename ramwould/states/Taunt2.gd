extends "res://slimegirl/ramwould/states/SlimeState.gd"

var endless_ticks = 0
var interrupt_ticks = 0

func _enter():
	endless_ticks = 0
	interrupt_ticks = 0
	
	anim_name = "Hustle"
	ticks_per_frame = 1
	sprite_anim_length = 45
	
	if data is bool:
		if data:
			return "Taunt"
			
func _tick():
	endless_ticks += 1
	interrupt_ticks += 1
	
	if endless_ticks >= 45:
		endless_ticks = 0
		
		anim_name = "HustleLoop"
		ticks_per_frame = 5
		sprite_anim_length = 5
		
		gain_hustle_buff()
		
	if interrupt_ticks >= 45:
		interrupt_ticks = 0
		enable_interrupt()
		
func gain_hustle_buff():
	host.gain_super_meter_raw(host.MAX_SUPER_METER)
	host.unlock_achievement("ACH_HUSTLE", true)

func on_interrupt():
	interrupt_ticks = 0
