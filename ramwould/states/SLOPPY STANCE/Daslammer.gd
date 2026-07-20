extends "res://slimegirl/ramwould/states/SLOPPY STANCE/SlopState.gd"

onready var hitbox = $Hitbox

func _enter():
	if hitbox.hit_bass_sound_player:
		hitbox.hit_bass_sound_player.pitch_variation = 0.0
	
func on_got_blocked_by(who):
	.on_got_blocked_by(who)
	
	if who is Fighter:
		if who.is_grounded():
			who.move_directly(0, -1)
			who.apply_force(0, -5)
			who.set_grounded( false )
