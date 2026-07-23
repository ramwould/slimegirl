extends Node

const COLOR_NOTE = "#8c8c8c"
const COLOR_IMPORTANT = "#ffa00d"
const COLOR_POISON = "#78df2b"
const COLOR_MELTDOWN = "#ff0000"
const COLOR_BEAM = "#5c874e"
const COLOR_MOVE = "#fff6a9"
const COLOR_FREE_ACTION = "#e0a9ff"

const AURA_MODIFIERS = [
		"extra_shape1",
		"num_points",
		"slime_alt_color",
		"slime_alt_reversed",
		"slime_alt_speed",
		"slime_alt_override",
		"s1_alt_color",
		"s1_alt_reversed",
		"s1_alt_speed",
		"s1_alt_override",
		"s2_alt_color",
		"s2_alt_reversed",
		"s2_alt_speed",
		"s2_alt_override",
		"particle_overrides",
		"particle_tint",
	]

#		[color=#78df2b]slimetrail[/color]
#		[color=#ff0000][Meltdown][/color]
#		[color=#5c874e]beam Charge[/color]
#		[color=#78df2b]goops[/color]

func register(codex):

	codex.set_subtitle("Some would call her a champ")
	codex.set_summary("""Some goofy ahh slime girl just crawled out of the toxic waste bin. And then they F...OUGHT!

Slimegirl does [u]very little contact damage[/u], however each hit comes with a good dose of [color=#78df2b]DoT POISON[/color]!
She was created as a tool for mass extinction by a lone witch in a forest, the goal being to get rid of every magical entity living in the Enchanted Forest, where various pixies and fantasy creatures reside simply because they were being too noisy.

Slimegirl herself is quite friendly, however her toxic poison keeps most people away from her and naturally kills magic. Due to this, her only real friend is her creator.

Her favorite type of snack is magic, although she could technically eat anything. The color of her slime is determined by what she ate the most of recently, and can also be affected by the environment around her if she's there for long enough.

[center][color=#78df2b]Poison
||============================================||[/color][/center]

Her poison acts as her main way of dealing damage, almost every hit will add poison to the opponent. This poison will not kill the opponent on its own, so keep that in mind.
This is special poison, as it reduces the healing effects of opponents by 33%!

[color=#8c8c8c]The amount of poison added per hit is calculated based on damage, specifically:
	[damage] * [PSN on hit] * [PSN on block] (if blocking)[/color]
	
The current state of the match will affect how her poison acts as well:
	) Sadness, an opponent combo, or if the opponent is currently blocking will make her poison tick slower
	) Opponents in her aura or being in [color=#ff0000][Meltdown][/color] can increase its speed
	) Opponents standing on her Slimetrails will increase her poison's damage

Poison potency is her main way of determining how much damage her poison will do per tick.
Actions like keeping the opponent in your radius, having them stand in her slimy trails, or even just being in [color=#ff0000][Meltdown][/color] can all increase the potency of her poison.

[color=#ffa00d]The opponent can [u]burst[/u] or [u]parry[/u] Slimegirl's attacks to get rid of some of her poison![/color]

[center][color=#78df2b]Aura
||============================================||[/color][/center]

Slimegirl constantly radiates a powerful aura, which can affect many different attacks.

Depending on the situation, it can be larger or smaller:
	) During sadness, it becomes half its size
	) Standing on any Slimetrail or keeping the opponent in her aura can increase it
	) Higher poison potency
	) Move effects (such as [img]res://slimegirl/ramwould/sprites/icons/venocache_i.png[/img][color=#fff6a9][Venocache][/color]) may also alter its size

[center][color=#78df2b]Goop
||============================================||[/color][/center]

Slimegirl can use her goop to help her move where she wants. She can goop nearly anything, pulling herself towards whatever she gooped! Moving far enough can break the goop.

While attached, Slimegirl gains the option to yank herself towards the gooped area allowing her to redirect her velocity or perform aerials from the ground.

[center][color=#78df2b]Beam Charge
||============================================||[/color][/center]

[color=#5c874e]Beam Charge[/color] can allow Slimegirl’s various rays of doom to become even more powerful, applying more poison on hit and creating quick moving Shokwaves (spelled correctly) that glide along the ground!
""")

	var slimegirl = codex.character_parsed
	var state_list = slimegirl.get_node("StateMachine")
	for state in state_list.get_children():
		if state is CharacterState:
			codex.define_state(state.name, state)
			var has_poison_enabled = false
			for node in state.get_children():
				if node is Hitbox:
					if node is slimegirl.SLIMEBOX:
						if node.add_poison:
							has_poison_enabled = true
					if ("poison" in node.misc_data):
						has_poison_enabled = true
					if node.hitbox_type == Hitbox.HitboxType.Detect:
						codex.moveset[state.name].hitbox_data.erase(node.name)
				if node is HostCommand:
					if node.command == "try_create_clone":
						codex.moveset[state.name].set_gimmick_tick(node.tick, "Copybuny Frame")
						
			if state.get("poison_percent") is float and has_poison_enabled:
				var poison :String= str( state.get("poison_percent") )
				poison.pad_decimals(2)
				codex.moveset[state.name].custom_stats["PSN on hit"] = poison+"x"
			
				if state.get("apply_poison_on_block"):
					var poison_on_block :String= state.get("poison_percent_on_block")
					poison_on_block.pad_decimals(2)
					codex.moveset[state.name].custom_stats["PSN on block"] = poison_on_block+"x"
			if state.get("only_extreme_turbo"):
				codex.moveset[state.name].visible = false
				
	codex.moveset["Snagtrik"].desc = """Grabs the opponent or projectile using an aimable claw.
Max distance is controlled by aura size.

This attack [color=#78df2b]goops[/color] opponents and will enable [color=#5c874e]beam charge[/color].

Grabbing onto a projectile will launch her in the direction of the projectile, keep it in place, and transition Slimegirl into [img]res://slimegirl/ramwould/sprites/icons/slopdrop_i.png[/img][color=#fff6a9][Slop Drop][/color]

[color=#ffa00d]Doing this will consume an air option[/color], but will not start this move's cooldown."""
	codex.moveset["Snagtrik"].custom_stats["Cooldown"] = slimegirl.MAX_SNAGTRIK_TICKS
	
	codex.moveset["DIWhy"].desc = """If the move successfully connects, Slimegirl will do a drop kick while the opponent DI’s upwards, or a low sweep ([Clap Trap] if aerial) while downwards.
By default, she will choose to dropkick them."""
	codex.moveset["DIWhy_DropKick"].visible = true
	codex.moveset["DIWhy_DropKick"].desc = """[color=gray]Doesn't add projectile invulnerability. I would remove this, but codex is bugging out rn."""
	codex.moveset["DIWhy_LowSweep"].visible = true
	codex.moveset["DIWhy_Claptrap"].visible = true
	
	codex.moveset["SnapCracklePop"].desc = """Create a projectile that behaves somewhat like [img]res://characters/wizard/sprites/actionbuttons/flame_wave.png[/img][color=#fff6a9][Flame Wave][/color]!
It's speed is affected by aura size."""
	codex.moveset["SnapCracklePop"].custom_stats["Cooldown"] = slimegirl.MAX_SNAPCRACKLPOP_TICKS
	
	codex.moveset["Taunt"].visible = true
	codex.moveset["Taunt"].desc = """Can detonate carrot-mines."""
	
	codex.moveset["KickGrounded_F"].title = "Extendo-Kick (Forward)"
	codex.moveset["KickGrounded_FU"].title = "Extendo-Kick (High)"
	codex.moveset["KickGrounded_FU"].visible = true
	codex.moveset["KickAerial"].title = "Extendo-Kick (Aerial)"
	
	codex.moveset["HighSmackGrounded"].title = "H. Smack (Grounded)"
	codex.moveset["HighSmackAerial"].title = "H. Smack (Aerial)"
	
	codex.moveset["Syringe"].desc = """Shoot out a super sharp spike somewhere within her aura.

Knockback always launches away from aura center."""
	codex.moveset["SyringeLassail"].visible = false
	
	codex.moveset["Assimilate"].desc = """Assimilates [color=#8c8c8c](or attempt to assimilate)[/color] a projectile into Slimegirl for more power!
Assimilation adds super meter, boosted poison damage, and projectile immunity for the rest of the move on success.
Projectiles not absorbed are considered “botched”. They will not offer super and will power up Slimegirl's poison way less.

Additionally, if the opponent is in her aura, she gains an early interrupt.
A fully successful assimilation will enable [color=#5c874e]beam charge[/color].

[color=#8c8c8c]Note: A good way to determine when a projectile can be successfully assimilated is if it's a "simple projectile" that cannot be manually controlled in any way once it's been thrown out. It's not guaranteed, but it should apply to most projectiles in the game.[/color]"""
	codex.moveset["Assimilate"].set_gimmick_tick(4, "Assimilation")
	codex.moveset["Assimilate"].set_start_projectile_invuln_tick(4)
	
	codex.moveset["Assimilate"].set_gimmick_tick(8, "Interrupt (Combo)")
	codex.moveset["Assimilate"].set_interrupt_tick(8)
	codex.moveset["Assimilate"].set_gimmick_tick(11, "Interrupt (Neutral)")
	codex.moveset["Assimilate"].set_interrupt_tick(11)
	
	codex.moveset["Meltdown"].desc = """[color=#fff6a9][Meltdown][/color] is a powerful state that significantly weaponizes her poison even more.

[color=#8c8c8c]On use, Slimegirl gains hyper armor if the opponent is in her aura while she has initiative. If she's been hit by the opponent, both Slimegirl and the opponent will gain an interrupt.[/color]

While the opponent is standing in her aura, her poison timer will increase every frame. Additionally, anytime the siren blares and the opponent is in her aura, they take damage, and even more poison gets added!

Slimegirl can blow up any existing clones created from [color=#e0a9ff]{Copybuny}[/color] on use, and all clones that exist in her aura afterwards for each turn she gets.
[color=#8c8c8c]Note: She cannot blow up clones and[/color] [color=#e0a9ff]{Copybuny}[/color] [color=#8c8c8c]at the same time[/color].

This move lasts until she's been hit or when its lifetime is over."""
	codex.moveset["Meltdown"].set_gimmick_tick(7, "[Meltdown] Starts")
	codex.moveset["Meltdown"].custom_stats["Duration"] = slimegirl.MAX_MELTDOWN_TICKS
	
	codex.moveset["Lassail"].desc = """Slimegirl throws her tail out, which takes her aura with her.
While it’s out, her aura size is increased.

While standing in [color=#78df2b]Slimefire[/color], she throws out a powerful version of lassail that deals more damage and explodes when being pulled back!"""
	
	codex.moveset["Retail"].desc = """Redirects lassail to a different direction."""
	
	codex.moveset["Chernobyl"].desc = """Ignite all existing trails into acidic [color=#78df2b]Slimefire[/color]!
She may also [color=red]smite[/color] them with a fiery beam where they stood!

Afterwards, Slimegirl stops making Slimetrails and her friction is drastically increased for the duration of this move's cooldown.

May create Shokwaves that travel along the ground while [color=#5c874e]beam charge[/color] is active."""
	codex.moveset["Chernobyl"].set_gimmick_tick(4, "Chernobyl Fire")
	codex.moveset["Chernobyl"].custom_stats["Cooldown"] = slimegirl.MAX_CHERNOBYL_TICKS
	
	var melt_text = """Slimegirl warps to the first or last trail she's put down. This move is faster in combos but loses its invulnerability.
If lassail is out, she may also choose to warp to it instead, destroying lassail in the process."""
	codex.moveset["Melt_IntroGrounded"].desc = melt_text
	codex.moveset["Melt_IntroAerial"].desc = melt_text
	
	codex.moveset["VenomBuster"].custom_stats["Cooldown"] = slimegirl.MAX_VENOBUSTER_COOLDOWN
	
	codex.moveset["Sleismic"].desc = """Slimegirl strikes the ground, creating two giant vertical rays of doom!
	
While in neutral, the first beam will not appear.
The second beam will create Shokwaves while [color=#5c874e]beam charge[/color] is active."""
	
	codex.moveset["PN'D"].desc = """Inject poison directly into the opponent.
Will also enable [color=#5c874e]beam charge[/color]."""
	codex.moveset["PN'D_PumpSuper"].visible = true
	codex.moveset["PN'D_PumpSuper"].desc = """Inject more poison directly into the opponent at the cost of one super per pump."""
	codex.moveset["PN'D_PumpSuper"].custom_stats["Max Pumps"] = slimegirl.PND_PUMP_MAX+2

	codex.moveset["Goodrider"].visible = true
	codex.moveset["Goodrider"].desc = """Slams the opponent onto the ground, then jumps on top of them, skating across the ground damaging the opponent in the process.
The opponent must end up on a [color=#78df2b]slimetrail[/color] when thrown or else Slimegirl will trip and fall."""
	
	codex.moveset["Tumble"].visible = true
	codex.moveset["TumbleKnockdown"].visible = true
	
	codex.moveset["SlimeballGrounded"].desc = """Slimegirl throws a piece of herself with high velocity. Wherever it lands will create a Slimetrail if one isn't there already, can optionally [color=#78df2b]goop[/color] the last thing it hits.
	
Standing in [color=#78df2b]Slimefire[/color] will turn her Slimeballs into exploding fireballs!"""
	codex.moveset["SlimeballAerial"].visible = false
	
	codex.moveset["Venocache"].desc = """Pulls the opponent in to substitute active poison for instant damage based on the potency of Slimegirl's poison.
This move also temporarily increases her aura size, slimetrail width, and slimetrail duration.

It will always pull the opponent towards her aura."""

	codex.moveset["Allears"].desc = """Slimegirl jumps whenever she hits an opponent below herself.
Hitting projectiles will cause her to bounce off of it without taking damage. She may only do this once per projectile while she hasn't touched the ground."""
	
	codex.moveset["Slopdrop"].desc = """Fall from the air, hitting anything along the way!

On landing, if Slimegirl has [color=#5c874e]beam charge[/color], she will release Shokwaves in both directions!"""
	
	codex.moveset["Reboing"].visible = true
	codex.moveset["Snagtrik_Reboing"].visible = true
	codex.moveset["Snagtrik_Reboing"].title = "Reboing (From Snagtrik)"
	
	codex.moveset["Snagtrik_DropKick"].visible = true
	
	codex.moveset["24Karot_Grounded"].visible = true
	codex.moveset["24Karot_Aerial"].visible = true
	
	var burst_desc = """Temporarily increases aura size for [color=yellow]%s[/color] frames on use.""" % [slimegirl.RADIUS_SIZE_TIME_BURST]
	codex.moveset["DefensiveBurst"].desc = burst_desc
	codex.moveset["OffensiveBurst"].desc = burst_desc
	
	codex.moveset["Pounce_Lunge"].desc = """Leap onto the opponent (or don't) and playfully impale them with a carrot-mine while moving quickly which enables [color=#5c874e]beam charge[/color], otherwise throw them back.
While moving backwards, Slimegirl will do a much faster lunge with grounded attack invulnerablity on inititative.

This move is only accessible after landing on the ground or from [Mad Dash]"""
	
	codex.add_custom_text_tab("{Copybuny} / {Noxipaste}",
"""With her super, Slimegirl can duplicate her current move, storing its data and momentum as a clone accessible through [color=#e0a9ff]{Noxipaste}[/color].
She can have up to 3 active clones at a time before she starts deleting the oldest clone.

On hold, she can choose to warp to any one of her clones, destroying it in the process while repeating the move she was doing at that time.
[color=#8c8c8c](Think of it as "save stating")[/color]

[color=#ffa00d]Note: Slimegirl will not willingly make grounded clones in the air!
Any clones that fail to be created will not consume super.[/color]

""")

	codex.add_custom_text_tab("THE CREDITS",
"""Special thanks to all the people who helped me out in the Yomi Modding and Bracketeering Discords, I actually was not expecting Slimegirl to be as liked as much as she is.

She wouldn't be nearly as good right now if not for them!
""")

