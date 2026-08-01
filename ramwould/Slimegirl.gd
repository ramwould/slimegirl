extends Fighter

signal poison_booster()
signal meltdown_alarm()
signal chernobyl_fire()

const SLIMEBOX := preload("res://slimegirl/ramwould/hitboxes/SlimeHitbox.gd")
const BEAMBOX := preload("res://slimegirl/ramwould/hitboxes/BeamHitbox.gd")

class_name _SLIMEGIRL

onready var needle :Line2D= $"%Needle"
onready var snagarm_end :Sprite= $"%SnagEnd"

onready var airmelt :AnimatedSprite= $"%AirMelt"
onready var sharpeardo :AnimatedSprite= $"%Sharpeardo"

onready var venocachewind :ParticleEffect= $"%VenocacheWind"
onready var meltdown_aura :ParticleEffect= $"%MeltdownAura"
onready var aura_controller :Node2D= $"%AuraController"

#	TODO: Add more achievos
#	TODO: Fix the jank (never gonna happen)

#	DEBUG STUFF
var charname = "Slimegirl"

#	GAMEPLAY STUFF
var poison_time:int = 0
var poison_potency:String = "1.0" # affects radius, poison damage, poison minimum damage
var poison_damage_mod:int = 1 # default poison damage per poison tick
var poison_damage_ticks:int = 0 # while > 0, increases poison_damage_mod by 1
const MAX_POISON_DAMAGE_TICKS = 90
var boost_ticks:int = 0 # affects poison damage based on time
var temporary_size_ticks:int = 0
var burst_size_ticks:int = 0
var poison_tick_rate:int = 1 # low numbers = faster tick speed
var current_radiation_radius:String = "0.0"
var visual_radius:String = "0.0"
var extra_radius_size_mult:String = "1.0" # radius size multiplier
var aura_multiplier_while_inf:int = 1
var radius_center_global_x:int = 0
var radius_center_global_y:int = 0
var lassail_proj = null
var carrotmine = null
var last_trail_center_x:int = 0
var first_trail_center_x:int = 0
var syringe_pos_global_x:int = 0
var syringe_pos_global_y:int = 0
var syringe_length_ratio:float = 0
var syringe_ticks:int = 0
var syringe_max:float = 5
export var syringe_curve:Curve

var on_slimetrail_this_state = false
var opponent_on_slimetrail_this_state = false
var opponent_on_fire = false
var on_fire_this_state = false
var trail_array:Array = []

var meltdown_ticks:int = 0
var chernobyl_ticks:int = 0
var pnd_pump_times = 0
var snapcracklpop_ticks:int = 0

var snag_pos_global_x = 0
var snag_pos_global_y = 0
var snag_length_ratio:float = 0
var snag_ticks:int = 0
var snag_cooldown:int = 0
var snag_max:float = 5
export var snag_curve:Curve

var airmelt_length_ratio:float = 0
var airmelt_ticks:float = 0
var airmelt_max:float = 0
export var airmelt_curve:Curve

var goop_global_x = 0
var goop_global_y = 0
var gooped_obj_name
var yank_ticks:int = 0
var disable_goop_visual = false

var combo_count_on_burst:int = 0

var copybuny_active = false
var copybuny_this_turn = false
var copybuny_index = 0
var copybuny_xy = Vector2()
var noxipaste_tick = 4
var noxipaste_active = false
var noxipaste_queue_active = false
var noxipaste_this_turn = false
var noxipaste_effect_this_turn = false
var noxipaste_flip_state = false
var noxipaste_explode = false
var noxipaste_queue_explode = false
var noxipaste_explode_this_turn = false
var slimeclone_data = []
var current_slimeclone_state_name = "Wait"

var reversed_material:Material
var pause_poison_ticks = false
var queued_beam_shockwave = false
var venobuster_ticks = 0
var poison_gained_this_turn = 0
var ghost_poison_gained_this_turn = 0

var bounced_projectiles = []
var queued_for_detonation = []
var queued_for_firey_explosion_on_disable = []
var fire_explosion_spawn_frame = -1
var fire_explosion_pos = Vector2()

var autoblocking = false
var do_burst_drain = true
var ignored_self_hitbox = false

var opponent_hp_last = 0
var stored_healing_penalty = 0
var increased_friction = false

var poison_on_slop_stance_enter = 0
var old_stance = ""

const MAX_SLAP_USES = 12
var slap_uses = MAX_SLAP_USES

#	CONSTANT STUFF
const DEFAULT_TICK_RATE = 4
const ADDED_TICK_RATE_OPPONENT_COMBO = 2
const ADDED_TICK_RATE_IN_BLOCKSTRING = 1
const ADDED_TICK_RATE_IN_MELTDOWN = -3
const ADDED_TICK_RATE_OPPONENT_BLOCKING = 2
const ADDED_TICK_RATE_SADNESS = 4
const ADDED_TICK_RATE_OPPONENT_IN_AURA_SAFE = -2

const DEFAULT_RADIATION_RADIUS = "60"

const POISON_POTENCY_MOD_DURING_COMBO = "0.15"
const POISON_POTENCY_MOD_OPPONENT_IN_AURA_SAFE = "0.36"
const POISON_POTENCY_MOD_FOR_BEAM_CHARGE = "0.20"
const POISON_POTENCY_MOD_IN_MELTDOWN = "0.30"

const RADIUS_SIZE_MOD_SELF_ON_TRAIL = "0.25"
const RADIUS_SIZE_MOD_LASSAIL_OUT = "0.15"
const RADIUS_SIZE_MOD_OPPONENT_POISONED = "0.12"
const RADIUS_SIZE_PENALTY_MELTDOWN = "0.25"
const RADIUS_SIZE_MOD_VENOCACHE = "0.40"
const RADIUS_SIZE_TIME_VENOCACHE = 150
const RADIUS_SIZE_MOD_BURST = "0.30"
const RADIUS_SIZE_TIME_BURST = 120

const GLOBAL_POISON_TIME_MULTIPLIER_ON_HIT = "1.9"

const POISON_TIME_MULTIPLIER_ON_SLIMETRAIL = "1.15"
const POISON_TIME_MULTIPLIER_ON_COUNTERHIT = "1.50"
const POISON_TIME_MULTIPLIER_ON_COPYBUNY = "1.35"
const POISON_TIME_MULTIPLIER_IN_MELTDOWN = "1.25"
const POISON_TIME_MULTIPLIER_FOR_BEAM_CHARGE = "1.15"

const OPPONENT_BURST_DRAIN = 7
const BOOST_TIME_MELTDOWN = 150
const MAX_BOOST_TICKS = 500
const MAX_BOOST_MOD = "2.00"
const MAX_SLIMETRAIL_DIST = 50
const SLIMETRAIL_SCENE := preload("res://slimegirl/ramwould/projectiles/SlimeFloor.tscn")
const SLIMETRAIL_FRIC = "0.08"
const SLIMETRAIL_FRIC_HIGH = "0.19"
const SLIMEFIRE_DAMAGE = 1
const MELTDOWN_PULSE_DAMAGE = 20
const BLOCK_PULSE_TICKS = 10
const MAX_GOOP_PULL_FORCE = "0.4"
const MAX_GOOP_DISTANCE = "180"
const MAX_SELF_GOOP_PULL_FORCE = "0.6"
const MAX_SELF_GOOP_DISTANCE = "300"
const MAX_CHERNOBYL_TICKS = 140
const MAX_MELTDOWN_TICKS = 250
const MELTDOWN_COLOR_DISABLED := Color(.3, .3, .3, 1)
const MAX_SNAGTRIK_TICKS = 150
const PND_PUMP_MAX = 6 # +2 for actual pumps/super cost,			dont ask why its like this
const COPYBUNY_SUPER_COST = 1
const MAX_COPYBUNY_CLONES = 3
const MAX_COPYBUNY_DESPAWN_DISTANCE = "310"
const CLONE_DETACH_EXPLODE_DELAY = 6
const POISON_PERCENT_LOSS_ON_PARRY = 0.25
const DEFAULT_PROJECTILE_POISON_PERCENT = "0.40"
const MIN_PROJECTILE_POISON_MOD_STRENGTH = "0.30"
const MAX_PROJECTILE_POISON_MOD_DISTANCE = "700"
const MAX_VENOBUSTER_COOLDOWN = 40
const MAX_VENOCACHE_POISON_INTAKE = 500
const NOXIPASTE_TELEPORT_TICK = 5
const NOXIPASTE_EXPLODE_TICK = 6
const POISON_METER_GAIN = "1.45"
const POISON_METER_GAIN_OPPONENT = "0.66"
const MAX_SNAPCRACKLPOP_TICKS = 55
const MAX_YANK_FORCE_AERIAL = "16.5"
const MAX_YANK_FORCE_GROUNDED = "11.0"
const MAX_YANK_TICKS = 60
const TOXIC_BURST_POISON = 50

const SLIMEPOISON_FX := preload("res://slimegirl/ramwould/FX/SlimePoisonFX.tscn")
const ASSIMILATE_FX := preload("res://slimegirl/ramwould/FX/AssimilateFX.tscn")
const MELTDOWN_FX := preload("res://slimegirl/ramwould/FX/MeltdownFX.tscn")
const EXPANDING_FX := preload("res://slimegirl/ramwould/FX/afterimages/Expanding01.tscn")
const MELT_FX := preload("res://slimegirl/ramwould/FX/MeltFX.tscn")

const BEAM_SCENE = preload("res://slimegirl/ramwould/projectiles/BasicBeam.tscn")
const SHOKWAVE_SCENE = preload("res://slimegirl/ramwould/projectiles/BeamShockwave.tscn")
const SLIMECLONE_SCENE = preload("res://slimegirl/ramwould/projectiles/Slimeclone.tscn")

#	EXTERNAL STUFF
var Original
var options_applied = false
var original_style_applied = false

var debugging = OS.has_feature("editor")
var tween
var prev_camera_zoom = 1.0

var aura_opacity :int= 0
var MOD_RADIUS_OPACITY_MULT = 1.00
var MOD_BUBBLES_OPACITY_MULT = 1.00
var MOD_MELTDOWN_EFFECT = true
var MOD_EXTRA_NOISE = true
var MOD_SILLY_WORD = true

#	character:	projectile tscn path	used to not break certain projectiles when using [Assimilate]
#										only add projectiles here if it breaks the character or the game when assimilated

const PROJECTILES_SLIMEGIRL_CANNOT_ASSIMILATE = {
	"Crossbones":["res://Mod - CrossBones/characters/CrossBones/Projectiles/Cross/DirProjectile (Cross).tscn"],
	"Big Sword":["res://_LamBigSword/BigSword/Big Sword asset/BSDrop.tscn"],
}

onready var codex_lib = get_node_or_null("/root/CharCodexLibrary")
onready var modOptions = get_tree().get_current_scene().get_node_or_null("ModOptions")
onready var modMain = ModLoader.get_node("EverybodySayThankYouTrimay")

#	Tracks poison damage for damage prediction
var poison_track = 0
	
#	ACHIEVEMENT THINGS
var ACH_MOD_AURA_DRAW_SHAPE:int = 0
var ACH_MOD_AURA_NUM_POINTS:int = 0
var ACH_MOD_SLIME_ALT_COLOR:Color = Color.white
var ACH_MOD_SLIME_ALT_REVERSED = false
var ACH_MOD_SLIME_ALT_SPEED = "Off"
var ACH_MOD_SLIME_ALT_OVERRIDE = false
var ACH_MOD_S1_ALT_COLOR:Color = Color.white
var ACH_MOD_S1_ALT_REVERSED = false
var ACH_MOD_S1_ALT_SPEED = "Off"
var ACH_MOD_S1_ALT_OVERRIDE = false
var ACH_MOD_S2_ALT_COLOR:Color = Color.white
var ACH_MOD_S2_ALT_REVERSED = false
var ACH_MOD_S2_ALT_SPEED = "Off"
var ACH_MOD_S2_ALT_OVERRIDE = false

