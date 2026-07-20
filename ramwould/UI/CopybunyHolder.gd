extends Control

onready var clone_nodes = [$"%Button1", $"%Button2", $"%Button3", $"%Button4"]
var disabled = false setget set_disabled
var fighter:Fighter = null

signal data_changed()

func fighter_update():
	if fighter:
		for node in clone_nodes:
			if node == clone_nodes[0]:
				node.disabled = disabled
				continue
			node.hide()
		
		var arr:Array = fighter.slimeclone_data
		
		$"%Button1".text = "No Clones"
		if arr.size() > 0:
			$"%Button1".text = "None"
			
			var index = 1
			for data in arr:
				var button:Button = clone_nodes[index]
				button.text = data["state_visual"]
				button.copybuny_index = index
				button.disabled = data["clone_inactive"]
				if not disabled:
					button.show()
				index+=1
				
			if disabled:
				$"%Button1".text = "Disabled"
			
func _on_Button1_toggled(button_pressed):
	select_button(0)
	emit_signal("data_changed")
	
func _on_Button2_toggled(button_pressed):
	select_button(1)
	emit_signal("data_changed")

func _on_Button3_toggled(button_pressed):
	select_button(2)
	emit_signal("data_changed")

func _on_Button4_toggled(button_pressed):
	select_button(3)
	emit_signal("data_changed")

func select_button(idx:int):
	for button in clone_nodes:
		if button == clone_nodes[idx]:
			(button as Button).set_pressed_no_signal(true)
		else:
			(button as Button).set_pressed_no_signal(false)

func current_selected()->int:
	for button in clone_nodes:
		if (button as Button).pressed and button.visible:
			return button.copybuny_index
	return -1

func set_disabled(val:bool):
	disabled = val
		
		
		
		
		
		
		
		