func setup_achievements(list):
	list.set_default_locked_icon("res://slimegirl/ramwould/sprites/achivements/achive_locked.png")

	list.define("achivement_hustle", {
		"title": "Reel Damag",
		"desc": "Land [img=]res://ui/ActionSelector/StateIcons/taunt.png[/img][color=fff6a9][Basik Punch][/color] [color=#ffa00d]5[/color] times.",
		"icon": "res://slimegirl/ramwould/sprites/achivements/achive_unlocked.png",
		"counter_id": "landed_hustle",
		"counter_target": 5,
	})
	
	list.define("achivement_toxic", {
		"title": "Super Toxic",
		"locked_desc": "Apply [color=#ffa00d]10000[/color] total ticks of [color=#78df2b]poison[/color]. (Unlocks customization options!)",
		"desc": "Apply [color=#ffa00d]10000[/color] total ticks of [color=#78df2b]poison[/color].",
		"icon": "res://slimegirl/ramwould/sprites/achivements/achive_unlocked.png",
		"counter_id": "poison_tracker",
		"counter_target": 4000,
	})
	
	list.define("achivement_cache", {
		"title": "Big Money",
		"desc": "Cache in [color=#ffa00d]500[/color] or more ticks of poison.",
		"icon": "res://slimegirl/ramwould/sprites/achivements/achive_unlocked.png",
	})
	
	list.define("achivement_beat_self", {
		"title": "Getting Real Slimy Now",
		"locked_desc": "Win against another [color=#ffa00d]woman of slimy properties[/color].",
		"desc": "Win against another [color=#ffa00d]Slimegirl[/color].",
		"icon": "res://slimegirl/ramwould/sprites/achivements/achive_unlocked.png",
	})
	
	list.define("achivement_beat_pixie", {
		"title": "EXTERMINATED :3",
		"locked_desc": "Win a match against a [color=#ffa00d]tiny floaty creature[/color].",
		"desc": "Win a match against [color=#ffa00d]Pixie[/color].",
		"icon": "res://slimegirl/ramwould/sprites/achivements/achive_unlocked.png",
	})
	
	list.define("achivement_beat_cirno", {
		"title": "It's kinda cold in here, don'tcha think?",
		"locked_desc": "Win a match against a [color=#a0a0ff]tiny floaty fairy[/color].",
		"desc": "Win a match against [color=#a0a0ff]Cirno[/color].",
		"icon": "res://slimegirl/ramwould/sprites/achivements/achive_unlocked.png",
	})
	
	list.define("achivement_play_slimpurt", {
		"title": "Best Buds",
		"locked_desc": "Play a match against [color=#ffa00d]another goober of similar properties[/color].",
		"desc": "Play a match against [color=#ffa00d]Slimpurt[/color].",
		"icon": "res://slimegirl/ramwould/sprites/achivements/achive_unlocked.png",
	})
	
	list.define("achivement_beat_juvenile", {
		"title": "Noisy Neighbors",
		"locked_desc": "Win a match against [rainbow]a bunny with [u]this[/u] color[/rainbow].",
		"desc": "Win a match against [rainbow]Juvenile[/rainbow].",
		"icon": "res://slimegirl/ramwould/sprites/achivements/achive_unlocked.png",
	})
	
	list.define("achivement_beat_bunbun", {
		"locked_title": "??? Incarnate?",
		"title": "Bunbun Incarnate?",
		"locked_desc": "Win a match against [color=red]a devil in disguise[/color].",
		"desc": "Win a match against [color=red]Bunbun[/color].",
		"icon": "res://slimegirl/ramwould/sprites/achivements/achive_unlocked.png",
	})
	
	list.define("achivement_beat_lopunny", {
		"title": "Mega Slimegirl",
		"locked_desc": "Are there laws against the pokemon, [color=#ffa00d]Batman[/color]?",
		"desc": "Win a match against a wild[color=#ffa00d]lopunny[/color].",
		"icon": "res://slimegirl/ramwould/sprites/achivements/achive_unlocked.png",
	})

	list.define("achivement_tumble", {
		"title": "Everyone Makes Mistakes",
		"locked_desc": "[color=#ffa00d]Slam[/color] into a wall. (Unlocks customization options!)",
		"desc": "[color=#ffa00d]Slam[/color] into a wall.",
		"icon": "res://slimegirl/ramwould/sprites/achivements/achive_unlocked.png",
	})
		
	list.define("achivement_spooberman", {
		"title": "The Amazing Goopy Gal",
		"desc": "[color=#ffa00d]Fling yourself from projectile[/color] to projectile without touching the ground or getting hit.",
		"icon": "res://slimegirl/ramwould/sprites/achivements/achive_unlocked.png",
	})
	
	list.define("achivement_lucky", {
		"title": "Getting Lucky",
		"desc": "[color=#ffa00d]Predict and dodge[/color] an attack with [Split].",
		"icon": "res://slimegirl/ramwould/sprites/achivements/achive_unlocked.png",
	})
	
	