var ACH_MOD_PARTICLE_OVERRIDES = ""
var ACH_MOD_PARTICLE_TINT = ""

var ACH_DATA_TIME:int = 0
const ACH_DATA_TIME_MAX = 86399
const ACH_POWER_THRESHOLD = "2.5"

var slime_color:Color = Color(1, 1, 1, 1)
var slime_color_org:Color = Color(1, 1, 1, 1)
var outline_color:Color = Color(1, 1, 1, 1)
var color_tween_ticks:int = 0
var color_tween2_ticks:int = 0
const MAX_COLOR_TWEEN = 30

var spooderman_tracker = 0

func copy_to(s):
	.copy_to(s)
	s.trail_array = trail_array.duplicate(true)
	s.slime_color = slime_color
	s.slime_color_org = slime_color_org
	s.outline_color = outline_color
	s.lassail_proj = lassail_proj
	s.carrotmine = carrotmine
	if slimeclone_data.empty():
		s.slimeclone_data = []
	else:
		for data in slimeclone_data:
			s.slimeclone_data.append( data.duplicate(true) )
	s.copybuny_xy = copybuny_xy
	s.bounced_projectiles = bounced_projectiles.duplicate(true)
	s.queued_for_detonation = queued_for_detonation.duplicate(true)
	s.fire_explosion_pos = fire_explosion_pos
	s.aura_opacity = aura_opacity
	s.old_stance = old_stance
	s.opponent_hp_last = opponent_hp_last
	
func _ready():
	state_variables.append_array([
		"poison_time",
		"poison_potency",
		"poison_damage_mod",
		"poison_damage_ticks",
		"poison_tick_rate",
		"poison_gained_this_turn",
		"pause_poison_ticks",
		"boost_ticks",
		
		"temporary_size_ticks",
		"burst_size_ticks",
		"aura_multiplier_while_inf",
		
		"meltdown_ticks",
		"chernobyl_ticks",
		"snapcracklpop_ticks",
		"goop_global_x",
		"goop_global_y",
		"gooped_obj_name",
		"yank_ticks",
		"disable_goop_visual",
		
		"Original",
		"options_applied",
		
		"aura_opacity",
		"MOD_RADIUS_OPACITY_MULT",
		"MOD_BUBBLES_OPACITY_MULT",
		"MOD_MELTDOWN_EFFECT",
		"MOD_EXTRA_NOISE",
		"MOD_SILLY_WORD",
		"prev_camera_zoom",
		
		"ACH_MOD_AURA_NUM_POINTS",
		"ACH_MOD_SLIME_ALT_COLOR",
		"ACH_MOD_SLIME_ALT_REVERSED",
		"ACH_MOD_SLIME_ALT_SPEED",
		"ACH_MOD_SLIME_ALT_OVERRIDE",
		"ACH_MOD_S1_ALT_COLOR",
		"ACH_MOD_S1_ALT_REVERSED",
		"ACH_MOD_S1_ALT_SPEED",
		"ACH_MOD_S1_ALT_OVERRIDE",
		"ACH_MOD_S2_ALT_COLOR",
		"ACH_MOD_S2_ALT_REVERSED",
		"ACH_MOD_S2_ALT_SPEED",
		"ACH_MOD_S2_ALT_OVERRIDE",
		
		"color_tween_ticks",
		"color_tween2_ticks",
		"slime_color",
		"slime_color_org",
		"outline_color",
		
		"debugging",
		"do_burst_drain",
		
		"carrotmine",
		
		"syringe_pos_global_x",
		"syringe_pos_global_y",
		"syringe_length_ratio",
		"syringe_ticks",
		"syringe_max",
		
		"snag_pos_global_x",
		"snag_pos_global_y",
		"snag_length_ratio",
		"snag_ticks",
		"snag_max",
		
		"ignored_self_hitbox",
		
		"opponent_hp_last",
		"stored_healing_penalty",
		"increased_friction",
		"poison_on_slop_stance_enter",
		"old_stance",
		"slap_uses",
		
		"combo_count_on_burst",
		"copybuny_active",
		"copybuny_this_turn",
		"copybuny_index",
		"noxipaste_tick",
		"noxipaste_active",
		"noxipaste_queue_active",
		"noxipaste_this_turn",
		"noxipaste_effect_this_turn",
		"noxipaste_flip_state",
		"noxipaste_queue_explode",
		"noxipaste_explode",
		"noxipaste_explode_this_turn",
		"current_slimeclone_state_name",
		])
		
	airmelt.set_material( sprite.get_material() )
	sharpeardo.set_material( sprite.get_material() )
	snagarm_end.set_material( sprite.get_material() )
		
	var game:Game = Global.current_game
	if is_instance_valid(game):
		game.connect("game_ended", self, "beat_hustler")

	if not is_ghost:
		Original = self
	
	connect("poison_booster", $"%Radiation", "_on_Slimegirl_poison_booster")
	connect("meltdown_alarm", $"%MeltdownAlarm", "_on_meltdown_alarm")
	


func init(p=null):
	if not initialized:
#		this whole thing is for the clock that slimegirl's aura can base her colors off of
		var fighter_extra = player_extra_params_scene.instance()
		if fighter_extra:
			fighter_extra.initializing = true
			process_extra( fighter_extra.get_extra() )
			fighter_extra.initializing = false
	
	.init(p)
	
	
	$"%CopybunyReasonLabel".visible = false
	$"%AuraController".visible = true
	
	opponent_on_fire = false
	do_burst_drain = true
		
	if codex_lib:
		if debugging:
			codex_lib.unlock_achievement(self, "achivement_toxic")
			
			if Input.is_key_pressed(KEY_ASCIITILDE):
				codex_lib.relock_achievement(self, "achivement_beat_pixie")
				codex_lib.relock_achievement(self, "achivement_beat_bunbun")
				codex_lib.relock_achievement(self, "achivement_power")
				codex_lib.relock_achievement(self, "achivement_spooberman")
				codex_lib.relock_achievement(self, "achivement_toxic")
				codex_lib.set_counter(self, "poison_tracker", 0)
		
	MOD_RADIUS_OPACITY_MULT = 0.5
	MOD_BUBBLES_OPACITY_MULT = 1.0
	MOD_MELTDOWN_EFFECT = true
	MOD_EXTRA_NOISE = true
	MOD_SILLY_WORD = true
	
	ACH_MOD_AURA_DRAW_SHAPE = -1
	ACH_MOD_AURA_NUM_POINTS = 16
	ACH_MOD_SLIME_ALT_COLOR = Color("ffffff")
	ACH_MOD_SLIME_ALT_REVERSED = false
	ACH_MOD_SLIME_ALT_SPEED = "Off"
	ACH_MOD_SLIME_ALT_OVERRIDE = false
	ACH_MOD_S1_ALT_COLOR = Color("00b035")
	ACH_MOD_S1_ALT_REVERSED = false
	ACH_MOD_S1_ALT_SPEED = "Off"
	ACH_MOD_S1_ALT_OVERRIDE = false
	ACH_MOD_S2_ALT_COLOR = Color("ff0000")
	ACH_MOD_S2_ALT_REVERSED = false
	ACH_MOD_S2_ALT_SPEED = "Off"
	ACH_MOD_S2_ALT_OVERRIDE = false
	ACH_MOD_PARTICLE_OVERRIDES = "Default"
	ACH_MOD_PARTICLE_TINT = "None"
	
	if modOptions != null:
		MOD_RADIUS_OPACITY_MULT = modOptions.get_setting("SL_settings", "rad_opacity") / 100.00
		MOD_BUBBLES_OPACITY_MULT = modOptions.get_setting("SL_settings", "bubbl_opacity") / 100.00
		MOD_MELTDOWN_EFFECT = modOptions.get_setting("SL_settings", "meltdown_flash")
		MOD_EXTRA_NOISE = not modOptions.get_setting("SL_settings", "disable_extra_noise")
		MOD_SILLY_WORD = not modOptions.get_setting("SL_settings", "disable_silly_words")
	
	if debugging:
#		apply_poison(120)
		pass

func apply_damage_ticks(ticks:int):
	poison_damage_ticks += ticks
	poison_damage_ticks = Utils.int_clamp(poison_damage_ticks, 0, MAX_POISON_DAMAGE_TICKS)
	
func apply_poison(ticks:int):
	if ticks > 0:
		achiev_counter("poison_tracker", ticks)
		unlock_achiev("achivement_toxic")
	
	var gained_poison = Utils.int_max(-poison_time, ticks)
			
	poison_gained_this_turn += gained_poison
	poison_time += ticks

func is_poisoned()->bool:
	return poison_time > 0
	
func poison_tick():

#	the original had add_penalty(- 25) called everytime take_damage() was called which isn't what i needed it to do, so i replicated it for poison ticks
	if opponent.invulnerable:
		return
	if pause_poison_ticks:
		return
	if stance == "Intro":
		return
	
	poison_time -= 1
	if poison_time % 4 == 0:
		var opponent_pos_global = opponent.get_center_position_float()
		var color = color_else_slime()
		color.a = MOD_BUBBLES_OPACITY_MULT
		_spawn_particle_effect(SLIMEPOISON_FX, opponent_pos_global, Vector2(), color)

	var damage:int = fixed.round( calculate_poison_damage() )
	var minimum:int = fixed.round( calculate_poison_damage() ) / 3
	var stale:int = Utils.int_max(0, combo_count-4)
	
	while true:
		if (opponent.hp - Utils.int_max(damage, minimum)) > 2:
			break
			
		else:
			damage -= 1
			minimum = Utils.int_min(damage, minimum)
		
			if damage < 1:
				return
			
	if poison_time <= 0:
		trail_hp = get_visual_hp()
		
	opponent.gain_burst_meter(damage / BURST_ON_DAMAGE_AMOUNT)
	
	damage = Utils.int_max(opponent.combo_stale_damage(damage, stale), 1)
	damage = Utils.int_max(damage, minimum)
	damage = Utils.int_max(opponent.guts_stale_damage(damage), 1)
	if parry_combo:
		damage = fixed.round(fixed.mul(str(damage), opponent.PARRY_COMBO_SCALING))
	damage = fixed.round(fixed.mul(str(damage), opponent.get_penalty_damage_modifier()))
	
	var meter_gain = fixed.round(fixed.mul(str(damage / opponent.DAMAGE_SUPER_GAIN_DIVISOR), POISON_METER_GAIN))
	gain_super_meter(meter_gain)
	
	var meter_gain_opponent = fixed.round(fixed.mul(str(damage / opponent.DAMAGE_TAKEN_SUPER_GAIN_DIVISOR), POISON_METER_GAIN_OPPONENT))
	opponent.gain_super_meter(meter_gain_opponent)
	
	damage = fixed.round(fixed.mul(fixed.mul(str(damage), opponent.damage_taken_modifier), global_damage_modifier))
	damage = Utils.int_max(damage, 1)
	damage = Utils.int_min(damage, opponent.hp-1)
		
	combo_damage += damage
	poison_track += damage
	opponent.hp -= damage
	
	if opponent.hp < 0:
		opponent.hp = 0
	if (opponent.current_state().get("IS_NEW_PARRY") and opponent.current_state().push):
		if opponent.hp <= 0:
			opponent.hp = 1

func poison_damage_tick():
	if poison_damage_ticks > 0:
		poison_damage_ticks -= 1
		poison_damage_mod += 1

func calculate_poison_damage()->String:
	var power = fixed.mul(poison_potency, calculate_boost_damage())
	power = fixed.mul(power, "0.65")
	power = fixed.add(power, str(poison_damage_mod-1))
	if fixed.lt( power,"1.0" ):
		power = "1.0"
		
	return power
	
