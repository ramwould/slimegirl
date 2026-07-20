extends BaseProjectile

onready var bubbles = $"%SlimeBubbles"
const IS_FIRE = false
var slime_length = 50
var slime_lifetime_extra = 0

func init(pos = null):
	.init(pos)
	get_fighter().connect("chernobyl_fire", self, "burn_trail")
	add_to_group("SlimeFloor")
	
	
func disable():
	.disable()
	bubbles.stop_emitting()
	get_fighter().trail_array.erase(name)
		
func burn_trail():
	if not disabled:
		var fire = spawn_object(preload("res://slimegirl/ramwould/projectiles/SlimeFire.tscn"), 0, 0, true, null, true)
		fire.fire_length = slime_length
		disable()

func tick():
	.tick()
	
	if not get_fighter().obj_in_radius(self):
		state_tick()

func _process(delta):
	bubbles.modulate = get_fighter().color_else_slime("outline")
	bubbles.modulate.a = 1.0 * get_fighter().MOD_BUBBLES_OPACITY_MULT
	bubbles.get_child(1).emission_rect_extents.x = slime_length
	
func hit_by(hitbox):
	pass
