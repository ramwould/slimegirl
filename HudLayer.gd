extends "res://ui/HUD/HudLayer.gd"

var p1_poison_prediction_holder
var p2_poison_prediction_holder
var p1_damage_override_pred_amount
var p2_damage_override_pred_amount
var p1_poison_pred_amount
var p2_poison_pred_amount

var accurate_damage = false
var show_damage_prediction = false

const OFFSET = 8

func init(game):
	.init(game)

	var file = File.new()
	var modOptions = null

	if file.file_exists("res://SoupModOptions/ModOptions.gd"):
		modOptions = get_tree().get_root().get_node("Main/ModOptions")

	if modOptions != null:
		if file.file_exists("res://QOL/Options.gd"):
			accurate_damage = modOptions.get_setting("QOL","hp_accurate")
		show_damage_prediction = modOptions.get_setting("SL_settings","show_damage_prediction")
		
	# Damage Number Prediction (copied and modified from Damage Prediction)
	if game.get_player(1).get("charname") and game.get_player(1).charname == "Slimegirl":
		if !p2_poison_prediction_holder == null:
			return
		p2_poison_prediction_holder = Node2D.new()
		p2_poison_prediction_holder.z_index = 1
		$"%P2HealthBar".add_child(p2_poison_prediction_holder)

		if !p2_damage_override_pred_amount == null:
			return
		p2_damage_override_pred_amount = Label.new()
		p2_damage_override_pred_amount.name = "P2HP"
		p2_damage_override_pred_amount.margin_left = 5
		p2_poison_prediction_holder.add_child(p2_damage_override_pred_amount)
	
		if !p2_poison_pred_amount == null:
			return
		p2_poison_pred_amount = Label.new()
		p2_poison_pred_amount.name = "P2PSN"
		p2_poison_pred_amount.margin_left = 5
		p2_poison_pred_amount.rect_position.y += OFFSET
		p2_poison_pred_amount.modulate = Color.yellowgreen
		
		if file.file_exists("res://DamagePrediction/HudLayer.gd"):
			var orig_holder :Label= get("p2_damage_pred_amount")
			orig_holder.visible = false
		
		p2_poison_prediction_holder.add_child(p2_poison_pred_amount)
	
	if game.get_player(2).get("charname") and game.get_player(2).charname == "Slimegirl":
		if !p1_poison_prediction_holder == null:
			return
		p1_poison_prediction_holder = Node2D.new()
		p1_poison_prediction_holder.z_index = 1
		p1_poison_prediction_holder.position.x = 229
		$"%P1HealthBar".add_child(p1_poison_prediction_holder)
		
		if !p1_damage_override_pred_amount == null:
			return
		p1_damage_override_pred_amount = Label.new()
		p1_damage_override_pred_amount.name = "P1HP"
		p1_damage_override_pred_amount.anchor_left = 1
		p1_damage_override_pred_amount.anchor_right = 1
		p1_damage_override_pred_amount.margin_right = -5
		p1_damage_override_pred_amount.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		p1_poison_prediction_holder.add_child(p1_damage_override_pred_amount)
	
		if !p1_poison_pred_amount == null:
			return
		p1_poison_pred_amount = Label.new()
		p1_poison_pred_amount.name = "P1PSN"
		p1_poison_pred_amount.anchor_left = 1
		p1_poison_pred_amount.anchor_right = 1
		p1_poison_pred_amount.margin_right = -5
		p1_poison_pred_amount.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		p1_poison_pred_amount.rect_position.y += OFFSET
		p1_poison_pred_amount.modulate = Color.yellowgreen
		
		if file.file_exists("res://DamagePrediction/HudLayer.gd"):
			var orig_holder :Label= get("p1_damage_pred_amount")
			orig_holder.visible = false
		
		p1_poison_prediction_holder.add_child(p1_poison_pred_amount)

func _physics_process(delta):
	if not show_damage_prediction:
		if p1_poison_pred_amount:
			p1_damage_override_pred_amount.text = ""
			p1_poison_pred_amount.text = ""
		if p2_poison_pred_amount:
			p2_damage_override_pred_amount.text = ""
			p2_poison_pred_amount.text = ""
		return
		
	if is_instance_valid(game):
		if is_instance_valid(game.ghost_game):
			var gg:Game = game.ghost_game
			var p1_ghost = gg.get_player(1)
			var p2_ghost = gg.get_player(2)
			var p1_ghost_health = max(p1_ghost.hp, 0)
			var p2_ghost_health = max(p2_ghost.hp, 0)
			var p1_health = max(p1.hp, 0)
			var p2_health = max(p2.hp, 0)
			
			if gg.get_player(1).get("charname") and gg.get_player(1).charname == "Slimegirl":
				var p2_poison = min(p1_ghost.poison_track, p1_health)
				var p2_damage = (p2_ghost_health - p2_health) + p2_poison
				
				p2_poison_pred_amount.text = str(-p2_poison) if accurate_damage else str(10*(-p2_poison))
				p2_damage_override_pred_amount.text = str(p2_damage) if accurate_damage else str(10*(p2_damage))
				
			if gg.get_player(2).get("charname") and gg.get_player(2).charname == "Slimegirl":
				var p1_poison = min(p2_ghost.poison_track, p1_health)
				var p1_damage = (p1_ghost_health - p1_health) + p1_poison
				
				p1_poison_pred_amount.text = str(-p1_poison) if accurate_damage else str(10*(-p1_poison))
				p1_damage_override_pred_amount.text = str(p1_damage) if accurate_damage else str(10*(p1_damage))
				
		else :
			if p1_poison_pred_amount:
				p1_damage_override_pred_amount.text = ""
				p1_poison_pred_amount.text = ""
			if p2_poison_pred_amount:
				p2_damage_override_pred_amount.text = ""
				p2_poison_pred_amount.text = ""