func has_poison_boost()->bool:
	return boost_ticks > 0
	
func calculate_boost_damage()->String:
	var boost_multiplier = "1.0"
	if not has_poison_boost():
		return boost_multiplier
	
	
	var d = fixed_map("0.0", str(MAX_BOOST_TICKS), "0.0", "1.0", str(boost_ticks))
	var boost_damage = fixed.lerp_string("1.0", MAX_BOOST_MOD, d)
	if fixed.ge(boost_damage,MAX_BOOST_MOD):
		boost_damage = MAX_BOOST_MOD
		
	return boost_damage

func boost_poison(ticks:int = -1, effect = true):
	if ticks <= 0:
		ticks = 0
	boost_ticks += ticks
	
	if effect:
		var pos = radius_center()
		_spawn_particle_effect(ASSIMILATE_FX, pos, Vector2(), color_else_slime("style_1"))
		
		play_sound("PoisonBoost")
		play_sound("HitBass")
		global_hitlag(6, true)
	
		emit_signal("poison_booster")


















func apply_style(style):
#	if not original_style_applied:
#		original_style_applied = true
#		slime_color_org = sprite.get_material().get_shader_param("color")
		
	.apply_style(style)
	
	if style != null:
		if not is_ghost and Global.enable_custom_colors:
			if ACH_MOD_SLIME_ALT_SPEED == "Off":
				pass
				
			else:
				if ACH_MOD_SLIME_ALT_OVERRIDE:
					ACH_MOD_SLIME_ALT_COLOR = (P1_COLOR if id == 1 else P2_COLOR)
				var new_color = _style_slime(ACH_MOD_SLIME_ALT_SPEED, slime_color_org, ACH_MOD_SLIME_ALT_COLOR)
#				set_color( new_color )
					
		if not options_applied:
			options_applied = true
			slime_color_org = sprite.get_material().get_shader_param("color")
			
			match style.get("extra_shape1", "None"):
#				Simple Shapes
				"Line": ACH_MOD_AURA_DRAW_SHAPE = 2
				"Triangle": ACH_MOD_AURA_DRAW_SHAPE = 3
				"Square": ACH_MOD_AURA_DRAW_SHAPE = 4
				"Pentagon": ACH_MOD_AURA_DRAW_SHAPE = 5
				"Hexagon": ACH_MOD_AURA_DRAW_SHAPE = 6	
				"Octagon": ACH_MOD_AURA_DRAW_SHAPE = 8
					
#				Special Shapes
				"Star": ACH_MOD_AURA_DRAW_SHAPE = 100
				"X": ACH_MOD_AURA_DRAW_SHAPE = 101
				"*": ACH_MOD_AURA_DRAW_SHAPE = 102
				"Mimic": ACH_MOD_AURA_DRAW_SHAPE = 103
				"Mimic (Full)": ACH_MOD_AURA_DRAW_SHAPE = 104
				"Circle": ACH_MOD_AURA_DRAW_SHAPE = 105
				"Divided Circle": ACH_MOD_AURA_DRAW_SHAPE = 106
				"Explosion":ACH_MOD_AURA_DRAW_SHAPE = 107
				
#				Don't Draw
				_: ACH_MOD_AURA_DRAW_SHAPE = -1
					
					
			ACH_MOD_AURA_NUM_POINTS = style.get("num_points", 16)
			
			ACH_MOD_SLIME_ALT_COLOR = style.get("slime_alt_color", Color("ffffff"))
			ACH_MOD_SLIME_ALT_REVERSED = style.get("slime_alt_reversed", false)
			ACH_MOD_SLIME_ALT_SPEED = style.get("slime_alt_speed", "Off")
			if ACH_MOD_SLIME_ALT_SPEED == null: ACH_MOD_SLIME_ALT_SPEED = "Off"
			ACH_MOD_SLIME_ALT_OVERRIDE = style.get("slime_alt_override", false)
			
			ACH_MOD_S1_ALT_COLOR = style.get("s1_alt_color", Color("00b035"))
			ACH_MOD_S1_ALT_REVERSED = style.get("s1_alt_reversed", false)
			ACH_MOD_S1_ALT_SPEED = style.get("s1_alt_speed", "Off")
			if ACH_MOD_S1_ALT_SPEED == null: ACH_MOD_S1_ALT_SPEED = "Off"
			ACH_MOD_S1_ALT_OVERRIDE = style.get("s1_alt_override", false)
			
			ACH_MOD_S2_ALT_COLOR = style.get("s2_alt_color", Color("ff0000"))
			ACH_MOD_S2_ALT_REVERSED = style.get("s2_alt_reversed", false)
			ACH_MOD_S2_ALT_SPEED = style.get("s2_alt_speed", "Off")
			if ACH_MOD_S2_ALT_SPEED == null: ACH_MOD_S2_ALT_SPEED = "Off"
			ACH_MOD_S2_ALT_OVERRIDE = style.get("s2_alt_override", false)
			
			ACH_MOD_PARTICLE_OVERRIDES = style.get("particle_overrides", "Default")
			ACH_MOD_PARTICLE_TINT = style.get("particle_tint", "None")
			
func _process(delta):
#	._process(delta)
	
	var cur_material = sprite.get_material()

	slime_color = cur_material.get_shader_param("color")
	outline_color = cur_material.get_shader_param("outline_color")
	
	if current_state() and ("Melt_Intro" in current_state().state_name):
		if not is_ghost:
			visual_radius = fixed.add( fixed.mul(fixed.sub("0",visual_radius),"0.085"), visual_radius )
	
	elif current_state() and ("Retail" in current_state().state_name) and current_state().detaching:
		if not is_ghost:
			visual_radius = fixed.add( fixed.mul(fixed.sub("0",visual_radius),"0.085"), visual_radius )
	
	elif hp <= 0:
		if not is_ghost:
			visual_radius = fixed.add( fixed.mul(fixed.sub("0",visual_radius),"0.050"), visual_radius )
			
	else:
		visual_radius = fixed.add( fixed.mul(fixed.sub(current_radiation_radius,visual_radius),"0.085"), visual_radius )
	
	needle.default_color = color_else_slime("outline")
	venocachewind.modulate = color_else_slime()
	meltdown_aura.modulate = color_else_slime("style_2")

	reversed_material = cur_material.duplicate()
	if cur_material.get_shader_param("use_outline"):
		reversed_material.set_shader_param("color", cur_material.get_shader_param("outline_color"))
		reversed_material.set_shader_param("outline_color", cur_material.get_shader_param("color"))
	
	if is_ghost:
		if is_instance_valid(Original):
			Original.poison_gained_this_turn = poison_gained_this_turn
			Original.poison_track = poison_track
			
	var label_to_change
	var ui = get_tree().get_current_scene()
	if MOD_SILLY_WORD:
		var id_or_none = "" if id == 1 else "2"
		label_to_change = "HudLayer/HudLayer/P%sCounterLabel" % [id]
		ui.get_node(label_to_change).text = "HAPY BORTHDAY!"
		label_to_change = "HudLayer/HudLayer/P%sAdvantageLabel" % [id]
		ui.get_node(label_to_change).text = "INICOTINE"
		label_to_change = "HudLayer/HudLayer/P%sSadnessLabel" % [id]
		if penalty_ticks <= 0: ui.get_node(label_to_change).text = "AW MAN!"
		else: ui.get_node(label_to_change).text = "DAY RUINED"
		label_to_change = "HudLayer/HudLayer/P%sGuardBreakLabel" % [id]
		ui.get_node(label_to_change).text = "WHOOPS!"
		label_to_change = "HudLayer/HudLayer/FeintDisplay/Label%s" % [id_or_none]
		ui.get_node(label_to_change).text = "Fwee Cancer"
		label_to_change = "HudLayer/HudLayer/TopBar2/P%sBurstMeter/ReadyLabel" % [id]
		ui.get_node(label_to_change).text = "BURST!?"
		label_to_change = "HudLayer/HudLayer/HBoxContainer/P%sComboCounter/P%sHitLabel" % [id, id]
		ui.get_node(label_to_change).text = "Hitz"
		label_to_change = "UILayer/GameUI/BottomBar/ActionButtons/VBoxContainer%s/P%sActionButtons/BottomRow/PanelContainer/CategoryContainer" % [id_or_none, id]
		
		var category = ui.get_node(label_to_change)
		for node in category.get_children():
			if node.get("label_text"):
				match node.label_text:
					"Defense":
						node.label_text = "Da Fence"
					"Super":
						node.label_text = "Supper"
					"Special":
						node.label_text = "Spacial"
					"Attack":
						node.label_text = "A Tack"
					"Movement":
						node.label_text = "Shmovin'"
		label_to_change = "UILayer/GameUI/BottomBar/ActionButtons/VBoxContainer%s/P%sActionButtons/BottomRow/PanelContainer/CategoryContainer/TurnButtons" % [id_or_none, id]
		var button_holder = ui.get_node(label_to_change)
		for button in button_holder.get_children():
			if button is Button:
				match button.name:
					"SelectButton":
						var rng_text = [
							"Lock In",
							"Lock In",
							"Lock In",
							"Lock In",
							"Lock In",
							"GO!", 
							"WAIT!", 
							"Slimey",
							"Ready?",
							"Luck In",
							"Chicken",
							"Get' Em",
							"Get' It",
							"Look In",
							"Lokd In",
							"Good?",
							"We Cool",
							"It's me",
							"My Turn",
							]
						if combo_count > 0 and opponent.is_in_hurt_state():
							rng_text.append_array([
								":)",
								":P",
								":D",
								":3",
								"OwO",
								"UwU",
								"DoT Dmg",
								"rawr xd",
							])
						if opponent.combo_count > 0 and is_in_hurt_state():
							rng_text = [
								"Lock In",
								"DI?",
								"Im Okay",
								"Ouch",
								"OOF",
								"Ouchies",
								":(",
								"Bruh",
								"Bruv",
								"...",
								"Im Good",
								"Aw Man",
								"Whyyy?",
							]
						var game :Game= Global.current_game
						if not game.game_paused:
							button.text = randi_choice_static(rng_text)
					"ContinueButton":
						if button.text == "Hold":
							button.text = "Then..."
					"FeintButton":
						if button.text == "Free":
							button.text = "Fwee"
					"ReverseButton":
						if button.text == "Flip":
							button.text = "Flop"
					"UndoButton":
						if button.text == "Undo":
							button.text = "Oops"
					"AutoButton":
						if button.text == "Auto":
							button.text = "Que?"
							
		$YouLabel.text = $YouLabel.text.replace("You", "Me")
		$ActionableLabel.text = $ActionableLabel.text.replace("Ready", "Rwedy")
		$ActionableLabel.text = $ActionableLabel.text.replace("Interrupt", "Inawupt")

		$BlockFrameLabel.text = $BlockFrameLabel.text.replace("Parry", "Nu uh")
		$HitFrameLabel.text = $HitFrameLabel.text.replace("Hit", "Ouchies")
	
	match ACH_MOD_PARTICLE_TINT:
		"Slime": particles.modulate = color_else_slime("slime")
		"Outline": particles.modulate = color_else_slime("outline")
		"Style 1": particles.modulate = color_else_slime("style_1")
		"Style 2": particles.modulate = color_else_slime("style_2")
		_: pass
	
	var _obj = self
	if lassail_projectile():
		_obj = lassail_projectile()
		
	for aura in aura_particles:
		if (aura is CustomTrailParticle):
			if aura.attached_to_limb:
				continue
				
			if "Scale" in ACH_MOD_PARTICLE_OVERRIDES:
				aura.particles.set_emission_shape(CPUParticles2D.EMISSION_SHAPE_SPHERE)
				aura.particles.set_emission_sphere_radius(float(visual_radius))
				aura.particles.visible = fixed.gt(visual_radius, "0.0")
				
			if "Snap" in ACH_MOD_PARTICLE_OVERRIDES:
				aura.set_x_offset( aura_controller.position.x - _obj.sprite.offset.x )
				aura.set_y_offset( aura_controller.position.y - _obj.sprite.offset.y )
				


















