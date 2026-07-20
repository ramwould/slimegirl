extends "res://SoupModOptions/ModOptions.gd"

func _ready():
	var my_menu = generate_menu("SL_settings", "Slimegirl Options")

	my_menu.add_number_slider("rad_opacity", "The opacity Slimegirl's aura will display", 50, {min_value=0,max_value=100})
	my_menu.add_number_slider("bubbl_opacity", "The opacity of Slimetrail bubbles", 100, {min_value=0,max_value=100})
	my_menu.add_bool("meltdown_flash", "Do meltdown flashes?", true)
	
	my_menu.add_bool("disable_extra_noise", "Disable various extra VFX/SFX?", false)
	my_menu.add_bool("disable_silly_words", "Disable UI text replacements?", false)
	my_menu.add_bool("show_damage_prediction", "Show prediction poison damage?", true)
	
	add_menu(my_menu)
