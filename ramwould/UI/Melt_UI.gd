extends ActionUIData


func _on_First_toggled(button_pressed):
	$Last.set_pressed_no_signal(false)
	$Lassail.set_pressed_no_signal(false)
	$Last.disabled = false
	$Lassail.disabled = false
	
	$First.disabled = true

func _on_Last_toggled(button_pressed):
	$First.set_pressed_no_signal(false)
	$Lassail.set_pressed_no_signal(false)
	$First.disabled = false
	$Lassail.disabled = false
	
	$Last.disabled = true

func _on_Lassail_toggled(button_pressed):
	$First.set_pressed_no_signal(false)
	$Last.set_pressed_no_signal(false)
	$First.disabled = false
	$Last.disabled = false
	
	$Lassail.disabled = true

func fighter_update():
	if is_instance_valid(fighter):
		$Lassail.hide()
		$First.show()
		$Last.show()
		
		if not $Lassail.visible and $Lassail.pressed and fighter.can_teleport():
			$Last.set_pressed_no_signal(true)
			$First.set_pressed_no_signal(false)
			$Lassail.set_pressed_no_signal(false)
			$First.disabled = false
			$Lassail.disabled = false
			
			$Last.disabled = true
		
		if (fighter.lassail_projectile() == null):
			return
		$Lassail.show()

func on_button_selected():
	if not fighter.can_teleport() and fighter.can_teleport_or_lassail():
		$First.hide()
		$Last.hide()
		
		$Lassail.set_pressed_no_signal(true)
		$First.set_pressed_no_signal(false)
		$Last.set_pressed_no_signal(false)
		$First.disabled = false
		$Last.disabled = false
		
		$Lassail.disabled = true

