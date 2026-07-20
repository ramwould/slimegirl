extends BaseProjectile

export var allow_host_hit_cancelling = false
export var allow_projectile_to_damage_slimegirl = false
export var slime_color_to_use = "ffffff"
export var uses_melee_hitboxes = false
export var affected_by_tailwhip_detect = false
export var on_fire_explosion:PackedScene
export var on_fire_explosion_fx:PackedScene
export var on_fire_hit_cancel = false
export var explosion_data = []

var on_fire = false
onready var fire_trail:ParticleEffect = get_node_or_null("./Flip/Particles/FireTrail")

func _on_hit_something(obj, hitbox):
	._on_hit_something(obj, hitbox)
	
	if allow_host_hit_cancelling:
		if get_fighter().current_state().has_hitboxes:
			get_fighter().current_state()._on_hit_something(obj, hitbox)
	get_fighter()._on_hit_something(obj, hitbox)
	
	if explosion_data.empty():
		return
	for entry in explosion_data:
		if entry is Dictionary:
			if get_fighter().in_meltdown() and (obj is Fighter):
				get_fighter().meltdown_ticks += entry.get("add_meltdown_ticks", 0)
					
func hit_by(hitbox):
#	if allow_projectile_to_damage_slimegirl:
#		if hitbox:
#			if hitbox.host == get_fighter().obj_name:
#				return
#		.hit_by(hitbox)
#
#	else:
		.hit_by(hitbox)

func copy_to(p):
	.copy_to(p)
	p.on_fire = on_fire

func _ready():
	state_variables.append_array(
		[
			"on_fire",
		]
	)
	
func tick():
	.tick()
	if uses_melee_hitboxes or allow_host_hit_cancelling:
		for hitbox in hitboxes:
			hitbox.host = get_fighter()
	
	if on_fire:
		if fire_trail:
			enable_firetrail()
				
func _spawn_particle_effect(particle_effect:PackedScene, pos:Vector2, dir = Vector2.RIGHT):
	
	var color = Color.white
	if not slime_color_to_use.empty():
		if slime_color_to_use.to_lower() in ["default","outline","style_1","style_2"]:
			color = get_fighter().color_else_slime(slime_color_to_use)
		else:
			assert(slime_color_to_use.is_valid_html_color())
			color = Color(slime_color_to_use)
	
	var obj = particle_effect.instance()
	var cfg = self.get("custom_hitspark_config")
	var is_custom_hitspark = cfg != null and "custom_config" in obj
	if is_custom_hitspark:
		obj.set("custom_config", cfg)
	add_child(obj)
	if obj.name == "Multicolor":
		for child in obj.get_children():
			if child is Particles2D:
				if "Include" in child.name:
					child.modulate = color
			elif child is CPUParticles2D:
				if "Include" in child.name:
					child.modulate = color
			elif child is AnimatedSprite:
				if "Include" in child.name:
					child.modulate = color
	elif obj.name == "Color":
		obj.modulate = color
	obj.tick()
	var facing = - 1 if dir.x < 0 else 1
	obj.position = pos
	if facing < 0:
		obj.rotation = (dir * Vector2( - 1, - 1)).angle()
	else :
		obj.rotation = dir.angle()
	obj.scale.x = facing
	for child in obj.get_children():
		if child is CustomTrailParticle:
			child.facing = facing
	remove_child(obj)

	emit_signal("particle_effect_spawned", obj)
	if hooks:
		hooks.spawn_particle(obj)
	return obj
	
func init(pos=null):
	.init(pos)
	if fire_trail:
		fire_trail.stop_emitting()
	
func enable_firetrail():
	if disabled:
		return
	if fire_trail == null:
		return
	fire_trail.show()
	fire_trail.emitting = true
	fire_trail.set_enabled(true)
	for child in fire_trail.get_children():
		if child is Particles2D:
			child.one_shot = false
			child.emitting = true
		elif child is CPUParticles2D:
			child.one_shot = false
			child.emitting = true
		elif child is AnimatedSprite:
			child.playing = false
			child.frame = 0
		elif child is AudioStreamPlayer2D:
			fire_trail.sounds_played[child] = false
	
func disable():
	.disable()
	
	try_explode()

func try_explode():
	var box = get_hurtbox_center_float()
	var box_relative = hurtbox_pos_relative()
	if on_fire and on_fire_explosion:
		_spawn_particle_effect(on_fire_explosion_fx, box, Vector2())
		var obj = spawn_object(on_fire_explosion, box_relative.x, box_relative.y, true, null, true)
		obj.allow_host_hit_cancelling = on_fire_hit_cancel
