extends "res://slimegirl/ramwould/states/SlimeState.gd"

var redirect_x = ""
var redirect_y = ""
var detaching = false
const FORCE = "10.0"

export var poison_taken = 0

func _enter():
	var dir = xy_to_dir(data["Direction"].x, data["Direction"].y, FORCE)
	redirect_x = dir.x
	redirect_y = dir.y
	
	detaching = data["DetachOption"]
	pass

func _frame_0():
	if host.lassail_projectile():
		var lassail = host.lassail_projectile()
		lassail.update_data()
		var dir = lassail.get_vel().x
		host.set_facing( fixed.sign(dir) if fixed.sign(dir) != 0 else host.get_facing_int() )

		
func _frame_4():
	if host.lassail_projectile():
		var lassail = host.lassail_projectile()
		lassail.current_state().current_tick -= anim_length-1
		if lassail.current_state().current_tick < 0:
			lassail.current_state().current_tick = 0
		lassail.apply_force(redirect_x, redirect_y)
		host.play_sound("Yank")
		host.add_penalty(5)
		host.apply_poison(-Utils.int_abs(poison_taken))
		
		if detaching:
			detaching = false
			lassail.detach()
			host.use_super_bar()
			host.super_effect(8)
			host.play_sound("Break")
			host.play_sound("Break2")
			host.play_sound("HitBass")