func aura_stat_tick():
	if opponent.combo_count <= 0:
		if opponent_in_radius():
			poison_potency = fixed.add(poison_potency, POISON_POTENCY_MOD_OPPONENT_IN_AURA_SAFE)
			poison_tick_rate += ADDED_TICK_RATE_OPPONENT_IN_AURA_SAFE
	
		if combo_count > 0:
			poison_potency = fixed.add(poison_potency, POISON_POTENCY_MOD_DURING_COMBO)
			
	else:
		poison_tick_rate += ADDED_TICK_RATE_OPPONENT_COMBO
		
	if opponent.current_state().get("IS_NEW_PARRY"):
		poison_tick_rate += ADDED_TICK_RATE_OPPONENT_BLOCKING
	
	if in_blockstring:
		poison_tick_rate += ADDED_TICK_RATE_IN_BLOCKSTRING
		
	if lassail_projectile():
		extra_radius_size_mult = fixed.add(extra_radius_size_mult,RADIUS_SIZE_MOD_LASSAIL_OUT)
	
	if is_poisoned():
		extra_radius_size_mult = fixed.add(extra_radius_size_mult,RADIUS_SIZE_MOD_OPPONENT_POISONED)
		
	if queued_beam_shockwave:
		poison_potency = fixed.add(poison_potency, POISON_POTENCY_MOD_FOR_BEAM_CHARGE)
		
	if object_on_trail(self):
		extra_radius_size_mult = fixed.add(extra_radius_size_mult,RADIUS_SIZE_MOD_SELF_ON_TRAIL)
	
	if penalty_ticks > 0:
		poison_tick_rate += ADDED_TICK_RATE_SADNESS
		extra_radius_size_mult = fixed.div(extra_radius_size_mult,"2.0")

	if in_meltdown():
		extra_radius_size_mult = fixed.sub(extra_radius_size_mult, RADIUS_SIZE_PENALTY_MELTDOWN)
		poison_potency = fixed.add(poison_potency, POISON_POTENCY_MOD_IN_MELTDOWN)
		poison_tick_rate += ADDED_TICK_RATE_IN_MELTDOWN
		
	if temporary_size_ticks > 0:
		extra_radius_size_mult = fixed.add(extra_radius_size_mult,RADIUS_SIZE_MOD_VENOCACHE)
		temporary_size_ticks -= 1
		
	if burst_size_ticks > 0:
		extra_radius_size_mult = fixed.add(extra_radius_size_mult,RADIUS_SIZE_MOD_BURST)
		burst_size_ticks -= 1
	
#	if stance == "Sloppy":
#		extra_radius_size_mult = fixed.mul(extra_radius_size_mult,"0.75")
		
func turn_start_effects():
	noxipaste_this_turn = false
	noxipaste_effect_this_turn = false
	noxipaste_explode_this_turn = false
	if is_ghost:
		poison_gained_this_turn = 0
		poison_track = 0

	$"%CopybunyReasonLabel".visible = false

func turn_end_effects():
	pass

func process_action(queued_action):
	if queued_action is String:
		if queued_action == "Continue":
			pass
					
		else:
			var state_name = current_state().state_name
			if queued_action != state_name:
				if not copybuny_active:
					copybuny_this_turn = false
					
			if not noxipaste_active:
				noxipaste_queue_active = false
					
func on_state_started(state):
	.on_state_started(state)
	
	on_slimetrail_this_state = object_on_trail(self)
	on_fire_this_state = false
	opponent_on_slimetrail_this_state = object_on_trail(opponent)
	
	var ignore_these = ["Snagtrik_Throw"]
	if state is ThrowState and not ignore_these.has(state.name):
		disable_goop_visual = true
		
func on_state_ended(state):
	.on_state_ended(state)
	
	disable_goop_visual = false
	





















	
func tick_before():
	hitlag_ticks
	for hb_name in parried_hitboxes:
		var hb :Hitbox= hitbox_from_name(hb_name)
		if hb and hb.hitbox_type == Hitbox.HitboxType.Burst:
			do_burst_drain = false
	
	.tick_before()
	
	poison_potency = "1.0"
	extra_radius_size_mult = "1.0"
	poison_tick_rate = DEFAULT_TICK_RATE
	poison_damage_mod = 1
	
	aura_stat_tick()
	poison_damage_tick()
		
	poison_tick_rate = Utils.int_max(poison_tick_rate, 1)
	
	if is_poisoned():
		if current_tick % poison_tick_rate == 0:
			poison_tick()
			
func tick():
	var curr_state = current_state()
	var prev_state = previous_state()
	var opponent_state = opponent.current_state()
	
	var BURST_STATES = ["Burst", "DefensiveBurst", "OffensiveBurst"]
	if opponent_state:
		if (opponent_state.state_name in BURST_STATES):
			if do_burst_drain:
				apply_poison(-OPPONENT_BURST_DRAIN)
			reset_goop( true )
		
		else:
			do_burst_drain = true
	
	.tick()
	
	if old_stance == "Sloppy" and stance != "Sloppy":
		poison_on_slop_stance_enter = 0
	
	if old_stance != "Sloppy" and stance == "Sloppy":
		poison_on_slop_stance_enter = poison_time
	
	old_stance = stance
	
	var opp_real_name = opponent.get("charname")
	if (opp_real_name is String) and opp_real_name == "Big Sword":
		opponent.customcollision = opponent.current_state().state_name == "Grabbed" and opponent.broken == 0
		
	if ghost_ready_tick != null or opponent.ghost_ready_tick != null:
		$"%CopybunyReasonLabel".visible = false
			
	_center_aura()
					
	if game_tick == noxipaste_tick:
		if noxipaste_queue_active:
			try_teleport_clone()
			
		elif noxipaste_queue_explode:
			if not queued_for_detonation.empty():
				try_explode_clone(queued_for_detonation, false)
				queued_for_detonation.clear()
				
	if queued_beam_shockwave and MOD_EXTRA_NOISE:
		if current_tick % 22 == 0:
			beam_charge_queued_effect()
		if current_tick % 66 == 0:
			play_sound("BeamQueuePing")
			
	_meltdown_tick()
	_chernobyl_tick()
	_snapcracklpop_tick()
	_slimeclones_tick()
	_heal_penalty_tick()
	
	if venobuster_ticks > 0: venobuster_ticks -= 1
	if boost_ticks > 0: boost_ticks -= 1
	if yank_ticks > 0: yank_ticks -= 1
		
	current_radiation_radius = fixed.mul( DEFAULT_RADIATION_RADIUS, poison_potency )
	current_radiation_radius = fixed.mul( current_radiation_radius, extra_radius_size_mult )
	if infinite_resources:
		current_radiation_radius = fixed.mul( 
			current_radiation_radius, 
			fixed_map("0", "100", "0.0", "5.0", str(aura_multiplier_while_inf))
			)
		
	match stance:
		"Intro": current_radiation_radius = "0"
		"Normal": pass
		"Sloppy": pass
			
	_syringe_tick()
	
	snag_cooldown -= 1
	if color_tween_ticks > 0: color_tween_ticks -= 1
	if color_tween2_ticks > 0: color_tween2_ticks -= 1
		
	_snagtrik_tick()
	_airmelt_tick()
		
	if current_tick % 2 == 0:
		slime_trail_tick()
	
	_goop_tick()
	
	if fixed.ge( calculate_poison_damage(), ACH_POWER_THRESHOLD ):
		unlock_achiev("achivement_power")
		pass
		
	if opponent_on_fire:
		fire_trail()
		opponent_on_fire = false

	if is_grounded():
		if spooderman_tracker >= 2:
			unlock_achiev("achivement_spooberman")
		spooderman_tracker = 0
		clear_bounced_projectiles()
		pass
	
	poison_time = Utils.int_max(poison_time, 0)















		
func _heal_penalty_tick():

	if is_poisoned() and stance != "Intro":
		var temp_penalty = opponent_hp_last - opponent.hp
#		if Utils.int_abs(temp_penalty) > opponent.MAX_HEALTH / 2:
#			pass
#
#		else:
		if opponent_hp_last < opponent.hp:

			stored_healing_penalty += temp_penalty

			var penalty_poison = stored_healing_penalty / 3
			stored_healing_penalty -= penalty_poison
			stored_healing_penalty = Utils.int_max(0, stored_healing_penalty)

			if penalty_poison < 0:
				if opponent.hp >= opponent.MAX_HEALTH - 300:
					return
				opponent.hp += penalty_poison

	opponent_hp_last = opponent.hp

func yank_slimegirl(yank_aerial:bool):
	yank_ticks = MAX_YANK_TICKS
	play_sound("Yank")
	var grounded = false
	
	update_data()
	var my_pos = get_pos()
	var other_pos = {x = goop_global_x, y = goop_global_y}
	var vec_to_goop = fixed.normalized_vec(str(other_pos.x - my_pos.x), str(other_pos.y - my_pos.y))
		
	var dir = fixed.normalized_vec_times(vec_to_goop.x, vec_to_goop.y, MAX_YANK_FORCE_AERIAL if yank_aerial else MAX_YANK_FORCE_GROUNDED)
	if not yank_aerial:
		grounded = true
		if fixed.lt(dir.y,"0"):
			dir.y = "0"

	elif fixed.lt(dir.y,"0"):
		dir.y = fixed.mul(dir.y, "0.75")
	
#	if is_gooped_opponent():
#		try_detonate_mine()
		
	set_grounded( grounded )
	reset_goop(true)
	apply_force(dir.x, dir.y)
	
	
func _can_yank_self()->bool:
	if yank_ticks <= 0 and is_gooped():
		return true
	return false
	
func object_on_trail(obj:BaseObj)->bool:
	if obj:
		if obj == self:
			return obj.is_grounded() and (slimetrail_near_obj(self) or not in_chernobyl())
		return obj.is_grounded() and slimetrail_near_obj(obj)
		
	return false

##############################################
func slimetrail_near_obj(obj:BaseObj)->bool:
	for trail in objs_map.values():
		if trail is BaseProjectile:
			if trail.disabled:
				continue
			if not trail.is_in_group("SlimeFloor"):
				continue
			if trail.is_in_group("SlimeFloor") and trail.get("IS_FIRE"):
				continue
			if obj_in_width(obj, trail):
				return true
	return false
	
func slime_trail_tick():
	if stance == "Intro":
		return
	update_data()

	if is_grounded() and not slimetrail_near_obj(self) and not is_in_hurt_state(false) and not in_chernobyl():
		if not (current_state().state_name.begins_with("Goodrider")):
			create_slime_trail(self)
	
	if opponent.is_grounded() and not slimetrail_near_obj(opponent) and is_gooped_opponent():
		create_slime_trail(opponent)
	
	update_slime_trail_pos()
	
func create_slime_trail(obj_or_position, detect_other_trails=true):
	if obj_or_position is BaseObj:
		if (detect_other_trails and not slimetrail_near_obj(obj_or_position) and obj_or_position.data and obj_or_position.get_pos().y == 0) or not detect_other_trails:
			var pos = obj_or_position.get_hurtbox_center()
			var trail = spawn_object(SLIMETRAIL_SCENE, pos.x, 0, false, null, false)
			trail.slime_length = get_slimetrail_dist()
			trail_array.append(trail.name)
			
	if (obj_or_position is Dictionary) or (obj_or_position is Vector2):
		var trail = spawn_object(SLIMETRAIL_SCENE, int(obj_or_position.x), 0, false, null, false)
		trail.slime_length = get_slimetrail_dist()
		trail_array.append(trail.name)
	
