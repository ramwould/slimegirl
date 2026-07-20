extends Node

var show_aura_in_match_p1 = true
var show_aura_in_match_p2 = true

func _init(modLoader = ModLoader):
	modLoader.installScriptExtension("res://slimegirl/CharacterSelect.gd")
	modLoader.installScriptExtension("res://slimegirl/HudLayer.gd")
	
	var file = File.new()
	if file.file_exists("res://SoupModOptions/ModOptions.gd"):
		modLoader.installScriptExtension("res://slimegirl/ModOptions.gd")
		
func _ready():
	name = "EverybodySayThankYouTrimay"