func setup_options(options, params):
	options.add_label("[center]Customizable effects! [color=gray](More to be added...)")
	options.add_label("[center]Complete achievements to unlock more!")
	
	options.add_seperator()
	options.add_label("[center]Aura Options")
	options.add_seperator()
	
	var polygon1 = options.add_dropdown("extra_shape1", "Adds a shape inside her aura", "None")
	append_aura_shapes(polygon1, params)
	
	options.add_slider("num_points", "Number of sides her outer aura has", 16, {
		"min_value":3,
		"max_value":16,
		"step":1
	})
	
	options.add_seperator()
	options.add_label("[center]Color Options")
	options.add_seperator()
	
	options.add_label("[color=gray]Enabling this overrides Body Color with default Red/Blue")
	options.add_toggle("slime_alt_override", "Body/Slime Color Override", false)
	options.add_color("slime_alt_color", "Body Color\n(Override Must Be Off)", "ffffff")
	options.add_label("[color=gray]Fades between Body Color and the current character color")
	var slime_speeds = options.add_dropdown("slime_alt_speed", "Fade Style", "Off")
	append_fade_options(slime_speeds)
	options.add_toggle("slime_alt_reversed", "Swap Fade Color Positions?", false)
	options.add_seperator()
	options.add_seperator()
#	TODO: Add option to fade outline colors
#	i mean i COULD add it now and it wouldn't be hard, im just lazy :P
	
	options.add_color("s1_alt_color", "Aura Color", "00b035")
	options.add_label("[right][color=gray]Default: 00b035")
	options.add_label("[color=gray]Fade between Aura Color and current style color 1")
	var color1_speeds = options.add_dropdown("s1_alt_speed", "Fade Style", "Off")
	append_fade_options(color1_speeds)
	options.add_toggle("s1_alt_reversed", "Swap Fade Color Positions?", false)
	options.add_seperator()
	options.add_seperator()
	
	options.add_color("s2_alt_color", "Meltdown Color", "ff0000")
	options.add_label("[right][color=gray]Default: ff0000")
	options.add_label("[color=gray]Fade between Meltdown Color and current style color 2")
	var color2_speeds = options.add_dropdown("s2_alt_speed", "Fade Style", "Off")
	append_fade_options(color2_speeds)
	options.add_toggle("s2_alt_reversed", "Swap Fade Color Positions?", false)
	options.add_seperator()
	options.add_seperator()
	
	options.add_label("[center]Style Particle Options")
	options.add_seperator()
	
	var particle_settings = options.add_dropdown("particle_overrides", "Changes how custom style particles are displayed", "Default")
	particle_settings.add_item("Default")
	particle_settings.add_item("Snap To Aura")
	particle_settings.add_item("Snap & Scale To Aura")

	var particle_colors = options.add_dropdown("particle_tint", "Tints custom style particles to a style color", "None")
	append_particle_tint_options(particle_colors)
	options.add_label("[right][color=gray]For best results, use shades of white!")
	
	options.add_seperator()
	options.add_label("[center]|| Preview ||")
	options.add_seperator()
	
	var active_settings = params.codex_library.load_all_char_options(params.char_path)
	options.add_custom_scene("aura_editor", preload("res://slimegirl/ramwould/codex_stuff/AuraPreview.tscn"), DEFAULT_AURA_DATA, active_settings)
	
