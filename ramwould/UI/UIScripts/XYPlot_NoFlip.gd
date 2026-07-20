tool
extends XYPlot

export var update_facing = true

func set_facing(val):
	if update_facing:
		.set_facing(val)
	pass
