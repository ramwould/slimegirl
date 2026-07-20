extends "res://slimegirl/ramwould/states/SlimeState.gd"

var y_speed = "0"
onready var hitbox = $Hitbox

const J_POWER = "7.5"
const MAX_DATA = "100"
const F_POWER = "2.5"

func _enter():
	iasa_on_hit = 16
	y_speed = "0"
	if data:
		y_speed = fixed.div( str(-data.x), fixed.div(MAX_DATA,J_POWER) )

	hitbox.hits_vs_grounded = false
	if data.x == 0:
		hitbox.hits_vs_grounded = true
		iasa_on_hit = -1
		
func _frame_2():
	host.apply_force_relative(F_POWER, fixed.add(y_speed,"-3.5"))
	spawn_particle_relative(preload("res://fx/JumpParticle.tscn"), Vector2(), Vector2.UP)
	host.play_sound("IntroBounce")

func _frame_12():
	host.apply_force_relative("2", "0")
	
func _on_hit_something(obj, hitbox):
	._on_hit_something(obj, hitbox)
	
	host.apply_y_fric("0.75")
	
