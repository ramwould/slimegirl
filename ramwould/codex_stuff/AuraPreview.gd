extends HBoxContainer

signal data_changed()

const SUFFIX = "_AURA_STYLE"

var extra_shape_1 = -1
var num_points = 16
var slime_alt_color = "ffffff"
var slime_alt_reversed = false
var slime_alt_speed = "Off"
var slime_alt_override = false
var s1_alt_color = "00b035"
var s1_alt_reversed = false
var s1_alt_speed = "Off"
var s1_alt_override = false
var s2_alt_color = "ff0000"
var s2_alt_reversed = false
var s2_alt_speed = "Off"
var s2_alt_override = false
var particle_overrides = "Default"
var particle_tint = "None"

var prev_selection = -1

onready var codex_library = get_node_or_null("/root/CharCodexLibrary")
onready var char_node = get_node_or_null("../../../../../../..")

onready var P1_StyleButton = get_node_or_null("/root/Main/UILayer/CharacterSelect/HBoxContainer/P1Display/CenterContainer/LoadStyleButton")
var styles = []
var style_paths = []

func _ready():
	$"%Update Values".connect("pressed", self, "_update_aura_display", [true])
	$"%LoadName".connect("item_selected", self, "_data_changed")
	
	$"%SaveAs".connect("pressed", self, "_save_aura")
	$"%Load".connect("pressed", self, "_load_aura")
	$"%Reset".connect("pressed", self, "_reset_aura")
	$"%Remove".connect("pressed", self, "_remove_aura")
	
	self.connect("visibility_changed", self, "_initialize_aura")
		
	$"%SAVE CONTAINER".visible = not (char_node is PanelContainer)
	$"%LOAD CONTAINER".visible = not (char_node is PanelContainer)
	$"%DELETE CONTAINER".visible = not (char_node is PanelContainer)
	$"%SaveLoadConfirm".visible = not (char_node is PanelContainer)
	
func get_data():
	return null

func _data_changed():
	_initialize_aura()
	emit_signal("data_changed")

func _initialize_aura():
	load_base_custom_styles()
	
	if char_node is PanelContainer:
		return
	var char_path = get_node("../../../../../../..").char_path
	
	refresh_aura_list(codex_library, char_path)
	_update_aura_display()
	$"%SaveLoadConfirm".text = "Displaying current aura"
	
func _update_aura_display(play_sound=false):
	var parent :Node= get_parent()
	if parent == null:
		return

	apply_params( parent.get_data() )
	load_data_onto_elsewhere( parent.get_data() )
	
	if play_sound:
		$"%Action".play()
	
func _save_aura():
	
	if char_node is PanelContainer:
		return
	var char_path = get_node("../../../../../../..").char_path

	var aura_name = $"%SaveName".text
	if aura_name.empty():
		
		aura_name = $"%LoadName".get_item_text( $"%LoadName".selected )
		if aura_name.empty():
			return

	var script = codex_library.__attempt_load_codex_script( char_path )
	if script.save_as_aura_data(codex_library, char_path, aura_name):
		print("Aura saved successfully as ",aura_name+SUFFIX)
		$"%SaveLoadConfirm".text = "Saved "+aura_name+" successfully!"
		$"%Action".play()
	
	_update_aura_display()
	
func _load_aura():
	var aura_name = $"%LoadName".get_item_text( $"%LoadName".selected )
	if aura_name.empty():
		return	

	var dict :Dictionary= get_selected_aura_data()
	if dict == null:
		return
	
	apply_params( dict )
	load_data_onto_elsewhere( dict )
	
	print("Aura loaded successfully as ",aura_name+SUFFIX)
	$"%SaveLoadConfirm".text = "Loaded "+aura_name+" successfully!"
	$"%Action".play()
	
func _remove_aura():
	if char_node is PanelContainer:
		return
	var char_path = get_node("../../../../../../..").char_path

	var aura_name = $"%LoadName".get_item_text( $"%LoadName".selected )
	if aura_name.empty():
		return
	var script = codex_library.__attempt_load_codex_script( char_path )
	if not codex_library.codex_save_data.has(char_path):
		codex_library.init_char_data(char_path)
	
	if codex_library.codex_save_data["_CODEX_"].has(aura_name+SUFFIX):
		codex_library.codex_save_data["_CODEX_"].erase(aura_name+SUFFIX)
		var save_file : File = File.new()
		save_file.open(codex_library.get_save_file_path("_CODEX_"), File.WRITE)
		save_file.store_string(JSON.print(codex_library.codex_save_data["_CODEX_"], "\t"))
		save_file.close()
		
	print("Aura removed successfully as ",aura_name+SUFFIX)
	$"%SaveLoadConfirm".text = "Removed "+aura_name+"..."
	$"%Action".play()
	
	refresh_aura_list(codex_library, char_path)
	
	apply_params( get_selected_aura_data() )
	load_data_onto_elsewhere( get_selected_aura_data() )
	
