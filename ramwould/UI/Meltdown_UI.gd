extends ActionUIData

onready var clone_nodes = [$"%Clone_1", $"%Clone_2", $"%Clone_3"]
	
func _on_Clone_1_toggled(button_pressed):
	pass
	
func _on_Clone_2_toggled(button_pressed):
	pass # Replace with function body.

func _on_Clone_3_toggled(button_pressed):
	pass # Replace with function body.

func fighter_update():
	if fighter:
		for node in clone_nodes:
			node.set_pressed_no_signal(false)
			node.hide()
		
		
		var dic:Array = fighter.slimeclone_data
		
		$VBoxContainer.hide()
		if dic.size() > 0:
			$VBoxContainer.show()
			var index = 0
			for data in dic:
				var button:CheckButton = clone_nodes[index]
				button.text = str(index+1) + ": " + data["state_visual"]
				button.copybuny_index = index
				button.show()
				index+=1

		
			

