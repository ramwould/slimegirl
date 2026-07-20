extends TextureRect

onready var host = $"../.."

var assimilate_tween:SceneTreeTween
var assimilate_alpha:float = 0
var aura_color = Color.white

var hit_ticks:float
const MAX_HIT_TIME = 0.5
const STARR_SHAPE_THICKNESS = 8.0
const AURA_SIZE = 50

var slime_color = Color.white
var valid_slime_color = true

var style1_color = Color("00b035")
var style2_color = Color.red
const DEFAULT_RED = Color("aca2ff")
const DEFAULT_BLU = Color("ff7a81")

const DEFAULT_STYLE = {
	"style_name": "Default",
	"character_color": Color.white,
	"extra_color_1": Color("00b035"),
	"extra_color_2": Color("ff0000"),
	"use_outline": false,
	"outline_color": Color.black,
}

func _ready():
	$"%Hit".connect("pressed", self, "_on_hit_button")
	$"%REDBLU".connect("pressed", self, "_on_PreviewStyle_item_selected", [0])
	
func in_meltdown_mimic():
	var duration = 2.5
	if Utils.pulse(duration, 0.01):
		_on_Slimegirl_poison_booster()
	return $"%MeltdownButton".pressed
	
func _process(delta):
	if host.slime_alt_color == null:
		return
	if host.s1_alt_color == null:
		return
	if host.s2_alt_color == null:
		return
	
	
	$"%TextureRect".self_modulate = _style_slime(host.slime_alt_speed, slime_color, Color(host.slime_alt_color))
	aura_color = _style_slime(host.s1_alt_speed, style1_color, Color(host.s1_alt_color))
	if in_meltdown_mimic():
		aura_color = _style_slime(host.s2_alt_speed, style2_color, Color(host.s2_alt_color))
	
	if hit_ticks > 0:
		hit_ticks -= 1.0*delta
	
	
	var hit_visible = false
	var fade_visible = false
	var all_speeds = [host.slime_alt_speed, host.s1_alt_speed, host.s2_alt_speed]
	for i in all_speeds:
		if i == null:
			pass
			
		elif "Pulse" in i:
			if not ("damage" in i):
				hit_visible = true
			
		elif "Fade" in i:
			fade_visible = true
	
	$"%Hit".visible = hit_visible
	$"%Fade Percent".visible = fade_visible
	$"%REDBLU".visible = $"%PreviewStyle".selected == 0 or not valid_slime_color
	
	update()

func _style_slime(var type, var color1, var color2)->Color:
	var fastest_speed = 180
	
	var reverse_s = color2.is_equal_approx(host.slime_alt_color) and host.slime_alt_reversed
	var reverse_1 = color2.is_equal_approx(host.s1_alt_color) and host.s1_alt_reversed
	var reverse_2 = color2.is_equal_approx(host.s2_alt_color) and host.s2_alt_reversed
	
	if reverse_s or reverse_1 or reverse_2:
		var temp = color1
		color1 = color2
		color2 = temp
		
	var color_lerp = color1
	
	
	match type:
		"Slow":
			var lerp_speed = Utils.wave(0.0, 1.0, Utils.frames(fastest_speed*4)) 
			color_lerp = color1.linear_interpolate(color2, lerp_speed)
		"Normal":
			var lerp_speed = Utils.wave(0.0, 1.0, Utils.frames(fastest_speed*2)) 
			color_lerp = color1.linear_interpolate(color2, lerp_speed)
		"Fast":
			var lerp_speed = Utils.wave(0.0, 1.0, Utils.frames(fastest_speed)) 
			color_lerp = color1.linear_interpolate(color2, lerp_speed)
		"Very Fast":
			var lerp_speed = Utils.wave(0.0, 1.0, Utils.frames(fastest_speed/2)) 
			color_lerp = color1.linear_interpolate(color2, lerp_speed)
		"Pulse on Damage Taken","Pulse on Damage Dealt","Pulse on Super Use":
			var d = hit_ticks / MAX_HIT_TIME
			color_lerp = color1.linear_interpolate(color2, d)
		"Fade to HP","Fade to Opponent HP","Fade to Poison","Fade to Burst","Fade to Max Meter",\
		"Fade to Match Time","Fade to AM/PM":
			var d = float($"%Fade Percent".get_data().count) / 100.0
			color_lerp = color2.linear_interpolate(color1, d)
		_: pass
			
	return color_lerp

func _on_hit_button():
	hit_ticks = MAX_HIT_TIME
	$"%Click".play()
	
