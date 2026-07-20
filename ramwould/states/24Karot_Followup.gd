extends "res://slimegirl/ramwould/states/SLOPPY STANCE/SlopState.gd"

export var aerial = false
const FRIC = "0.5"
const HIT_FORCE = "-5.5"

func _enter():
	apply_grav = false

func _frame_0():
	_tp_brake()
	
func _frame_2():
	if not aerial:
		host.apply_force_relative("7.5", "0.0")

func _frame_4():
	if aerial:
		apply_grav = true
		host.apply_force_relative("3.0", "-1.0")

func _frame_12():
	if aerial:
		_tp_brake()
		
func _tp_brake():
	host.apply_x_fric(FRIC)
	if aerial:
		host.apply_y_fric(FRIC)
	host.play_sound("TP")

func _on_hit_something(obj, hitbox):
	._on_hit_something(obj, hitbox)
	if aerial:
		host.update_data()
		var vel = host.get_vel()
		host.set_vel(vel.x, HIT_FORCE)

func on_got_blocked():
	if aerial:
		host.update_data()
		var vel = host.get_vel()
		host.set_vel(vel.x, HIT_FORCE)