func append_fade_options(options):
	options.add_item("Off")
	options.add_seperator()
	options.add_item("Slow")
	options.add_item("Normal")
	options.add_item("Fast")
	options.add_item("Very Fast")
	options.add_item("Pulse on Damage Taken")
	options.add_item("Pulse on Damage Dealt")
	options.add_item("Pulse on Super Use")
	options.add_item("Fade to HP")
	options.add_item("Fade to Opponent HP")
	options.add_item("Fade to Poison")
	options.add_item("Fade to Burst")
	options.add_item("Fade to Max Meter")
	options.add_item("Fade to Match Time")
	options.add_item("Fade to AM/PM")

func append_particle_tint_options(options):
	options.add_item("None")
	options.add_item("Slime")
	options.add_item("Outline")
	options.add_item("Style 1")
	options.add_item("Style 2")

func append_aura_shapes(polygon1, params):
	var achievements_list = params.codex_library.get_achievement_list(params.char_path)
	
	var super_toxic = achievements_list.achievements["achivement_toxic"]
	var mistakes_were_made = achievements_list.achievements["achivement_tumble"]
	
	polygon1.add_item("None")
	
	polygon1.add_item("Triangle")
	polygon1.add_item("Square")
	polygon1.add_item("Pentagon")
	polygon1.add_item("Hexagon")
	polygon1.add_item("Octagon")
	
	polygon1.add_item("Circle")
	polygon1.add_item("Divided Circle")
	
	polygon1.add_item("Mimic")
	polygon1.add_item("Mimic (Full)")
	
	polygon1.add_item("Explosion")
	