#UNUSED
func _reset_aura():
	if char_node is PanelContainer:
		return
	var char_path = get_node("../../../../../../..").char_path

	var script = codex_library.__attempt_load_codex_script( char_path )
	apply_params( script.DEFAULT_AURA_DATA )
	
	var parent:Node= get_parent()
	if parent:
		for id in parent.tracked_option_nodes:
			parent.tracked_option_nodes[id].set_value(parent.option_values[id])
			
		parent.emit_signal("data_changed")
		
	print("Aura reset successfully")
	$"%SaveLoadConfirm".text = "Resetting current aura..."
	$"%Action".play()
	
func apply_params(params):
	if params is Dictionary:
		match params.get("extra_shape1"):
			"Line": extra_shape_1 = 2
			"Triangle": extra_shape_1 = 3
			"Square": extra_shape_1 = 4
			"Pentagon": extra_shape_1 = 5
			"Hexagon": extra_shape_1 = 6
			"Octagon": extra_shape_1 = 8
				
			"Star": extra_shape_1 = 100
			"X": extra_shape_1 = 101
			"*": extra_shape_1 = 102
			"Mimic": extra_shape_1 = 103
			"Mimic (Full)": extra_shape_1 = 104
			"Circle": extra_shape_1 = 105
			"Divided Circle": extra_shape_1 = 106
			"Explosion": extra_shape_1 = 107
			
			_: extra_shape_1 = -1

		num_points = params.get("num_points")
		slime_alt_color = params.get("slime_alt_color")
		slime_alt_reversed = params.get("slime_alt_reversed")
		slime_alt_speed = params.get("slime_alt_speed")
		slime_alt_override = params.get("slime_alt_override")
		s1_alt_color = params.get("s1_alt_color")
		s1_alt_reversed = params.get("s1_alt_reversed")
		s1_alt_speed = params.get("s1_alt_speed")
		s1_alt_override = params.get("s1_alt_override")
		s2_alt_color = params.get("s2_alt_color")
		s2_alt_reversed = params.get("s2_alt_reversed")
		s2_alt_speed = params.get("s2_alt_speed")
		s2_alt_override = params.get("s2_alt_override")
		particle_overrides = params.get("particle_overrides")
		particle_tint = params.get("particle_tint")

func set_value(value):
	return value
	
func get_selected_aura_data() -> Dictionary:
	if char_node is PanelContainer:
		return {}
	var char_path = get_node("../../../../../../..").char_path
	var aura_name = $"%LoadName".get_item_text( $"%LoadName".selected )
	if aura_name.empty():
		return {}
	var script = codex_library.__attempt_load_codex_script( char_path )
	var dict :Dictionary= script.load_aura_data(codex_library, aura_name)
	if dict.empty() and OS.is_debug_build():
		print("No Aura To Get!")
		return {}
		
	return dict

# change other codex values outside of AuraPreview.tscn
func load_data_onto_elsewhere(data):
	if char_node is PanelContainer:
		return
	var char_path = get_node("../../../../../../..").char_path
	refresh_aura_list(codex_library, char_path)
	
	var parent :Node= get_parent()
	if parent == null:
		return
		
	var the_data = data
	for id in parent.tracked_option_nodes:
		var current_data = the_data.get(id)
		if current_data == null:
			continue
		parent.tracked_option_nodes[id].set_value( current_data )
	
	emit_signal("data_changed")

func refresh_aura_list(codex_library, char_path):
	prev_selection = $"%LoadName".selected
	$"%LoadName".clear()
	if not codex_library.codex_save_data.has(char_path):
		codex_library.init_char_data(char_path)
	for aura_array in codex_library.codex_save_data["_CODEX_"]:
		if aura_array.ends_with(SUFFIX):
			$"%LoadName".add_item(aura_array.trim_suffix(SUFFIX))
	
	if $"%LoadName".get_item_count() == 0:
		$"%LoadName".selected = -1
		prev_selection = -1
		return
		
	else:
		if prev_selection != -1:
			$"%LoadName".selected = prev_selection
			
func load_base_custom_styles():
	P1_StyleButton.update_styles()
	styles = P1_StyleButton.loaded_styles.duplicate(true)
	style_paths = P1_StyleButton.loaded_style_paths.duplicate(true)






