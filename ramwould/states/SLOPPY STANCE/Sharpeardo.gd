extends "res://slimegirl/ramwould/states/SLOPPY STANCE/SlopState.gd"

const FORCE = "5.0"
onready var hitbox_far = $Hitbox
onready var hitbox_close = $Hitbox2

func _frame_5():
	host.sprite.hide()
	host.sharpeardo.show()
	if data is Dictionary:
		var dir = xy_to_dir(data.x, data.y, FORCE)
		host.apply_force(dir.x, dir.y)
		
		var rotation_vector := Vector2(data.x * host.get_facing_int(), data.y).normalized()
		host.sharpeardo.rotation = rotation_vector.angle()
		
		dir = xy_to_dir(data.x, data.y)
		hitbox_close.dir_x = fixed.mul(dir.x, str(host.get_facing_int()) )
		hitbox_close.dir_y = dir.y
		hitbox_far.dir_x = hitbox_close.dir_x
		hitbox_far.dir_y = hitbox_close.dir_y
		
		var offset = -14
		var hitbox_pos = fixed.vec_mul(dir.x, dir.y, "35")
		hitbox_far.x = fixed.round(hitbox_pos.x) * host.get_facing_int()
		hitbox_far.y = fixed.round(hitbox_pos.y) + offset
		
		hitbox_pos = fixed.vec_mul(dir.x, dir.y, "16")
		hitbox_close.x = fixed.round(hitbox_pos.x) * host.get_facing_int()
		hitbox_close.y = fixed.round(hitbox_pos.y) + offset
		
func _frame_17():
	host.sprite.show()
	host.sharpeardo.hide()
	
func _exit():
	host.sprite.show()
	host.sharpeardo.hide()