#	TODO: add more unlockables
	if super_toxic.unlocked:
		polygon1.add_item("Star")
	if mistakes_were_made.unlocked:
		polygon1.add_item("Line")
		polygon1.add_item("X")
		polygon1.add_item("*")
		
func modify_style_data(style_data, params):
	for mod in AURA_MODIFIERS:
		style_data[mod] = params.codex_library.load_all_char_options(params.char_path).get(mod)
		
func save_as_aura_data(codex_library, char_path, aura_name)->bool:
	var dic = {}
	for mod in AURA_MODIFIERS:
		dic[mod] = codex_library.load_all_char_options(char_path).get(mod)
		
	return codex_library.save_codex_setting(aura_name+"_AURA_STYLE", dic)

func load_aura_data(codex_library, aura_name)->Dictionary:
	var dic = codex_library.load_codex_setting(aura_name+"_AURA_STYLE")
	if dic is Dictionary:
		return dic
		
	return {}

const DEFAULT_AURA_DATA = {
		"extra_shape1": -1,
		"num_points": 16,
		"slime_alt_color": "ffffff",
		"slime_alt_reversed": false,
		"slime_alt_speed": "Off",
		"slime_alt_override": false,
		"s1_alt_color": "00b035",
		"s1_alt_reversed": false,
		"s1_alt_speed": "Off",
		"s1_alt_override": false,
		"s2_alt_color": "ff0000",
		"s2_alt_reversed": false,
		"s2_alt_speed": "Off",
		"s2_alt_override": false,
		"particle_overrides": "Default",
		"particle_tint": "None",
	}
	
func reset_aura_data()->Dictionary:
	return DEFAULT_AURA_DATA
	
