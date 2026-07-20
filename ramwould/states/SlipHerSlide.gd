extends "res://slimegirl/ramwould/states/SlimeState.gd"

func _enter():
	host.update_data()
	var vel = host.get_vel()
	if vel and vel.x != "0":
		host.set_facing( fixed.sign(vel.x) )
		
func _frame_0():
	host.play_sound("Slimebrake")

func _frame_2():
	spawn_particle_relative(preload("res://fx/DashParticle.tscn"), Vector2(13*host.get_facing_int(), -5), Vector2.RIGHT*host.get_facing_int())

func _exit():
	host.stop_sound("Slimebrake")
