extends "res://characters/states/Landing.gd"


func _frame_0():
	._frame_0()
	host.colliding_with_opponent = false
	host.opponent.colliding_with_opponent = false

func _frame_2():
	if host.queued_beam_shockwave:
		var center = host.get_hurtbox_center_float()
		center.y = 0
		host.spawn_shockwave(center, false)

func set_lag(lag = null):
	if lag == null:
		lag = 0
	if data is int:
		lag = data

	anim_length = lag
	iasa_at = lag - 1
	self.lag = lag



func on_got_blocked_by(who):
	if who is Fighter:
		pass

