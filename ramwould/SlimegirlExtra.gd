extends PlayerExtra

onready var copybuny_button = $"%Copybuny"
onready var copybuny_plot = $"%Clone Position"
onready var noxipaste_options := $"%Copybuny Index"
onready var noxipaste_flip_button = $"%Clone Flipped"
onready var noxipaste_detonate_button = $"%Clone Detonate All"
onready var detach_button = $"%Detach"
onready var yank_button = $"%Yank"
onready var friction_button = $"%FrictionCtrl"

var opponent_on_ground = false
var opponent_on_air = false

var the_watch_int = 0
var initializing = false

const SUPER_COLOR := Color("f49fff")

func _ready():
	$"%Copybuny".connect("toggled", self, "_on_copybuny_toggled")
	$"%Clone Detonate All".connect("toggled", self, "_on_detonate_toggled")
	
	$"%Detach".connect("toggled", self, "_on_detach_toggled")
	$"%Yank".connect("toggled", self, "_on_yank_toggled")
	
	Utils.pass_signal_along(noxipaste_flip_button, self, "pressed", "data_changed")
	Utils.pass_signal_along(copybuny_plot, self, "data_changed")
	Utils.pass_signal_along(noxipaste_options, self, "data_changed")
	Utils.pass_signal_along(friction_button, self, "pressed", "data_changed")


func _on_copybuny_toggled(button_pressed):
	copybuny_plot.visible = button_pressed
	noxipaste_detonate_button.set_pressed_no_signal(false)
	emit_signal("data_changed")

func _on_detonate_toggled(button_pressed):
	copybuny_button.set_pressed_no_signal(false)
	emit_signal("data_changed")

func _on_yank_toggled(button_pressed):
	if button_pressed:
		detach_button.set_pressed_no_signal( false )
	emit_signal("data_changed")
	
func _on_detach_toggled(button_pressed):
	if button_pressed:
		yank_button.set_pressed_no_signal( false )
	emit_signal("data_changed")
	
func get_extra():
	var dic_of_time = Time.get_time_dict_from_system()
	the_watch_int = int(
		dic_of_time["second"]+\
		(dic_of_time["minute"]*60)+\
		(dic_of_time["hour"]*3600)
	)
	
	if initializing:
		return { "current_time":the_watch_int }
		
	return {
		"create_clone":button_active_and_pressed(copybuny_button),
		"create_clone_xy":copybuny_plot.get_data(),
		
		"teleporting":list_valid(),
		"flip_teleport":list_valid() and button_active_and_pressed(noxipaste_flip_button),
		"detonate_all_clones":button_active_and_pressed(noxipaste_detonate_button),
		
		"get_clone_index":noxipaste_options.current_selected()-1,
		"detach":button_active_and_pressed(detach_button),
		"yank":button_active_and_pressed(yank_button),
		
		"input_aerial":opponent_on_air,
		"input_grounded":opponent_on_ground,
		
		"slime_friction":button_active_and_pressed(friction_button),
		
		"current_time":the_watch_int,
	}


func show_options():

	
	if attached_to_clone(): 
		$"%Detach".text = "Detach (%sf)" % str(fighter.CLONE_DETACH_EXPLODE_DELAY)
	else: $"%Detach".text = "Detach"
	
	setup_buttons()

func reset():
	.reset()
	opponent_on_air = false
	opponent_on_ground = false
	
	setup_buttons()
	
func setup_buttons():
	update_clone_index()
	
	copybuny_button.hide()
	copybuny_button.disabled = false
	copybuny_button.set_pressed_no_signal(false)
	copybuny_button.modulate = Color.white if fighter.can_get_freebie_clone() else SUPER_COLOR
	
	copybuny_plot.hide()
	copybuny_plot.reset()
	
	noxipaste_flip_button.visible = false
	noxipaste_flip_button.set_pressed_no_signal(false)
	
	noxipaste_detonate_button.visible = false
	noxipaste_detonate_button.set_pressed_no_signal(false)
	
	var noxipaste_disabled = false
	if fighter.current_state():
		noxipaste_disabled = is_defense_state( fighter.current_state() )
		
		for child in fighter.current_state().get_children():
			if "IgnoreGoopRule" in child.name:
				noxipaste_disabled = false
			if "NoNoxipaste" in child.name:
				noxipaste_disabled = true
				
	noxipaste_options.visible = true
	noxipaste_options.disabled = noxipaste_disabled or should_not_noxipaste()
	noxipaste_options.select_button(0)
	
	detach_button.visible = fighter.is_gooped()
	yank_button.visible = detach_button.visible
	
	detach_button.set_pressed_no_signal(false)
	yank_button.set_pressed_no_signal( false )
	
	if not fighter._can_yank_self():
		yank_button.disabled = true
		
		
	disable_on_block()
	$"%Clone Label".visible = list_valid()
	
	friction_button.visible = fighter.object_on_trail(fighter)
	friction_button.set_pressed_no_signal( fighter.increased_friction )
	