func get_slimetrail_dist():
	if temporary_size_ticks > 0:
		return MAX_SLIMETRAIL_DIST + 30
	return MAX_SLIMETRAIL_DIST
	
func get_last_trail_name():
	if trail_array.empty():
		return null
	return trail_array.front()
	
func get_first_trail_name():
	if trail_array.empty():
		return null
	return trail_array.back()
	
func can_teleport()->bool:
	var at_least_one_name = (get_last_trail_name() != null) or (get_first_trail_name() != null)
	return at_least_one_name

func can_teleport_or_lassail()->bool:
	return can_teleport() or lassail_projectile()

func update_slime_trail_pos():
	if get_last_trail_name():
		last_trail_center_x = objs_map[get_last_trail_name()].get_hurtbox_center().x
	if get_first_trail_name():
		first_trail_center_x = objs_map[get_first_trail_name()].get_hurtbox_center().x

func opponent_in_radius(slimegirl_only=false)->bool:
	return obj_in_radius(opponent, slimegirl_only)
	
func obj_in_radius(obj, slimegirl_only=false)->bool:
	if fixed.eq(current_radiation_radius, "0.0"):
		return false
	
	var my_pos = radius_center()
	if slimegirl_only:
		my_pos.x = get_hurtbox_center().x
		my_pos.y = get_hurtbox_center().y

	obj.update_data()
	var obj_pos = obj.get_pos()
	var dist = fixed.vec_dist(str(my_pos.x), str(my_pos.y), str(obj_pos.x), str(obj_pos.y))
	return fixed.lt( dist, current_radiation_radius )

func syringe_extend(speed, fixed_position_global):
	syringe_max = speed
	syringe_ticks = speed
	if fixed_position_global and (fixed_position_global is Vector2):
		syringe_pos_global_x = fixed_position_global.x
		syringe_pos_global_y = fixed_position_global.y

func syringe_is_out()->bool:
	return syringe_ticks > 0

func _syringe_tick():
	if syringe_ticks <= 0:
		return
	syringe_ticks -= 1
#	var time:float = clamp( syringe_ticks/syringe_max, 0.0, 1.0 )
	var t = fixed_map("0.0", str(syringe_max), "1.0", "0.0", str(syringe_ticks))
	syringe_length_ratio = syringe_curve.interpolate(float(t))
	
func snagtrik_extend(speed, fixed_position_global):
	snag_max = speed
	snag_ticks = speed
	snag_cooldown = MAX_SNAGTRIK_TICKS
	if fixed_position_global and (fixed_position_global is Vector2):
		snag_pos_global_x = fixed_position_global.x
		snag_pos_global_y = fixed_position_global.y
	
func snagtrik_is_out()->bool:
	return snag_cooldown > 0

func _snagtrik_tick():
	if snag_ticks <= 0:
		return
	snag_ticks -= 1
#	var time:float = clamp( snag_ticks/snag_max, 0.0, 1.0 )
	var t = fixed_map("0.0", str(snag_max), "1.0", "0.0", str(snag_ticks))
	snag_length_ratio = snag_curve.interpolate(float(t))
	
func _airmelt_tick():
	if airmelt_ticks <= 0:
		return
	airmelt_ticks -= 1
	
#	var time:float = clamp( airmelt_ticks/airmelt_max, 0.0, 1.0 )
	var t = fixed_map("0.0", str(airmelt_max), "1.0", "0.0", str(airmelt_ticks))
	airmelt_length_ratio = airmelt_curve.interpolate(float(t))
	
func obj_in_width(obj_from:BaseObj, obj_to:BaseObj)->bool:
	obj_from.update_data()
	obj_to.update_data()
	
	var local_pos = obj_from.obj_local_center(obj_to).x
	if obj_to.get("slime_length"):
		return Utils.int_abs(local_pos) < obj_to.slime_length
	if obj_to.get("fire_length"):
		return Utils.int_abs(local_pos) < obj_to.fire_length
		
	return false
		
func apply_fric():
	if on_slimetrail_this_state:
		var apply_the_fric = increased_friction and is_grounded()
		apply_x_fric(SLIMETRAIL_FRIC if not apply_the_fric else SLIMETRAIL_FRIC_HIGH)
	else:
		.apply_fric()
		
func start_meltdown():
	meltdown_ticks = MAX_MELTDOWN_TICKS
	meltdown_aura.start_emitting()
	boost_poison( BOOST_TIME_MELTDOWN, false )
	meltdown_pulse( false )
	
func start_chernobyl():
	chernobyl_ticks = MAX_CHERNOBYL_TICKS
	reset_goop(true)
	emit_signal("chernobyl_fire")
	meltdown_pulse( false )
	
func in_meltdown()->bool:
	return meltdown_ticks > 0

func meltdown_disabled()->bool:
	return opponent.combo_count > 0
	
func in_chernobyl()->bool:
	return chernobyl_ticks > 0

func _snapcracklpop_tick():
	if snapcracklpop_ticks <= 0:
		return
	snapcracklpop_ticks -= 1
	
func _meltdown_tick():
	if meltdown_ticks <= 0:
		if meltdown_aura.emitting:
			meltdown_aura.stop_emitting()
		return
	meltdown_ticks -= 1
	if meltdown_disabled():
		return
	if current_tick % 60 == 0:
		meltdown_pulse()
	if opponent_in_radius() and current_tick % 2 == 0:
		apply_poison(1)

func _chernobyl_tick():
	if chernobyl_ticks <= 0:
		return
	chernobyl_ticks -= 1
	
func meltdown_pulse(deal_damage = true):
	var pos = radius_center()
	_spawn_particle_effect(MELTDOWN_FX, pos, Vector2(), color_else_slime("style_2"))

	emit_signal("poison_booster")
	if MOD_MELTDOWN_EFFECT:
		emit_signal("meltdown_alarm")
	if MOD_EXTRA_NOISE:
		play_sound("MeltdownAlarm")
	
	if opponent_in_radius() and deal_damage:
		opponent.take_damage(MELTDOWN_PULSE_DAMAGE, 0, "0.25", 0, "1.0")
		apply_poison(MELTDOWN_PULSE_DAMAGE)
		play_sound("MeltdownHit")
		play_sound("HitBass")
	
	_pulse_on_blank("Pulse on Damage Dealt")
	
func _center_aura():
	update_data()

	var pos_global = get_hurtbox_center()
	var pos_local:Vector2 = Vector2( hurtbox_pos_relative().x, hurtbox_pos_relative().y )
	
	if lassail_projectile() and lassail_connected():
		lassail_projectile().update_data()
		pos_global = lassail_projectile().get_hurtbox_center()
		pos_local = to_local( lassail_projectile().get_hurtbox_center_float() )
		
	radius_center_global_x = pos_global.x
	radius_center_global_y = pos_global.y
	aura_controller.position = pos_local
			
func radius_center()->Vector2:
#	var global = to_global( aura_controller.position )
	var global = Vector2( radius_center_global_x, radius_center_global_y )
	return global
	
func lassail_projectile()->BaseObj:
#	if lassail_proj:
#		return objs_map[lassail_proj]
#	return null
	return obj_from_name(lassail_proj)

func can_lassail()->bool:
	return (lassail_proj == null)
	
func lassail_connected()->bool:
	var lassail = lassail_projectile()
	if (lassail == null):
		return false
	return not lassail.is_detached()
	
func fire_trail():
	opponent.take_damage(SLIMEFIRE_DAMAGE)
	if current_tick % 2 == 0:
		apply_poison(1)

func can_counter_hitbox(hitbox):
	
	if ignored_self_hitbox:
		return true
			
	return .can_counter_hitbox(hitbox)

func counter_hitbox(hitbox):
	if ignored_self_hitbox:
		ignored_self_hitbox = false
		return
	.counter_hitbox(hitbox)

func hit_by(hitbox, force=false):
	if hitbox and hitbox.host:
		var slimeball = obj_from_name(hitbox.host)
		if (slimeball and slimeball.get("allow_projectile_to_damage_slimegirl") is bool) and (slimeball.get("allow_projectile_to_damage_slimegirl") == false) and slimeball.id == id:
			ignored_self_hitbox = true
			return true
	.hit_by(hitbox, force)
	
func _on_hit_something(obj, hitbox):
	var state = current_state()
	if (obj is Fighter):
		
		_pulse_on_blank("Pulse on Damage Dealt")
		
		var is_noxipaste_hit = noxipaste_this_turn and current_slimeclone_state_name == current_state().state_name and not hitbox.is_projectile()
		var can_apply_poison = ((stance == "Sloppy") and hitbox.is_projectile() or stance != "Sloppy")
		
		if (hitbox is SLIMEBOX):
			var applied_poison = calculate_poison_ticks(state, hitbox, is_noxipaste_hit)
			if hitbox.add_poison:
				if can_apply_poison:
					print("poison boosted: " if (on_slimetrail_this_state and state.get("increased_poison_on_trail")) else "poison: ", applied_poison)
					apply_poison(applied_poison)
					apply_damage_ticks(hitbox.damage)
					
		elif ("poison" in hitbox.misc_data):
			var applied_poison = calculate_poison_ticks(state, hitbox, is_noxipaste_hit)
			if can_apply_poison:
				print("poison boosted: " if (on_slimetrail_this_state and state.get("increased_poison_on_trail")) else "poison: ", applied_poison)
				apply_poison(applied_poison)
				apply_damage_ticks(hitbox.damage)
				
		if current_state().sprite_animation == "BurstToxic":
			apply_poison(TOXIC_BURST_POISON)
		
	._on_hit_something(obj, hitbox)
		
	if counterhit_this_turn:
		enable_beam_charge()
		if MOD_EXTRA_NOISE:
			spawn_particle_effect(preload("res://slimegirl/ramwould/FX/CounterHitFX.tscn"), obj.get_hurtbox_center_float())
		
func on_got_blocked_by(who):
	var state = current_state()
	var can_apply_poison = (stance != "Sloppy")
	
	if state.get("apply_poison_on_block"):
		if who is Fighter:
			var real_hitbox
			for hitbox_name in who.parried_hitboxes:
				var hitbox = who.hitbox_from_name(hitbox_name)
				if hitbox:
					if (hitbox is SLIMEBOX):
						if hitbox.add_poison and hitbox.enabled and hitbox.active:
							real_hitbox = hitbox
							break
					if ("poison" in hitbox.misc_data) and hitbox.enabled and hitbox.active:
						real_hitbox = hitbox
						break
				
			if real_hitbox:
				var applied_poison = floor( calculate_poison_ticks(state, real_hitbox)*float(state.get("poison_percent_on_block")) )
				if can_apply_poison:
					print(applied_poison, " : blocked")
					apply_poison(applied_poison)
				
			else:
				print("No Hitbox Detected", " : blocked")
	.on_got_blocked_by(who)

func on_got_parried():
	var remove = floor(poison_time * POISON_PERCENT_LOSS_ON_PARRY)
	apply_poison(-remove)
	print("parried! lost ", remove, " poison")
	
	noxipaste_queue_active = false
	noxipaste_queue_explode = false
	
	.on_got_parried()

func has_autoblock_armor():
	return autoblocking and not (current_state() is CharacterHurtState)

func on_got_hit_by_fighter():
	if ("Meltdown" in current_state().state_name) and has_armor():
		current_state().enable_hit_cancel()
		opponent.current_state().enable_hit_cancel()

func on_got_hit():
	if ("Meltdown" in current_state().state_name) and has_armor():
#		meltdown_ticks /= 2
#		print("reduced meltdown by half!")
		pass
		
	else:
