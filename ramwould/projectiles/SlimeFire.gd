extends BaseProjectile

onready var fire = $"%fire_particles"
const IS_FIRE = true
var fire_length = 50

func init(pos = null):
	.init(pos)
	add_to_group("SlimeFloor")
	fire.get_child(1).emission_rect_extents.x = fire_length
	fire.get_child(2).emission_rect_extents.x = fire_length
	
func disable():
	.disable()
	fire.stop_emitting()
		
func tick():
	.tick()

func _process(delta):
	fire.modulate = get_fighter().color_else_slime("style_1")

	
func hit_by(hitbox):
	pass
