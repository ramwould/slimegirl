tool
extends Hitbox

class_name SlimeHitbox, "res://slimegirl/ramwould/hitboxes/icon_slime.png"

export var fake_damage_mod:int = 3
export var add_poison = false

func init():
	.init()
	
#	This was necessary to get clashing to work properly with other moves
#	Might not be the best solution, but it works so, meh
	damage *= fake_damage_mod
	if damage_in_combo != -1:
		damage_in_combo *= fake_damage_mod
	minimum_damage *= fake_damage_mod


func get_dir_float(facing = false):
	var normalized_dir = host.fixed.normalized_vec(dir_x, dir_y)
	dir_x = normalized_dir.x
	dir_y = normalized_dir.y
	return .get_dir_float(facing)
	
func hit(obj):
	var actual_hitbox = Hitbox.new()
	actual_hitbox = self.duplicate()
	actual_hitbox.host = self.host
	
	if not is_projectile() and host.has_sloppy_power():
		var power = int( host.fixed.mul(host.get_sloppy_power(), "400") )
		var arr = [damage, damage_in_combo, minimum_damage]
		for i in 3:
			var d = arr[i]
			
			d /= fake_damage_mod
			d *= power
			d /= 400
		
			arr[i] += d
		
		actual_hitbox.damage = arr[0]
		if arr[1] < -1:
			arr[1] = -1
		actual_hitbox.damage_in_combo = arr[1]
		actual_hitbox.minimum_damage = arr[2]
		
	else:
		actual_hitbox.damage /= fake_damage_mod
		if actual_hitbox.damage_in_combo != -1:
			actual_hitbox.damage_in_combo /= fake_damage_mod
		actual_hitbox.minimum_damage /= fake_damage_mod
		
	if not (host.get("allow_projectile_to_damage_slimegirl") == null):
		if not host.allow_projectile_to_damage_slimegirl and obj == host.get_fighter() and host.damages_own_team:
			return
			
	if not (obj.name in hit_objects) and ( not obj.invulnerable or hitbox_type == HitboxType.ThrowHit) and otg_check(obj):
		var camera = get_tree().get_nodes_in_group("Camera")[0]
		var dir = get_dir_float(true)
		if grounded_hit_state is String and grounded_hit_state == "HurtGrounded" and obj.is_grounded():
				dir.y *= 0
		save_hit_object(obj)
		if hitbox_type == HitboxType.Detect:
			host.detect(obj)
			return 
		obj.hit_by(actual_hitbox.to_data())
		var can_hit = true
		if obj.is_in_group("Fighter"):
			if host.is_in_group("Fighter"):
				if host.current_state().end_feint:
					host.feinting = false
					host.current_state().feinting = false
			if not host.is_ghost:
				if not bump_on_whiff:
					var length = Utils.frames(victim_hitlag if screenshake_frames < 0 else screenshake_frames) * float(obj.global_hitstop_modifier)

					camera.bump(camera_bump_dir, screenshake_amount, length)
			if obj.can_parry_hitbox(self) or name in obj.parried_hitboxes:
				can_hit = false
				emit_signal("got_parried")
			if obj.can_counter_hitbox(self):
				can_hit = false
			if obj.on_the_ground:
				if not hits_otg:
					can_hit = false

			if not hits_vs_dizzy:
				if obj.current_state().state_name == "HurtDizzy":
					can_hit = false
		if can_hit and spawn_particle_effect:
			if hit_particle:
				spawn_particle(hit_particle, obj, dir)
			if not replace_hit_particle:
				spawn_particle(HIT_PARTICLE if Global.enable_custom_hit_sparks else DEFAULT_HIT_PARTICLE, obj, dir)

		if can_hit:
			var pushback_modifier = host.fixed.mul(str(host.hitstun_decay_combo_count) if host.is_in_group("Fighter") else "0", COMBO_PUSHBACK_COEFFICIENT)
			var pushback = host.fixed.mul(host.fixed.add(pushback_x, pushback_modifier), "-1")
			pushback = host.fixed.div(pushback, "2")
			host.add_pushback(pushback)
			obj.add_pushback(pushback)
			var opponent = obj.get("opponent")
			
			if opponent:
				if opponent != host:
					opponent.add_pushback(pushback)
			if hit_sound_player and not ReplayManager.resimulating:
				hit_sound_player.play()
				if not bass_on_whiff:
					hit_bass_sound_player.play()
			emit_signal("hit_something", obj, actual_hitbox)

func box_draw():
		var parent = get_parent()
		if parent.is_in_group("BaseObj"):
			if parent.disabled:
				return 
		var color = Color.red
		var inner_border_color = Color.orange
		
		var rect = get_rect_float()
		var fill = color
		var stroke = color
		fill.a = 0.25
		stroke.a = 0.5
		draw_rect(rect, fill, true)
		draw_rect(rect, stroke, false)
		
		rect = rect.grow(-1.0)
		stroke = inner_border_color
		stroke.a = 0.5
		var width = 1.0
		draw_rect(rect, stroke, false, width)
