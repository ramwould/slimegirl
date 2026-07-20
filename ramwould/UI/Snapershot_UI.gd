extends ActionUIData

func fighter_update():
	if fighter:
		$Angle.visible = fighter.queued_beam_shockwave and fighter.combo_count > 0

func get_data():
	if $Angle.visible:
		return .get_data()
		
	return null