#		meltdown_ticks = 0
		boost_ticks = 0
		
	copybuny_active = false
	reset_goop(true)
	clear_bounced_projectiles()
	if carrotmine_projectile():
		carrotmine_projectile().on_fire = false
		carrotmine_projectile().disable()
		
	noxipaste_queue_active = false
	noxipaste_queue_explode = false
	queued_for_detonation.clear()
	
	spooderman_tracker = 0
	poison_damage_ticks = 0
	queued_beam_shockwave = false
	
	_pulse_on_blank("Pulse on Damage Taken")
		
func on_blocked_something():
	if in_blockstring and current_state().name == "ParrySuper":
		block_pulse()

func block_pulse():
	var can_deal_damage =\
	opponent_in_radius() and not opponent.invulnerable and not (opponent.current_state() is ParryState)
	
	if not can_deal_damage:
		return
	
	if in_blockstring:
		var fx = preload("res://slimegirl/ramwould/FX/BlockStrPoisonFX.tscn")
		var pos = radius_center()
		_spawn_particle_effect(fx, pos, Vector2(), color_else_slime("style_1"))
			
	emit_signal("poison_booster")
	_pulse_on_blank("Pulse on Damage Dealt")
	
	apply_poison(BLOCK_PULSE_TICKS)
	play_sound("BlockStrPoison")
	play_sound("HitBass")

	
func calculate_poison_ticks(state, hitbox, noxipaste_hit=false)->int:
	var get_damage = hitbox.damage
	if state.started_during_combo and hitbox.damage_in_combo > 0:
		get_damage = hitbox.damage_in_combo
	if get_damage < hitbox.minimum_damage:
		get_damage = hitbox.minimum_damage
	
	var poison_percent:String = DEFAULT_PROJECTILE_POISON_PERCENT
	if not ("projectile_poison" in hitbox.misc_data):
		if state.get("poison_percent"):
			poison_percent = str( state.get("poison_percent") )
			
		if state.get("increased_poison_on_trail"):
			if on_slimetrail_this_state:
				poison_percent = fixed.mul( poison_percent, POISON_TIME_MULTIPLIER_ON_SLIMETRAIL )
				
		if queued_beam_shockwave:
			poison_percent = fixed.mul( poison_percent, POISON_TIME_MULTIPLIER_FOR_BEAM_CHARGE )
			
	else:
		var distance_from_proj = obj_distance( hitbox.host )
		if fixed.ge( distance_from_proj, MAX_PROJECTILE_POISON_MOD_DISTANCE ):
			distance_from_proj = MAX_PROJECTILE_POISON_MOD_DISTANCE
		
		var max_projectile_poison_mod_strength = fixed.add(MIN_PROJECTILE_POISON_MOD_STRENGTH, DEFAULT_PROJECTILE_POISON_PERCENT)
		var dist_to_poison = fixed.lerp_string("0.0", max_projectile_poison_mod_strength, fixed.div( distance_from_proj,MAX_PROJECTILE_POISON_MOD_DISTANCE ))
		poison_percent = fixed.add( poison_percent, dist_to_poison )
	
	if in_meltdown():
		poison_percent = fixed.mul( poison_percent, POISON_TIME_MULTIPLIER_IN_MELTDOWN )
	
	if counterhit_this_turn:
		print("counterhit! increased poison")
		poison_percent = fixed.mul( poison_percent, POISON_TIME_MULTIPLIER_ON_COUNTERHIT )

	if noxipaste_hit:
		print("copybuny! increased poison")
		if MOD_EXTRA_NOISE and not noxipaste_effect_this_turn:
			global_hitlag(4, false)
			play_sound("NoxipasteHit")
			noxipaste_effect_this_turn = true
		poison_percent = fixed.mul( poison_percent, POISON_TIME_MULTIPLIER_ON_COPYBUNY )
		
	var poison_combo_count = -2
	if burst_cancel_combo:
		poison_combo_count += combo_count_on_burst
	
	var total_poison_time_multiplier = fixed.mul( poison_percent, GLOBAL_POISON_TIME_MULTIPLIER_ON_HIT )
	var applied_poison:int = floor(opponent.combo_stale_damage(get_damage, poison_combo_count) * float(total_poison_time_multiplier))
	return applied_poison
	
func spawn_basic_beam(x:int, y:int, hitbox:SweptHitbox, from=self)->BaseProjectile:
	var new = hitbox.to_data()
	
	var obj:BaseProjectile = from.spawn_object(BEAM_SCENE, x, y)
	obj.beam_direction = hitbox.get("beam_direction")
	obj.stop_at_ground = hitbox.get("stop_at_ground")
	obj.show_base = hitbox.get("show_base")
	obj.hitbox_data = new
	obj.beam_size = hitbox.width
	obj.loop_active_ticks = hitbox.loop_active_ticks
	obj.loop_inactive_ticks = hitbox.loop_inactive_ticks
	obj.active_ticks = hitbox.active_ticks
	obj.startup_time = hitbox.startup_ticks
	obj.hit_particle = hitbox.hit_particle
	obj.create_trail = hitbox.get("create_trail")
	obj.can_shockwave = hitbox.get("can_shockwave")
	obj.melee = hitbox.get("melee_hitbox")
	
	var dir = hitbox.get("beam_direction").normalized()*2000
	
	obj.swept.start_tick = 1+hitbox.startup_ticks
	obj.swept.to_x = dir.x
	obj.swept.to_y = dir.y

	obj.swept.whiff_sound = hitbox.whiff_sound
	obj.swept.hit_sound = hitbox.hit_sound
	obj.swept.hit_bass_sound = hitbox.hit_bass_sound
	obj.swept.whiff_sound_volume = hitbox.whiff_sound_volume
	obj.swept.hit_sound_volume = hitbox.hit_sound_volume
	obj.swept.bass_sound_volume = hitbox.bass_sound_volume
	obj.swept.bass_on_whiff = hitbox.bass_on_whiff
	
	obj.init()
	obj.swept.call_deferred("setup_audio")	
				
	return obj

func spawn_shockwave(global_pos:Vector2, parry_window=true):
	play_sound("BeamShockwave")
	_spawn_particle_effect(preload("res://slimegirl/ramwould/FX/ShockwaveTrailFX.tscn"), global_pos, Vector2(), color_else_slime("outline"))
	for p_dir in [1, -1]:
		var wave:BaseProjectile = spawn_object(SHOKWAVE_SCENE, global_pos.x, 0, false, null, false)
		wave.set_facing(p_dir)
		wave.has_projectile_parry_window = parry_window
		if on_fire_this_state:
			append_fiery_projectile(wave)

func spawn_shockwave_one(global_pos:Vector2, p_facing:int, parry_window=true):
	play_sound("BeamShockwave")
	_spawn_particle_effect(preload("res://slimegirl/ramwould/FX/ShockwaveTrailFX.tscn"), global_pos, Vector2(), color_else_slime("outline"))
	var wave:BaseProjectile = spawn_object(SHOKWAVE_SCENE, global_pos.x, 0, false, null, false)
	wave.set_facing(p_facing)
	wave.has_projectile_parry_window = parry_window
	if on_fire_this_state:
		append_fiery_projectile(wave)

func stick_goop_to_obj(obj:BaseObj, force:bool):
	if obj == null:
		return
	if obj.disabled:
		return
	if not force and gooped_obj():
		return
	
	gooped_obj_name = obj.name
	var obj_center = obj.get_hurtbox_center_float()
	goop_global_x = obj_center.x
	goop_global_y = obj_center.y
	
	play_sound("GoopApplied")

func stick_goop_to_pos(x:int, y:int, force:bool):
	if goop_pos_no_edge(x, y):
		reset_goop( true )
		return
	if force:
		reset_goop( true )
	if gooped_obj_name:
		return
	
	goop_global_x = x
	goop_global_y = y
	
	play_sound("GoopApplied")

#	true goop position is not on the edges of the stage
func goop_pos_no_edge(x:int, y:int):
	return y < -5 and Utils.int_abs(x) < stage_width-5
	
func _goop_tick():
	var obj = gooped_obj()
	var goop_pos = Vector2(goop_global_x, goop_global_y)
	
	if goop_pos == Vector2.ZERO:
		reset_goop( true )
		return
		
	if (obj == null || obj.disabled):
		reset_goop( false )
	
	if obj:
		var obj_center = obj.get_hurtbox_center_float()
		goop_global_x = obj_center.x
		goop_global_y = obj_center.y
		
	var center = get_hurtbox_center_float()
	var pull_dir = {
		"x":goop_global_x-center.x,
		"y":goop_global_y-center.y,
		}
	var veclen = fixed.vec_len(str(pull_dir.x), str(pull_dir.y))
	if fixed.gt( veclen, MAX_SELF_GOOP_DISTANCE ) and goop_pos != Vector2.ZERO:
		reset_goop( true )
		return
	var pull_force_with_distance = fixed.mul( fixed.div(veclen,MAX_SELF_GOOP_DISTANCE), MAX_SELF_GOOP_PULL_FORCE)
	var force = fixed.normalized_vec_times(str(pull_dir.x), str(pull_dir.y), pull_force_with_distance)
	update_grounded()
	if is_grounded():
		force.y = "0"
	apply_force(force.x, force.y)
	update_data()
	
func gooped_obj()->BaseObj:
	return obj_from_name(gooped_obj_name)
	
func is_gooped_opponent()->bool:
	return gooped_obj_name and gooped_obj() == opponent

func is_gooped()->bool:
	var goop_pos = Vector2(goop_global_x, goop_global_y)
	return (goop_pos != Vector2.ZERO) or gooped_obj()
	
func reset_goop(full:bool):
	if full or goop_pos_no_edge(goop_global_x, goop_global_y):
		goop_global_x = 0
		goop_global_y = 0
	gooped_obj_name = null
		
func start_venocache():
	var size_time = RADIUS_SIZE_TIME_VENOCACHE+poison_time
	temporary_size_ticks = size_time
	
	var poison_intake = poison_time
	if poison_intake > MAX_VENOCACHE_POISON_INTAKE:
		poison_intake = MAX_VENOCACHE_POISON_INTAKE
	apply_poison(-poison_intake)
	
	meltdown_pulse( false )
	if lassail_projectile() and lassail_connected():
		lassail_projectile()._slimegirl_used_venocache()
		lassail_projectile().hitlag_ticks += 16
		
func start_venocache_wind():
	$"%VenocacheWind".start_emitting()
	play_sound("VenocacheWind")
	
func stop_venocache_wind():
	$"%VenocacheWind".stop_emitting()
	
func reset_combo():
	.reset_combo()
	combo_count_on_burst = 0
	slap_uses = MAX_SLAP_USES 
	
func use_burst():
	if current_state().sprite_animation == "BurstToxic":
		start_burst_size_mod()
		
	.use_burst()
	combo_count_on_burst = combo_count
	
func start_burst_size_mod():
	burst_size_ticks = RADIUS_SIZE_TIME_BURST
	
