extends "res://ui/ActionSelector/ActionUIData/ActionUIDataCheckButton.gd"

var copybuny_index = -1

func get_data():
	return {
		"enabled":pressed,
		"index":copybuny_index
	}
