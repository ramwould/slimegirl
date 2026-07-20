extends ObjectState

onready var windbox1 = $Windbox
onready var windbox2 = $Windbox2
onready var windbox3 = $Windbox3
onready var hitbox = $Area

const PUSH_DIRECT = "1.55"
const PUSH_FORCE = "0.28"
var blowing = false
var can_hit = false

func _tick():
	var slimegirl = host.get_fighter()
	if slimegirl.current_state() and not ("Venocache" in slimegirl.current_state().state_name):
		slimegirl.stop_venocache_wind()
		host.disable()
		return
		
	hitbox.can_draw = can_hit
	if can_hit:
		var hitbox_hitting = []
		for h in [hitbox]:
			h.facing = host.get_facing()
			host.update_data()
			var pos = host.get_pos()
			h.update_position(pos.x, pos.y)
			for obj in slimegirl.objs_map.values():
				if _fighter_valid(obj) and h.overlaps(obj.hurtbox):
					if obj.is_otg():
						continue
					if obj.invulnerable:
						continue
					hitbox_hitting.append(obj)	
			for obj in hitbox_hitting:
				queue_state_change("Explosion")
				return
		
	if blowing:
		var windbox_hitting = []
		for wb in [windbox1, windbox2, windbox3]:
			wb.facing = host.get_facing()
			host.update_data()
			var pos = host.get_pos()
			wb.update_position(pos.x, pos.y)
			for obj in slimegirl.objs_map.values():
				if _fighter_valid(obj) and wb.overlaps(obj.hurtbox):
					windbox_hitting.append(obj)
			for obj in windbox_hitting:
				push_object(obj)

func _fighter_valid(obj)->bool:
	var slimegirl = host.get_fighter()
	return obj is Fighter and (not obj == slimegirl) and obj.current_state() and obj.current_state().state_name != "Burst" and not obj.projectile_invulnerable and not obj.invulnerable
	
func _enter():
	blowing = false
	can_hit = false
	
func _frame_3():
	var slime = host.get_fighter()
	blowing = true
	
	slime.start_venocache_wind()
		
func _frame_5():
	can_hit = true
	
func _frame_11():
	blowing = false
	can_hit = false
	host.get_fighter().stop_venocache_wind()
	host.disable()

func _exit():
	host.get_fighter().stop_venocache_wind()

func push_object(obj):
	var dir = obj.obj_local_center(host)
	if obj is Fighter:
		var p_dir = fixed.normalized_vec_times(str(dir.x), str(dir.y), PUSH_FORCE)
		var d_dir = fixed.normalized_vec_times(str(dir.x), str(dir.y), PUSH_DIRECT)
		if obj.is_grounded():
			p_dir.x = fixed.div(p_dir.x,"2")
			p_dir.y = "0"
			d_dir.y = "0"
			
		obj.apply_force(p_dir.x, p_dir.y)
		obj.move_directly(d_dir.x, d_dir.y)
		
#	else:
#		var p_dir = fixed.normalized_vec_times(dir_x, dir_y, fixed.div(PUSH_FORCE,"2"))
#		var m_dir = fixed.normalized_vec_times(dir_x, dir_y, fixed.div(PUSH_DIRECT,"1.33"))
#		obj.apply_force(p_dir.x, p_dir.y)
#		obj.move_directly(m_dir.x, m_dir.y)
