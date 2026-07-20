extends "res://slimegirl/ramwould/states/SlimeState.gd"

var clones_to_explode = []
var set_tick = false
var consumed_levels = false

onready var meltdown_hit := $Hitbox

func copy_to(s):
	.copy_to(s)
	s.clones_to_explode = clones_to_explode.duplicate(true)
	
func _enter():
	set_tick = false
	consumed_levels = false
	clones_to_explode.clear()
	if (data is Dictionary):
		for button in data.values():
			if (button is Dictionary) and button.get("enabled",false):
				clones_to_explode.append(button["index"])

func _frame_5():
	if host.initiative:
		host.has_hyper_armor = true

	if not clones_to_explode.empty():
		host.play_sound("ButtonPress2")	
		host.try_explode_clone(clones_to_explode)
		
func _frame_15():
	host.has_hyper_armor = false

func _frame_16():
	dash()
	
func _exit():
	hit_cancel_exceptions.clear()

func on_got_hit():
	if not set_tick:
		host.add_pushback("2")
	set_counter_tick()

func detect(obj):
	if obj is Fighter:
		set_counter_tick()
		
func on_got_blocked_by(who):
	if who is Fighter:
		start_meltdown()
		
func _on_hit_something(obj, hitbox):
	._on_hit_something(obj, hitbox)
	
	if obj is Fighter:
		start_meltdown()
		
func start_meltdown():
	consume_levels()
	host.start_meltdown()
	
func dash():
	host.reset_momentum()
	host.update_data()
	host.update_facing()
	host.apply_force_relative(15, 0)
	
func set_counter_tick():
	if set_tick:
		return
	set_tick = true
	current_tick = meltdown_hit.start_tick - 5

func consume_levels():
	if consumed_levels:
		return
	consumed_levels = true
	
	var levels = super_level_
	host.combo_supers += 1
	host.super_effect(10)
		
	for i in range(levels):
		host.use_super_bar()