func process_extra(extra:Dictionary):
	if "create_clone" in extra:
		copybuny_active = extra.create_clone
		if copybuny_active:
			play_sound("ButtonPress1")
			copybuny_this_turn = true
			copybuny_xy = extra.create_clone_xy
				
	.process_extra(extra)

	if "teleporting" in extra:
		noxipaste_active = extra.teleporting
			
	if "detonate_all_clones" in extra:
		noxipaste_explode = extra.detonate_all_clones
	
	if not noxipaste_queue_active:
		copybuny_index = -1
	if noxipaste_active:
		play_sound("ButtonPress1")
		noxipaste_queue_active = true
		noxipaste_flip_state = extra.flip_teleport
		copybuny_index = extra.get_clone_index
		noxipaste_tick = NOXIPASTE_TELEPORT_TICK+game_tick
		
	elif noxipaste_explode:
		play_sound("ButtonPress2")
		noxipaste_queue_explode = true
		queued_for_detonation = get_clones_in_radius()
		noxipaste_tick = NOXIPASTE_EXPLODE_TICK+game_tick

	if "detach" in extra:
		if extra["detach"]:
			if gooped_obj() and gooped_obj().get("IS_SLIMECLONE"):
				var index = 0
				for clone in slimeclone_data:
					if gooped_obj().obj_name == clone["clone_name"]:
						break
					index+=1
				try_explode_clone([index], false, CLONE_DETACH_EXPLODE_DELAY-3)
				
			reset_goop(true)
	
	if "yank" in extra:
		if extra["yank"]:
			yank_slimegirl( extra["input_aerial"] )
		
	if "slime_friction" in extra:
		increased_friction = extra["slime_friction"]
	
	if "aura_multiplier" in extra:
		aura_multiplier_while_inf = extra["aura_multiplier"].x
		
	if "current_time" in extra:
		ACH_DATA_TIME = extra["current_time"]
		
func consume_feint():
	if copybuny_this_turn:
		return
	.consume_feint()

func _slimeclones_tick():
	if slimeclone_data.empty():
		return
	for i in slimeclone_data.size():
		var obj = obj_from_name(slimeclone_data[i]["clone_name"])
		if obj is BaseProjectile:
			var dist = obj_distance(obj)
			var inactive = fixed.gt(dist, MAX_COPYBUNY_DESPAWN_DISTANCE)
			
			obj.clone_disabled = inactive
			slimeclone_data[i]["clone_inactive"] = inactive
		
func get_slimeclone(index:int, dic_ref:Array)->BaseProjectile:
	if dic_ref.empty():
		return null
		
	if index > dic_ref.size()-1:
		index = dic_ref.size()-1
		copybuny_index = index
		
	if index == -1:
		if dic_ref.front():
			return obj_from_name(dic_ref.front().clone_name)
		return null
	
	return obj_from_name(dic_ref[index].clone_name)

func can_get_freebie_clone()->bool:
	return false
#	return slimeclone_data.size() <= 0
	
func try_create_clone():
	if copybuny_this_turn:
		copybuny_this_turn = false
		if supers_available < COPYBUNY_SUPER_COST and not can_get_freebie_clone():
			return
		
		ex_effect(5)
		if not can_get_freebie_clone():
			for i in COPYBUNY_SUPER_COST:
				use_super_bar()
			combo_supers += 1
		play_sound("Copybuny")
		
		var clone_spawn_pos:Dictionary = get_copybuny_spawn_pos()
		if clone_spawn_pos.has("invalid"):
			if is_ghost:
				$"%CopybunyReasonLabel".visible = true
				$"%CopybunyReasonLabel".text = "[[FAIL REASON]]\n"+clone_spawn_pos["reason"]
				$"%CopybunyReasonLabel".rect_position = $"%CopybunyReasonLabel".rect_size / -2
			return
		
		if current_state().can_feint_if_possible:
			feinting = true
			
		var clone_spawn_vector = Vector2( float(clone_spawn_pos.x), float(clone_spawn_pos.y))
		var clone_spawn_local = to_local( clone_spawn_vector )
		if not (copybuny_xy.x == 0 and copybuny_xy.y == 0):
			var IMAGE_COUNT:float = 9
			for i in IMAGE_COUNT:
				var aftertrail_pos = lerp(Vector2.ZERO, clone_spawn_local, i / IMAGE_COUNT)
				var lerp_color:Color = lerp(slime_color, outline_color, i / IMAGE_COUNT)
				lerp_color.a = 0.7
				create_speed_after_image(lerp_color, Utils.frames(8), aftertrail_pos)
		
		var clone:BaseProjectile = spawn_object(SLIMECLONE_SCENE, clone_spawn_vector.x, clone_spawn_vector.y, false, null, false)
		setup_clone(clone)
		_spawn_particle_effect(MELT_FX,clone.get_hurtbox_center_float(),Vector2(),color_else_slime("outline"))

		if slimeclone_data.size() > MAX_COPYBUNY_CLONES:
			var remove_clone = get_slimeclone(0, slimeclone_data)
			remove_clone.disable()

func get_copybuny_spawn_pos()->Dictionary:
	var _pos = xy_to_dir(copybuny_xy.x, copybuny_xy.y, current_radiation_radius)
	
	var _vector:Vector2 = Vector2( float(_pos.x), float(_pos.y))
	var _global:Vector2 = _vector + radius_center()
	
	if lassail_projectile():
		_global -= lassail_projectile().hurtbox_pos_relative_float()
		
	else:
		_global -= self.hurtbox_pos_relative_float()

	var _radius = float(current_radiation_radius)
	
	var _global_output:Vector2 = _global
			
	var intersecting = Geometry.line_intersects_line_2d(_global, _vector, Vector2(stage_width, 0), Vector2.LEFT)
	if is_grounded():
		_global_output.y = 0
		
	if (_global_output.y > 0):
		_global_output.y = 0
	
	if (_global_output.y < -ceiling_height) and has_ceiling:
		_global_output.y = -ceiling_height
		
	if (_global_output.x > stage_width):
		_global_output.x = stage_width
		
	if (_global_output.x < -stage_width):
		_global_output.x = -stage_width
	
	if lassail_projectile() and is_grounded() and not Geometry.is_point_in_circle(_global_output, radius_center(), _radius):
		var _ground_A = Vector2(stage_width * sign(_vector.x), 0)
		var _ground_B = Vector2(-stage_width * sign(_vector.x), 0)
		var _segment = Geometry.segment_intersects_circle(_ground_A, _ground_B, radius_center(), _radius)
		if _segment == -1:
			return {"invalid":true, "reason":"Can't Ground Clone!"}
		
		_global_output = lerp(_ground_A, _ground_B, _segment)
	
	if _global_output.distance_to( get_hurtbox_center_float() ) > float(MAX_COPYBUNY_DESPAWN_DISTANCE):
		return {"invalid":true, "reason":"Too Far!"}
		
	return {"x":_global_output.x, "y":_global_output.y}
	
func setup_clone(clone:BaseProjectile):
	update_data()
	
	var is_grounded_clone = is_grounded() or get_pos().y >= 0
	clone.init(null)
	clone.set_grounded( is_grounded_clone )
	clone.set_facing( get_facing_int() )
	clone.aerial_clone = not is_grounded_clone
	
	var spriteframes:AnimatedSprite = sprite.duplicate()
	clone.sprite.frames = spriteframes.frames
	clone.sprite.animation = sprite.animation
	clone.sprite.frame = sprite.frame
	clone.modulate = Color(1, 1, 1, 0.9)
	clone.update_data()
	
	slimeclone_data.append({
		"clone_name":clone.name,
		"state_name":current_state().state_name,
		"state_visual":current_state().title,
		"state_tick":current_state().current_tick,
		"state_data":current_state().data,
		"current_vel":get_vel(),
		"current_stance":stance,
		"clone_inactive":false,
		})
	
func try_teleport_clone():
	var clone:BaseProjectile = get_slimeclone(copybuny_index, slimeclone_data)
	if clone:
		noxipaste_queue_active = false
		play_sound("Noxipaste")
		add_penalty(10)
		_spawn_particle_effect(MELT_FX, clone.get_hurtbox_center_float(),Vector2(),color_else_slime("outline"))
		_spawn_particle_effect(MELT_FX,get_hurtbox_center_float(),Vector2(),color_else_slime())
		
		clone.update_data()
		var clone_pos = clone.get_pos()
		var clone_cur_vel = clone.get_vel()
		var clone_grounded = clone.is_grounded()
		var state_data
		if slimeclone_data[copybuny_index].state_data is Dictionary:
			state_data = slimeclone_data[copybuny_index].state_data.duplicate(true)
		else: state_data = slimeclone_data[copybuny_index].state_data
		var state_name = slimeclone_data[copybuny_index].state_name
		var state_tick = slimeclone_data[copybuny_index].state_tick
		var clone_vel = slimeclone_data[copybuny_index].current_vel.duplicate(true)
		var clone_stance = slimeclone_data[copybuny_index].current_stance
		var clone_aerial_state = clone.aerial_clone
		clone.disable()
		
		var clone_visual = to_local(Vector2(clone_pos.x,clone_pos.y)).rotated(PI)
		var IMAGE_COUNT:float = 9
		for i in IMAGE_COUNT:
			var aftertrail_pos = lerp(Vector2.ZERO, clone_visual, i / IMAGE_COUNT)
			var lerp_color:Color = lerp(slime_color, outline_color, i / IMAGE_COUNT)
			lerp_color.a = 0.7
			create_speed_after_image(lerp_color, Utils.frames(13), aftertrail_pos)
		
		if clone_grounded and not clone_aerial_state:
			clone_pos.y = 0
		set_pos(clone_pos.x, clone_pos.y)
		if clone_stance != stance:
			change_stance_to(clone_stance)
		if noxipaste_flip_state:
			state_data = flip_clone_data_x(state_data)
		change_state(state_name, state_data, true, true)
		current_state().current_tick = state_tick
		set_grounded( clone_grounded and not clone_aerial_state )
		var added_vec = fixed.vec_add(clone_cur_vel.x, clone_cur_vel.y, clone_vel.x, clone_vel.y)
		if noxipaste_flip_state:
			added_vec.x = fixed.mul(added_vec.x,"-1")
		set_vel(added_vec.x, added_vec.y)
		update_facing()
		if noxipaste_flip_state:
			turn_around()
			reverse_state = true
		current_slimeclone_state_name = state_name
		update_data()
		
		noxipaste_this_turn = true
		feinting = true

func flip_clone_data_x(state_data):
	var _dict :Dictionary
	
	if state_data is Dictionary and state_data.get("y") is int:
		
		_dict = state_data.duplicate(true)
		if _dict.x is int:
			_dict.x *= -1

		elif _dict.x is String:
			_dict.x = fixed.mul(_dict.x,"-1")
		
		return _dict
		
	else:
		return state_data
	
func try_explode_clone(indexes=[], hit_cancel=true, lag=0):
	
	if indexes.empty():
		indexes = [copybuny_index]
	
	var clone_array = []
	for i in indexes:
		var clone:BaseProjectile = get_slimeclone(i, slimeclone_data)
		if clone:
			clone_array.append(clone)
	
	noxipaste_explode_this_turn = true
	noxipaste_queue_explode = false
	play_sound("Noxipaste")
	
	for obj in clone_array:		
		_spawn_particle_effect(MELT_FX, obj.get_hurtbox_center_float(),Vector2(),color_else_slime("outline"))
		obj.safely_disable = false
		obj.allow_host_hit_cancelling = hit_cancel
		obj.primed = lag+1
		obj.disable()

func try_detonate_mine():
	if has_carrotmine():
		carrotmine_projectile().disable()
		play_sound("ButtonPress1")
		
func get_clones_in_radius()->Array:
	var list = []
	for obj in objs_map.values():
		if obj and (obj is BaseObj):
			if obj.get("IS_SLIMECLONE") == null:
				continue
			if obj.disabled:
				continue
			var index = 0
			for data in slimeclone_data:
				if obj_in_radius(obj) and obj.name == data["clone_name"]:
					list.append(index)
				index+=1
	return list
	
func create_speed_after_image(color:Color = Color.white, lifetime = 0.2, offset = Vector2.ZERO):
	if is_ghost or ReplayManager.resimulating:
		return 
	call_deferred("_create_clone_line", color, lifetime, offset)

