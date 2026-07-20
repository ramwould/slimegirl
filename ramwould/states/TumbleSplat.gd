extends "res://characters/states/WallSlam.gd"

func _enter():
	._enter()

	host.unlock_achiev("achivement_tumble")
