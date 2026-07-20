extends Node2D

onready var host = get_parent()
const MAX_WIDTH = 7

func _process(delta):
	$"%SnagEnd".visible = host.snag_length_ratio > 0
	$"%Needle".visible = host.syringe_length_ratio > 0
	update()
	
func _draw():
	var draw_color_outline = host.color_else_slime("outline")
	
	#GOOP_START
#	if host.opponent_is_gooped():
#		var from_pos = to_local( host.opponent.get_hurtbox_center_float() )
#		var to_pos = to_local(Vector2(host.goop_global_x, host.goop_global_y))	
#		var get_map = Utils.map( (to_pos-from_pos).length(), 0.0, float(host.MAX_GOOP_DISTANCE), 1.0, 0.0 )
#		var wid = get_map * MAX_WIDTH
#		draw_circle( from_pos, wid*1.2, draw_color_outline)
#		draw_circle( to_pos, wid*1.2, draw_color_outline)
#		draw_line( from_pos, to_pos, draw_color_outline, wid)
	
	if host.is_gooped() and not host.disable_goop_visual:
		var from_pos = host.hurtbox_pos_relative_float()
		var to_pos = to_local(Vector2(host.goop_global_x, host.goop_global_y))	
		var get_map = Utils.map( (to_pos-from_pos).length(), 0.0, float(host.MAX_SELF_GOOP_DISTANCE), 1.0, 0.0 )
		var wid = get_map * MAX_WIDTH
		draw_circle( from_pos, wid*1.15, draw_color_outline)
		draw_circle( to_pos, wid*1.15, draw_color_outline)
		draw_line( from_pos, to_pos, draw_color_outline, wid)
	#GOOP_END
	
	#LASSAIL_START
	if host.lassail_projectile() and host.lassail_connected():
		var from_pos = host.hurtbox_pos_relative_float()
		var to_pos = to_local( host.radius_center() )
		draw_line( from_pos, to_pos, draw_color_outline, MAX_WIDTH)
		draw_circle( to_pos, MAX_WIDTH, draw_color_outline)
		draw_circle( from_pos, MAX_WIDTH, draw_color_outline)
	#LASSAIL_END
	
	#SNAGTRIK_START
	if host.snag_length_ratio > 0:
		var from_pos = host.hurtbox_pos_relative_float()
		var to_pos = to_local( Vector2(host.snag_pos_global_x, host.snag_pos_global_y) )

		var to_lerp = lerp(from_pos, to_pos, host.snag_length_ratio)
		
		draw_line( from_pos, to_lerp, draw_color_outline, MAX_WIDTH-1)
		draw_circle( from_pos, MAX_WIDTH-1, draw_color_outline)
		$"%SnagEnd".position = to_lerp
		$"%SnagEnd".rotation = to_pos.angle()
	#SNAGTRIK_END
	
	#NEEDLE_START
	if host.syringe_length_ratio > 0:
		var from_pos = $"%AuraController".position if (host.lassail_projectile() == null) else to_local( host.radius_center() )
		var to_pos = to_local( Vector2(host.syringe_pos_global_x, host.syringe_pos_global_y) )
		var to_lerp = lerp(from_pos, to_pos, host.syringe_length_ratio)
		
		$"%Needle".points[0] = from_pos
		$"%Needle".points[1] = to_lerp
	#NEEDLE_END