func _create_clone_line(color:Color = Color.white, lifetime = 0.2, offset = Vector2.ZERO):
	var speed_image_effect = preload("res://fx/SpeedImageEffect.tscn")
	var texture = sprite.frames.get_frame(sprite.animation, sprite.frame)
	var effect = _spawn_particle_effect(speed_image_effect, get_pos_visual() + sprite.offset + offset)
	effect.set_texture(texture)
	effect.lifetime = lifetime
	effect.set_color(color)
	effect.sprite.flip_h = get_facing_int() == - 1

func color_else_slime(color_type = "slime")->Color:
	var uses_outline = sprite.get_material().get_shader_param("use_outline")

		
	match color_type:
		"outline":
			return outline_color if (uses_outline and applied_style) else slime_color
			
		"style_1","assimilation":
			if not Global.enable_custom_colors or not is_color_active:
				return extra_color_1
				
			var style_color :Color= style_extra_color_1 if (style_extra_color_1 and applied_style) else extra_color_1
			if ACH_MOD_S1_ALT_OVERRIDE:
				ACH_MOD_S1_ALT_COLOR = extra_color_1
			return _style_slime(ACH_MOD_S1_ALT_SPEED, style_color, ACH_MOD_S1_ALT_COLOR)

		"style_2","meltdown":
			if not Global.enable_custom_colors or not is_color_active:
				return extra_color_2
				
			var style_color :Color= style_extra_color_2 if (style_extra_color_2 and applied_style) else extra_color_2
			if ACH_MOD_S2_ALT_OVERRIDE:
				ACH_MOD_S2_ALT_COLOR = extra_color_2
			return _style_slime(ACH_MOD_S2_ALT_SPEED, style_color, ACH_MOD_S2_ALT_COLOR)
		
		_:
			return slime_color
			
func _style_slime(var type:String, var color1:Color, var color2:Color)->Color:	
	if is_ghost: return color1
	
	var fastest_speed = 180
	
	var reverse_s = color2.is_equal_approx(ACH_MOD_SLIME_ALT_COLOR) and ACH_MOD_SLIME_ALT_REVERSED
	var reverse_1 = color2.is_equal_approx(ACH_MOD_S1_ALT_COLOR) and ACH_MOD_S1_ALT_REVERSED
	var reverse_2 = color2.is_equal_approx(ACH_MOD_S2_ALT_COLOR) and ACH_MOD_S2_ALT_REVERSED
	
	if reverse_s or reverse_1 or reverse_2:
		var temp = color1
		color1 = color2
		color2 = temp
		
	var color_lerp :Color= color1
		
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
			
		"Pulse on Damage Dealt","Pulse on Damage Taken","Pulse on Super Use":
			var d = color_tween_ticks / float(MAX_COLOR_TWEEN)
			color_lerp = color1.linear_interpolate(color2, d)
			
		"Fade to HP":
			var d = hp / float(MAX_HEALTH)
			color_lerp = color2.linear_interpolate(color1, d)
		"Fade to Opponent HP":
			var d = opponent.hp / float(opponent.MAX_HEALTH)
			color_lerp = color2.linear_interpolate(color1, d)
		"Fade to Poison":
			var d = clamp(poison_time / float(MAX_VENOCACHE_POISON_INTAKE), 0.0, 1.0)
			color_lerp = color1.linear_interpolate(color2, d)
		"Fade to Burst":
			var d = burst_meter / float(MAX_BURST_METER)
			if bursts_available >= 1:
				d = 1.0
			color_lerp = color2.linear_interpolate(color1, d)
		"Fade to Max Meter":
			var d = get_total_super_meter() / float(MAX_SUPER_METER*MAX_SUPERS)
			color_lerp = color1.linear_interpolate(color2, d)
		"Fade to Match Time":
			var game :Game= Global.current_game
			var d = game.get_ticks_left() / float(game.time+1)
			color_lerp = color2.linear_interpolate(color1, d)
		"Fade to AM/PM":
			var d = ACH_DATA_TIME / float(ACH_DATA_TIME_MAX)
			if d < 0.5:
				d *= 2
				color_lerp = color1.linear_interpolate(color2, d)
			else:
				d -= 0.5
				d *= 2
				color_lerp = color2.linear_interpolate(color1, d)
		_: pass
	return color_lerp
	
func _spawn_particle_effect(particle_effect:PackedScene, pos:Vector2, dir = Vector2.RIGHT, color = Color.white):
	
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

func spawn_particle_effect(particle_effect: PackedScene, pos: Vector2, dir = Vector2.RIGHT, color_type="None"):
	if ReplayManager.resimulating:
		return
	if not initialized:
		yield(self, "initialized")
	
	var get_color = Color.white
	match color_type:
		_:
			if color_type.is_valid_html_color():
				get_color = Color(color_type)
		"slime", "style_1", "style_2", "outline":
			get_color = color_else_slime(color_type)
			
	call_deferred("_spawn_particle_effect", particle_effect, pos, dir, color)

func spawn_particle_effect_relative(particle_effect: PackedScene, pos: Vector2 = Vector2(), dir = Vector2.RIGHT, color_type="None"):
	if ReplayManager.resimulating:
		return
	if not initialized:
		yield(self, "initialized")
	var p = get_pos_visual()
	pos.x *= get_facing_int()
	
	var get_color = Color.white
	match color_type:
		_:
			if color_type.is_valid_html_color():
				get_color = Color(color_type)
		"slime", "style_1", "style_2", "outline":
			get_color = color_else_slime(color_type)

	call_deferred("_spawn_particle_effect", particle_effect, pos + p, dir, get_color)
	
func enable_beam_charge():
	if queued_beam_shockwave:
		return
	queued_beam_shockwave = true
	global_hitlag(3, false)
	play_sound("BeamShockwaveCharge")
	beam_charge_queued_effect()

func use_beam_charge():
	queued_beam_shockwave = false
	global_hitlag(3, false)
	
func beam_charge_queued_effect():
	var speed_image_effect = EXPANDING_FX
	var texture = sprite.frames.get_frame(sprite.animation, sprite.frame)
	var effect = _spawn_particle_effect(speed_image_effect, get_pos_visual() + sprite.offset)
	effect.set_texture(texture)
	effect.lifetime = Utils.frames(12)
	effect.max_size = 1.6
	var new_color = color_else_slime("style_2").lightened(0.40)
	effect.set_color(new_color)
	effect.sprite.flip_h = get_facing_int() == - 1
	
func achiev_counter(counter_name:String, amount:float = 1, multiplayer_only=true):
	if codex_lib:
		if can_unlock_achievements() and (is_you(not multiplayer_only) or debugging):
			codex_lib.increment_counter(self, counter_name, amount)
		
func unlock_achiev(achievement_name:String, multiplayer_only=true):
	if codex_lib:
		if can_unlock_achievements() and (is_you(not multiplayer_only) or debugging):
			if codex_lib.achievement_target_met(self, achievement_name):
				codex_lib.unlock_achievement(self, achievement_name)

func beat_hustler():
	var opponent_name = getCharacterName(opponent.id)
	match opponent_name:
		"Pixie":
			if opponent.hp <= 0:
				unlock_achiev("achivement_beat_pixie")
		"Bunbun":
			if opponent.hp <= 0:
				unlock_achiev("achivement_beat_bunbun")
		"Slimegirl":
			if opponent.hp <= 0:
				unlock_achiev("achivement_beat_self")
		"Slimpurt":
			unlock_achiev("achivement_play_slimpurt")
		"Juvenile":
			if opponent.hp <= 0:
				unlock_achiev("achivement_beat_juvenile")
		"Cirno":
			if opponent.hp <= 0:
				unlock_achiev("achivement_beat_cirno")
		"Lopunny":
			if opponent.hp <= 0:
				unlock_achiev("achivement_beat_lopunny")
		"COG":
			pass
		
		"AAIR":
			pass
			
func getCharacterName(var id = 1)->String: #Returns a string with the character name.
	var _name:String = find_parent("Main").match_data.selected_characters[id]["name"] #Grabs the character's name.
	#Modified from Bard's code to be multihustle friendly.
	#And modified again from PPT to accomodate for my stage code lmao. - Fleig
	#Is the same as it appears in the character select menu.

	#When mods are exported to be built in the main game, their file name changes, so the below code trims it appropriately.
	var filter = _name.rfind("__") 

	if filter != -1:
		filter += 2
		_name = _name.right(filter)
	return _name

func super_effect(freeze=0):
	.super_effect(freeze)
	_pulse_on_blank("Pulse on Super Use")
	
func clear_bounced_projectiles():
	bounced_projectiles.clear()
	
func append_bounced_projectile(proj:BaseObj):
	if proj and (not proj.disabled):
		bounced_projectiles.append(proj.name)
	
func has_bounced_projectile(proj:BaseObj)->bool:
	var proj_exists = false
	for p_check_name in bounced_projectiles:
		var p_check = obj_from_name(p_check_name)
		if p_check == null:
			bounced_projectiles.erase(proj.name)
			continue
		if p_check.disabled:
			bounced_projectiles.erase(proj.name)
			continue
			
		if p_check_name == proj.name:
			proj_exists = true
			break

	if proj_exists:
		return true
	
	return false

func append_fiery_projectile(proj)->bool:
	if proj is BaseProjectile:
		if proj.disabled:
			return false
		if not proj.get("on_fire") is bool:
			return false
		if proj.get("on_fire") == true:
			return false
		proj.on_fire = true
		
	return true
	
func debug_text():
	.debug_text()
	debug_info(
		{
			"current_psn_dmg":calculate_poison_damage(),
			"current_boost_pwr":calculate_boost_damage(),
		}
	)	
	pass
	
func tween_camera_zoom(initial_value:float, end_value:float, duration:float, transition_type, ease_type):
	if is_ghost or ReplayManager.resimulating:
		return 
	var game = Global.current_game
	
#	emit_signal("zoom_changed")
	if tween:
		tween.kill()
		set_camera_zoom(initial_value)
		
	tween = game.create_tween()
	
	tween.set_parallel(true)
	tween.set_trans(transition_type)
	tween.set_ease(ease_type)
	
	tween.tween_property(game, "camera_zoom", initial_value, 0.0025)
	
	tween.set_ease(ease_type)
	tween.tween_property(game, "camera_zoom", end_value, duration)
	
	game.camera.limit_left = -10000000
	game.camera.limit_right = 10000000
	
	yield (tween, "finished")
	if not is_instance_valid(self):
		return 
	tween.kill()
	game.update_camera_limits()
	
func set_camera_zoom(value:float):
	if is_ghost or ReplayManager.resimulating:
		return 
	if tween:
		tween.kill()
	var game = Global.current_game
	game.camera_zoom = value
#	emit_signal("zoom_changed")
	game.update_camera_limits()
	
func has_carrotmine():
	return !(carrotmine == null)

func carrotmine_projectile()->BaseObj:
	if carrotmine:
		return objs_map[carrotmine]
	return null

func has_sloppy_power():
	return stance == "Sloppy" and (is_poisoned() or infinite_resources)
	
func get_sloppy_power() -> String:
	if not has_sloppy_power():
		return "0"
		
	var power = fixed.div(str(poison_on_slop_stance_enter), str(MAX_VENOCACHE_POISON_INTAKE))
	if fixed.gt(power, "1"):
		power = "1"
	if fixed.lt(power, "0"):
		power = "0"
		
	return power
	
func _pulse_on_blank(type:String):
	if type in [ACH_MOD_SLIME_ALT_SPEED, ACH_MOD_S1_ALT_SPEED, ACH_MOD_S2_ALT_SPEED]:
		color_tween_ticks = MAX_COLOR_TWEEN

func is_in_install_super():
	return in_meltdown()

func get_current_limb_sprite_node():
	if current_state().name == "Sharpeardo":
		return sharpeardo
	if current_state().name in ["Melt_IntroAerial", "Melt_OutroAerial"]:
		return airmelt
	return .get_current_limb_sprite_node()
	

	
	
	
	
	
	