func _draw():

	var regular_aura_point_count = host.num_points == 16
	var rad_size = AURA_SIZE + Utils.wave(0.0, 8.0, Utils.frames(360))
	var pos = get_rect().size / 2.0
	
	var inner_wave = rad_size + (Utils.wave(-1.0, 1.0, 4.333) * 4)
	var outer_wave = rad_size + (Utils.wave(0.5, -0.5, 4.333) * 4)
	
	var points_aura = PoolVector2Array()
	var points_poly = PoolVector2Array()
	var DEFAULT_ROTATION = Utils.float_time()*0.8
	
	for i in range(host.num_points+1):
		var point_vector = Vector2(outer_wave, 0).rotated( (i*(TAU/host.num_points)) + DEFAULT_ROTATION )+pos
		points_aura.append(point_vector)
		if i == 0:
			continue
		points_poly.append(point_vector)
		
	var assimilate_flash = aura_color
	assimilate_flash.a = max(assimilate_alpha,0.12)
	var shape_color = aura_color
	shape_color.a = 0.50
#	var texture :Texture= preload("res://slimegirl/ramwould/FX/sprites/big_circle01.tres")
	draw_colored_polygon(points_poly, assimilate_flash, points_poly, null, null, false)
	draw_polyline(points_aura, aura_color, 2.0)
	
	
	if host.extra_shape_1 > 1:
#		var offset = deg2rad(inner_wave*5)
		var offset = DEFAULT_ROTATION / PI
		match host.extra_shape_1:
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
				var 								num_lines = 1 
				if host.extra_shape_1 == 101: 		num_lines = 2
				if host.extra_shape_1 == 102: 		num_lines = 3
					
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
				for i in range(host.num_points+1):
					var point_vector = Vector2(outer_wave*0.85, 0).rotated( (i*(TAU/host.num_points)) + DEFAULT_ROTATION )
					point_vector+=pos
					points.append(point_vector)
				draw_polyline(points, shape_color, 3.0)
			
#			mimic (full)
			104:
				var points = PoolVector2Array()
				var shape = PoolColorArray()
				for i in range(host.num_points):
					var point_vector = Vector2(outer_wave*0.85, 0).rotated( (i*(TAU/host.num_points)) + DEFAULT_ROTATION )
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
				var divisions :int= host.num_points
				if divisions % 2 == 1:
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
					
					draw_arc(ext_pos, inner_wave*0.6, start_angle, end_angle, 64, shape_color, 3.0, false)
				
			_:
				var num_points = host.extra_shape_1+1
				var points = PoolVector2Array()
				for i in range(num_points):
					var point_vector = Vector2(outer_wave*0.85, 0).rotated( (i*(TAU/host.extra_shape_1)) + offset )
					point_vector+=pos
					points.append(point_vector)
				
				for i in range(num_points-1):
					var out = wrapi(i+1, 0, num_points-1)
					draw_line(points[i], points[out], shape_color, STARR_SHAPE_THICKNESS-4.0, false)
					

func _on_Slimegirl_poison_booster():
	if assimilate_tween and assimilate_tween.is_running():
		assimilate_tween.kill()
	assimilate_tween = create_tween()
	assimilate_tween.tween_method(self, "assimilate_flash", 1.0, 0.0, 0.20)
	
func assimilate_flash(alpha:float):
	assimilate_alpha = alpha

func set_style_colors(color_name, color_colour):
	set("%s_color"%color_name, color_colour) 

func reset_style_colors():
#	var s_color = DEFAULT_STYLE["character_color"]
#	if $"%PreviewStyle".selected == 0:
#		s_color = DEFAULT_BLU if $"%REDBLU".pressed else DEFAULT_RED
	var s_color = DEFAULT_BLU if $"%REDBLU".pressed else DEFAULT_RED
	
	set_style_colors( "slime", s_color)
	set_style_colors( "style1", DEFAULT_STYLE["extra_color_1"] )
	set_style_colors( "style2", DEFAULT_STYLE["extra_color_2"] )

func _on_PreviewStyle_item_selected(index: int) -> void:
	reset_style_colors()
	valid_slime_color = false
	if index > 0:
		index -= 1
		if host.styles[index]["character_color"]:
			valid_slime_color = true
			set_style_colors( "slime", host.styles[index]["character_color"] )
		if host.styles[index]["extra_color_1"]:
			set_style_colors( "style1", host.styles[index]["extra_color_1"] )
		if host.styles[index]["extra_color_2"]:
			set_style_colors( "style2", host.styles[index]["extra_color_2"] )
	
func _on_PreviewStyle_visibility_changed() -> void:
	reset_style_colors()
	
	$"%PreviewStyle".clear()	
	$"%PreviewStyle".add_item(DEFAULT_STYLE["style_name"])
	
	for style in host.styles:
		$"%PreviewStyle".add_item(style["style_name"])
		
	$"%PreviewStyle".select(0)
	
	var last_style = Global.get_player_data()["last_style"]
	for i in range(host.style_paths.size()):
		if host.style_paths[i] == last_style:
			$"%PreviewStyle".select(i + 1)
			_on_PreviewStyle_item_selected(i + 1)
			break