func update_selected_move(move_state):
	.update_selected_move(move_state)
	
	update_clone_index()
	

	copybuny_button.visible = false
	detach_button.disabled = false
	copybuny_plot.limit_angle = (fighter.lassail_projectile() != null) and fighter.lassail_connected()
	if move_state:
		var defense_or_hurt = is_defense_state(move_state)
		
		var buttons = [copybuny_button, noxipaste_detonate_button, detach_button, yank_button, noxipaste_options]
		for button in buttons:
			button.disabled = defense_or_hurt
			
		for nodes in move_state.get_children():
			if nodes is HostCommand:
				copybuny_button.visible = ("Copybuny" in nodes.name)
					
			if ("IgnoreGoopRule" in nodes.name):
				copybuny_button.disabled = false
	
	if fighter.supers_available < fighter.COPYBUNY_SUPER_COST and not fighter.can_get_freebie_clone():
		copybuny_button.disabled = true
	
	var can_noxipaste = true
	if fighter.current_state():
		var defense_or_hurt = is_defense_state( fighter.current_state() )
		can_noxipaste = not defense_or_hurt
		
		for child in fighter.current_state().get_children():
			if "IgnoreGoopRule" in child.name:
				can_noxipaste = true
			if "NoNoxipaste" in child.name:
				can_noxipaste = false
		
		if defense_or_hurt:
			detach_button.disabled = true
		
	yank_button.disabled = detach_button.disabled
	if not fighter._can_yank_self():
		yank_button.disabled = true
	
	if noxipaste_options.current_selected() > 0 and (move_state == null):
		yank_button.disabled = true
		detach_button.disabled = true
		
	if attached_to_clone() and (move_state == null):
		var index = 0
		for data in slimeclone_array():
			if data.has("clone_name"):
				if data.clone_name == name:
					break
			index += 1
		if noxipaste_options.current_selected() == index:
			detach_button.disabled = true
			
	opponent_on_ground = false
	opponent_on_air = false
	if yank_button.pressed:
		
		var _object = fighter.gooped_obj() and fighter.gooped_obj().is_grounded()
		var _goop_any = (fighter.gooped_obj() == null) and not fighter.goop_pos_no_edge(fighter.goop_global_x, fighter.goop_global_y)
		var _object_slimeball = fighter.gooped_obj() and fighter.gooped_obj().get("IS_SLIMEBALL")
		
		opponent_on_ground = _object and fighter.is_gooped() and fighter.is_grounded()
		if (_goop_any or _object_slimeball) and fighter.is_grounded():
			opponent_on_ground = true
		opponent_on_air = not opponent_on_ground
		
	if fighter.previous_state():
		for child in fighter.previous_state().get_children():
			if "IgnoreGoopRule" in child.name:
				can_noxipaste = true
			if "NoNoxipaste" in child.name:
				can_noxipaste = false
				
	if slimeclone_array().size() > fighter.MAX_COPYBUNY_CLONES or should_not_noxipaste():
		can_noxipaste = false
		
	noxipaste_options.visible = (move_state == null)
	noxipaste_options.disabled = not can_noxipaste
	disable_on_block()
	
	copybuny_plot.visible = button_active_and_pressed(copybuny_button)
	$"%Clone Label".visible =\
		not noxipaste_options.disabled\
		and (move_state != null)\
		and slimeclone_array().size() > 0
							
	noxipaste_flip_button.visible = list_valid()
	noxipaste_detonate_button.visible = false

	if can_noxipaste:
		var a_clone_in_zone = false
		for obj in fighter.objs_map.values():
			if obj is BaseProjectile:
				if fighter.obj_in_radius(obj) and not obj.disabled and obj.get("IS_SLIMECLONE"):
					a_clone_in_zone = true
		noxipaste_detonate_button.visible = fighter.in_meltdown() and a_clone_in_zone and (move_state != null) and not fighter.noxipaste_queue_explode
	
static func button_active_and_pressed(button:CheckButton):
	return button.pressed and button.visible and not button.disabled

func list_valid(ignore_visibility=false):
	return (noxipaste_options.visible or ignore_visibility) and not noxipaste_options.disabled and noxipaste_options.current_selected() > 0
	
func update_clone_index():
	noxipaste_options.fighter = fighter
	noxipaste_options.fighter_update()
		
func disable_on_block():
	if fighter.current_state().get("disable_aerial_movement"):
		copybuny_button.disabled = true
		copybuny_button.set_pressed_no_signal(false)
		noxipaste_detonate_button.disabled = true
		noxipaste_detonate_button.set_pressed_no_signal(false)
		
		noxipaste_options.set_disabled(true)
		
		fighter.reset_goop(true)
		
	if fighter.previous_state():
			
		if fighter.previous_state()._previous_state():
			for state in [fighter.previous_state(), fighter.previous_state()._previous_state()]:
				if state and state.get("IS_NEW_PARRY"):
					noxipaste_options.set_disabled(true)
		
func slimeclone_array()->Array:
	return fighter.slimeclone_data

func attached_to_clone():
	return fighter.gooped_obj() and fighter.gooped_obj().get("IS_SLIMECLONE")

func is_defense_state(move) -> bool:
	return move.type == CharacterState.ActionType.Defense or move.type == CharacterState.ActionType.Hurt

func should_not_noxipaste() -> bool:
	return slimeclone_array().empty() or fighter.noxipaste_queue_active or (fighter.current_state() is ThrowState)
