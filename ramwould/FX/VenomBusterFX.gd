extends ParticleEffect

#negative start_tick indicate startup time
var start_tick :int= 0
var grounded = false
onready var tint :Node2D= $"%Tint"

onready var beam :Node2D= $"%Beam"
onready var beam2 :Node2D= $"%Beam2"
onready var beam_base :Node2D= $"%BeamBase"
onready var beam_base2 :Node2D= $"%BeamBase2"

onready var SMASH :CPUParticles2D= $"%Smash"

const BOUNDING_WIDTH = 500

func _ready():
	line_update()
	
func tick():
	.tick()
	start_tick+=1
	line_update()
	
func line_update():
	beam.time_alive = Utils.frames( Utils.int_abs(start_tick) )
	beam.modulate.a = 0.25 if start_tick<=0 else 1.0
	beam_base.time_alive = beam.time_alive
	beam_base.modulate.a = beam.modulate.a
	
	beam2.time_alive = 			beam.time_alive
	beam2.modulate.a = 			beam.modulate.a
	beam2.real_ticks = 			start_tick
	beam_base2.time_alive = 	beam.time_alive
	beam_base2.modulate.a = 	beam.modulate.a
	beam_base2.real_ticks = 	start_tick
	
	SMASH.position.x = beam.end_position.x
	if grounded:
		$halo1.position.x = beam.end_position.x - 40
		$halo2.position.x = beam.end_position.x - 80

	for node in [$CPUParticles2D, $CPUParticles2D2, $CPUParticles2D3, SMASH, $halo1, $halo2]:
		node.modulate = tint.modulate
		if start_tick > 4:
			node.visible = true
		
func _process(delta: float) -> void:
	update()
	
