extends HBoxContainer

onready var host = $"../../.."
		
func _process(delta):
	$Percentage.text = str( host.fighter.aura_opacity )+"%"

func _on_OpacitySlider_value_changed(value):
	host.fighter.aura_opacity = value
	
func _setup_aura():
	var radius_value = host.fighter.aura_opacity
	$OpacitySlider.set_value( radius_value )
