extends PlayerInfo

onready var added_poison = $"%PoisonAdded"
onready var total_poison = $"%PoisonTotal"
onready var total_poison_replay = $"%PoisonTotalReplay"

func _ready():
	pass
	
func set_fighter(fighter):
	.set_fighter(fighter)
	
	$"%HOLDER OF ICONS".rect_position.x = 78
	if player_id == 2:
		$"%MeterContainer".alignment = HBoxContainer.ALIGN_END
		$"%HOLDER OF ICONS".rect_position.x = -50
		
	if fighter:
		$"%AuraButton".pressed = fighter.modMain.get("show_aura_in_match_p%s" % player_id)
		
func on_position_changed(under):
	.on_position_changed(under)
	
	if fighter:
		$"%AuraButton".pressed = fighter.modMain.get("show_aura_in_match_p%s" % player_id)
	
func _process(delta):
	total_poison.text = "Active Poison: %sf" % fighter.poison_time
	total_poison_replay.text = "Poison: %sf" % fighter.poison_time
	added_poison.text = "Added Poison: %sf" % fighter.poison_gained_this_turn
			
	total_poison.hide()
	total_poison_replay.hide()
	added_poison.hide()
	var game:Game = Global.current_game
	if game.game_paused:
		total_poison.show()
		if fighter.poison_gained_this_turn != 0:
			added_poison.show()
			
	else:
		total_poison_replay.show()
		

	if fighter:
		fighter.modMain.set("show_aura_in_match_p%s" % player_id, $"%AuraButton".pressed)
		
	update()
	
func _draw():
	total_poison.modulate = Color.white
	if fighter.in_meltdown():
		total_poison.modulate = Color.red
		
	total_poison_replay.modulate = total_poison.modulate
	
	if sign(fighter.poison_gained_this_turn) > 0:
		added_poison.modulate = Color.greenyellow
	else:
		added_poison.modulate = Color.crimson
	
	var assimilate_color:Color = fighter.color_else_slime("style_1")
	var meltdown_color:Color = fighter.color_else_slime("style_2")
	
	var tm = meltdown_color
	tm.a = 0.25
	var mix_color_left:Color = assimilate_color.blend(tm)
	tm.a = 0.5
	var mix_color_mid:Color = assimilate_color.blend(tm)
	tm.a = 0.75
	var mix_color_right:Color = assimilate_color.blend(tm)
	
	$"%LeftEdge".modulate = assimilate_color if player_id == 1 else meltdown_color
	$"%MidLeftEdge".modulate = mix_color_left if player_id == 1 else mix_color_right
	$"%MidEdge".modulate = mix_color_mid
	$"%MidRightEdge".modulate = mix_color_right if player_id == 1 else mix_color_left
	$"%RightEdge".modulate = meltdown_color if player_id == 1 else assimilate_color
	
	$"%IconChernobyl".modulate.a = 1.0 if not fighter.in_chernobyl() else 0.5
	$"%IconSnagtrik".modulate.a = 1.0 if fighter.snag_cooldown <= 0 else 0.5
	$"%IconVenobuster".modulate.a = 1.0 if fighter.venobuster_ticks <= 0 else 0.5
	$"%IconBeamCharge".modulate.a = 1.0 if fighter.queued_beam_shockwave else 0.5
	$"%IconSnapCracklPop".modulate.a = 1.0 if fighter.snapcracklpop_ticks <= 0 else 0.5
	
	
	
