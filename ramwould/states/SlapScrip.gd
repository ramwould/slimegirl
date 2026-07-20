extends "res://slimegirl/ramwould/states/SlimeState.gd"

onready var hitbox = $Hitbox

const DEFAULT_ENTER_SPEED = "3.5"
const FOLLOWUP_ENTER_SPEED = "2.4"

const MIN_HITLAG = 0
var DEFAULT_HITLAG = 0

func setup_hitboxes():
	.setup_hitboxes()
	
	DEFAULT_HITLAG = hitbox.hitlag_ticks

func _enter():
	if name == "Slap":
		if _previous_state_name() == "Slap":
			return "SlapAgain"
	
	if not (_previous_state_name() in ["Slap", "SlapAgain"]):
		host.slap_uses = host.MAX_SLAP_USES

func apply_enter_force():
	enter_force_speed = DEFAULT_ENTER_SPEED
	if host.slap_uses < host.MAX_SLAP_USES:
		enter_force_speed = FOLLOWUP_ENTER_SPEED
		
	.apply_enter_force()
	
func _frame_0():
	
	var d = fixed.div(str(host.slap_uses), str(host.MAX_SLAP_USES))
	var new_hitlag = fixed.mul(d, fixed.sub(str(DEFAULT_HITLAG), str(MIN_HITLAG)))
	new_hitlag = fixed.add(new_hitlag, str(MIN_HITLAG))
	
	hitbox.disable_collision = host.slap_uses == host.MAX_SLAP_USES
	hitbox.hitlag_ticks = fixed.round(new_hitlag)
#	hitbox.victim_hitlag = fixed.round(new_hitlag)

func _on_hit_something(obj, hitbox):
	._on_hit_something(obj, hitbox)
	if obj is Fighter:
		if name == "Slap":
			host.stack_move_in_combo("SlapAgain")
		if name == "SlapAgain":
			host.stack_move_in_combo("Slap")
		
		if host.slap_uses < host.MAX_SLAP_USES / 2:
			host.enable_beam_charge()
			
func _exit():
	if hit_fighter:
		host.slap_uses -= 1
		if host.slap_uses > host.MAX_SLAP_USES:
			host.slap_uses = host.MAX_SLAP_USES
		if host.slap_uses < 0:
			host.slap_uses = 0
