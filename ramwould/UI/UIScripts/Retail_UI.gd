extends ActionUIData

onready var detach_button := $"%DetachOption"


func fighter_update():
	if fighter:
		detach_button.disabled = fighter.supers_available <= 0
	
	else:
		detach_button.disabled = true
	
	if detach_button.disabled:
		detach_button.set_pressed_no_signal(false)
