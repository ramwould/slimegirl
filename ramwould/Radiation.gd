extends Node2D

onready var host = $"../.."
var assimilate_tween:SceneTreeTween
var assimilate_alpha:float = 0
var meltdown_visual = false
var aura_color = Color.white

const STARR_SHAPE_THICKNESS = 8.0

func _process(delta):
	visible = false
	
	if float(host.visual_radius) > 0:
		visible = true
	
	aura_color = host.color_else_slime("style_1")
	if host.in_meltdown():
		aura_color = host.color_else_slime("style_2")
		if host.meltdown_disabled():
			aura_color = host.MELTDOWN_COLOR_DISABLED
			
	update()
	
func _draw():
	
	var rad_size = float(host.visual_radius)
#	var pos = position if (host.lassail_projectile() == null) else to_local( host.radius_center() )
	var pos = position
	
	var inner_wave = rad_size + (Utils.wave(-1.0, 1.0, 4.333) * 4)
	var outer_wave = rad_size + (Utils.wave(0.5, -0.5, 4.333) * 4)
	
	var points_aura = PoolVector2Array()
	var points_poly = PoolVector2Array()
	var DEFAULT_ROTATION = deg2rad(host.game_tick*0.8)
	
	for i in range(host.ACH_MOD_AURA_NUM_POINTS+1):
		var point_vector = Vector2(outer_wave, 0).rotated( (i*(TAU/host.ACH_MOD_AURA_NUM_POINTS)) + DEFAULT_ROTATION )
		points_aura.append(point_vector)
		if i == 0:
			continue
		points_poly.append(point_vector)
		
	var assimilate_flash = aura_color
	assimilate_flash.a = max(assimilate_alpha,0.12)
	var shape_color = aura_color
	shape_color.a = 0.5
	
#	var texture :Texture= preload("res://slimegirl/ramwould/sprites/auras/aura_bg_01.png")
	draw_colored_polygon(points_poly, assimilate_flash, points_poly, null, null, false)
	draw_polyline(points_aura, aura_color, 2.0)

	if host.ACH_MOD_AURA_DRAW_SHAPE > 1:
#		var offset = deg2rad(inner_wave*5)
		var offset = DEFAULT_ROTATION / PI
		match host.ACH_MOD_AURA_DRAW_SHAPE:
#			star
			100:
				var points = PoolVector2Array()
				for i in 6:
					var point_vector = Vector2(outer_wave*0.85, 0).rotated( (i*(TAU/5)*2) + offset )
					point_vector+=pos
					points.append(point_vector)

				for i in 5:
					var out = wrapi(i+4, 0, 5)
					draw_line(points[i], points[out], shape_color, STARR_SHAPE_THICKNESS, false)
				
#				draw_polyline(points, shape_color, 3.0, false)
				pass

#			line, X, *
			2, 101, 102:
				var num_lines = 1
				if host.ACH_MOD_AURA_DRAW_SHAPE == 101:
					num_lines = 2
				if host.ACH_MOD_AURA_DRAW_SHAPE == 102:
					num_lines = 3
					
				for j in num_lines:
					var points = PoolVector2Array()
					for i in 2:
						var point_vector = Vector2(outer_wave, 0).rotated( (i*(TAU/2)) + offset )
						point_vector+=pos
						points.append(point_vector)

					draw_line(points[0], points[1], shape_color, STARR_SHAPE_THICKNESS-2.0, false)
					offset += (PI/num_lines)
#			mimic
			103:
				var points = PoolVector2Array()
				for i in range(host.ACH_MOD_AURA_NUM_POINTS+1):
					var point_vector = Vector2(outer_wave*0.85, 0).rotated( (i*(TAU/host.ACH_MOD_AURA_NUM_POINTS)) + DEFAULT_ROTATION )
					point_vector+=pos
					points.append(point_vector)
				draw_polyline(points, shape_color, 3.0)
			
#			mimic (full)
			104:
				var points = PoolVector2Array()
				var shape = PoolColorArray()
				for i in range(host.ACH_MOD_AURA_NUM_POINTS):
					var point_vector = Vector2(outer_wave*0.85, 0).rotated( (i*(TAU/host.ACH_MOD_AURA_NUM_POINTS)) + DEFAULT_ROTATION )
					point_vector+=pos
					points.append(point_vector)
					shape.append(shape_color)
				draw_polygon(points, shape)
			
#			circle
			105:
				var rad_width = (rad_size/100.0)
				draw_arc(pos, inner_wave*0.65, 0.0, TAU, 64, shape_color, STARR_SHAPE_THICKNESS*rad_width, false)
			
#			divided-circle
			106:
				var divisions = host.ACH_MOD_AURA_NUM_POINTS
				if int(divisions) % 2 == 1:
					divisions+=1
				var _rotation = -offset*4.8
				var rad_width = (rad_size/100.0)
				var arc_angle = (TAU/divisions)
				for i in range(divisions):
					if i % 2 == 0:
						var start_angle = (arc_angle*i)+_rotation
						var end_angle = arc_angle+start_angle
						draw_arc(pos, inner_wave*0.65, start_angle, end_angle, 64, shape_color, STARR_SHAPE_THICKNESS*rad_width, false)

#			explosion
			107:
				var count = 5
				var m_offset = (TAU / count)*(3.5)
				for i in range(count):
					var div = (TAU / count)*i 
					var start_angle = div+(offset*-1.8)
					var end_angle = start_angle + ((TAU / count)*2)
					
					var ext_pos = Vector2(inner_wave, 0).rotated(start_angle+m_offset) + pos
					
					draw_arc(ext_pos, inner_wave*0.6, start_angle, end_angle, 64, shape_color, 4.0, false)
					
#			basic shapes
			_:
				var num_points = host.ACH_MOD_AURA_DRAW_SHAPE+1
				var points = PoolVector2Array()
				for i in range(num_points):
					var point_vector = Vector2(outer_wave*0.85, 0).rotated( (i*(TAU/host.ACH_MOD_AURA_DRAW_SHAPE)) + offset )
					point_vector+=pos
					points.append(point_vector)
				
				for i in range(num_points-1):
					var out = wrapi(i+1, 0, num_points-1)
					draw_line(points[i], points[out], shape_color, STARR_SHAPE_THICKNESS-4.0, false)
					
	modulate.a = 0.50
	if not host.is_ghost:
		modulate.a *= (int(host.MOD_RADIUS_OPACITY_MULT*100) / 100.0)
		if not host.modMain.get("show_aura_in_match_p%s"%host.id):
			modulate.a = 0

func _on_Slimegirl_poison_booster():
	if assimilate_tween and assimilate_tween.is_running():
		assimilate_tween.kill()
	assimilate_tween = create_tween()
	assimilate_tween.tween_method(self, "assimilate_flash", 1.0, 0.0, 0.20)
	
func assimilate_flash(alpha:float):
	assimilate_alpha = alpha
