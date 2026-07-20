extends Getup

func _enter():
	var number = host.randi_range(1, 8)
	anim_name = "Knockdown_%s" % number
	if host.hp <= 0:
		anim_name = "Knockdown"
		
	._enter()
