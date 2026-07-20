extends ThrowState

const IMPALE_FX = preload("res://slimegirl/ramwould/FX/SmashFX.tscn")
const MINE_SCENE = preload("res://slimegirl/ramwould/projectiles/CarrotMine.tscn")

func _enter():
	._enter()
	interruptible_on_opponent_turn = false
	
func _frame_11():
	host.tween_camera_zoom(0.50, 0.80, 0.15, Tween.TRANS_CIRC, Tween.EASE_OUT)
	host.enable_beam_charge()
	spawn_particle_relative(IMPALE_FX, Vector2(10, 0))
	
	var mine :BaseProjectile= host.spawn_object(MINE_SCENE, 0, 0)
	mine.z_index = 50
	host.carrotmine = mine.name
	
func _frame_16():
	host.move_directly_relative(4, 0)
	
func _frame_20():
	host.move_directly_relative(8, 0)

func _frame_24():
	host.opponent.current_state().anim_name = "Grabbed"
	host.move_directly_relative(8, 0)
	
func _frame_29():
	host.move_directly_relative(13, 0)
	host.apply_force_relative("1.5", "0")

func _frame_35():
	host.tween_camera_zoom(0.80, 0.99, 0.6, Tween.TRANS_BACK, Tween.EASE_OUT)
	
	host.play_sound("TP")
	if host.opponent.current_state().state_name == "WallSlam":
		host.reset_momentum()
		host.apply_force_relative("-9", "0")
		queue_state_change("Wait")
		
func _frame_39():
	interruptible_on_opponent_turn = true
	

