extends DefaultFireball

func _tick():
	if current_tick >= lifetime:
		host.disable()
		
func fizzle():
	pass
