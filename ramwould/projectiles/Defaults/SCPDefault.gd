extends DefaultFireball

onready var hitbox = $Hitbox

func _tick():
	._tick()
	
	hitbox.dir_x = str(move_x)
	hitbox.dir_y = str(move_y)
	
	if hitbox.enabled:
#	if current_tick % (hitbox.loop_active_ticks+hitbox.loop_inactive_ticks) == 0:
		spawn_particle_relative(preload("res://slimegirl/ramwould/FX/CrackleFX.tscn"), Vector2(), Vector2())
		
