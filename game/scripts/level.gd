class_name Level
extends Node2D
# Builds the graybox rooms in code. Rooms 1-2 are dev test rooms; rooms
# 3-5 are the Petrified Village story slice (see docs/AREA_VILLAGE.md).

const ROOM_W := 1280.0
const ROOM_H := 720.0

var room := 1
var entry := "default"
var player: Player = null

var _plate_door: StaticBody2D = null
var _door_closed_pos := Vector2.ZERO
var _door_open := false
var _door_lift := 80.0
var _grate: Area2D = null  # the Square's baths grate, dashed open


func _init(room_index: int, entry_id := "default") -> void:
	room = room_index
	entry = entry_id


func _ready() -> void:
	_build_bounds()
	match room:
		1:
			_build_test_yard()
		2:
			_build_chamber()
		3:
			_build_village_street()
		4:
			_build_well_yard()
		5:
			_build_sanctuary_steps()
		6:
			_build_square()
		7:
			_build_bell_tower()
		8:
			_build_sanctuary()
		9:
			_build_quarry_terraces()
		10:
			_build_crane_yard()
		11:
			_build_the_cut()
		12:
			_build_sample_baths()
		13:
			_build_sample_gardens()
		14:
			_build_sample_undercroft()
		16:
			_build_scaffold_heights()
		17:
			_build_haul_road()
		18:
			_build_switchback()
		19:
			_build_foredame_dig()
		20:
			_build_wisp_gallery()
		21:
			_build_colossus_shelf()
		22:
			_build_quarry_sanctuary()
		23:
			_build_drowned_vestibule()
		24:
			_build_long_soak()
		25:
			_build_cisterns()
		26:
			_build_deep_sanctuary()
		_:
			_build_sample_palace()


func _skit_once(key: String, lines: Array) -> void:
	if G.seen.get(key, false):
		return
	G.seen[key] = true
	G.dialogue.skit(lines)


func _goto_room(n: int, entry_id := "default") -> void:
	(get_parent() as Node).call_deferred("load_room", n, entry_id)


func _make_door(rect: Rect2, text: String, target: int, target_entry: String) -> void:
	var door := Util.area(self, rect, Color(0.9, 0.8, 0.3, 0.4))
	if text != "":
		Util.label(door, Vector2(-30, -26), text)
	door.body_entered.connect(func(body: Node) -> void:
		if body is Player:
			_goto_room(target, target_entry)
	)


func _spawn_player(entries: Dictionary) -> void:
	# spawn at the entry point matching the door the player came through
	player = Player.new()
	player.position = entries.get(entry, entries.get("default", Vector2(80, 440)))
	add_child(player)


func _make_chisel_mote(pos: Vector2) -> void:
	# motes are collected once and for all; the key survives resets and saves
	var key := "mote_%d_%d_%d" % [room, int(pos.x), int(pos.y)]
	if G.seen.get(key, false):
		return
	var mote := Util.area(self, Rect2(pos.x - 8, pos.y - 8, 16, 16), Color(0.7, 0.9, 1.0))
	Util.label(mote, Vector2(-36, -26), "chisel light")
	mote.body_entered.connect(func(body: Node) -> void:
		if body is Player:
			G.seen[key] = true
			G.chisel += 2
			G.say("A mote of Chisel Light. (+2)")
			mote.queue_free()
	)


func _build_bounds() -> void:
	Util.block(self, Rect2(-32, -200, 32, ROOM_H + 400))
	Util.block(self, Rect2(ROOM_W, -200, 32, ROOM_H + 400))


func _make_waystone(pos: Vector2, one_soul := true) -> void:
	# a Waystone holds one passage, then goes dark — so a room can never
	# be emptied of every statue it needs (the thesis, enforced)
	var key := "ws_%d_%d" % [room, int(pos.x)]
	if one_soul and G.seen.get(key, false):
		var spent := Util.area(self, Rect2(pos.x - 24, pos.y - 64, 48, 64),
				Color(0.3, 0.34, 0.4, 0.4))
		Util.label(spent, Vector2(-44, -50), "Waystone (spent)")
		return
	var ws := Util.area(self, Rect2(pos.x - 24, pos.y - 64, 48, 64), Color(0.4, 0.8, 0.9, 0.5))
	Util.label(ws, Vector2(-32, -50), "Waystone")
	ws.body_entered.connect(func(body: Node) -> void:
		if body is StatueNPC and body.soft:
			G.rescued += 1
			G.seen["resc_" + body.npc_name] = true
			if one_soul:
				# spend the stone immediately, not just on the next reload
				G.seen[key] = true
				ws.queue_free()
				var spent := Util.area(self, Rect2(pos.x - 24, pos.y - 64, 48, 64),
						Color(0.3, 0.34, 0.4, 0.4))
				Util.label(spent, Vector2(-44, -50), "Waystone (spent)")
				G.say("%s is safe in the Village. The Waystone dims, spent. (Rescued: %d)"
						% [body.npc_name, G.rescued])
			else:
				G.say("%s reaches the Waystone — she is safe. (Rescued: %d)"
						% [body.npc_name, G.rescued])
			body.was_rescued.emit(body)
			body.queue_free()
	)


func _make_entrance(rect: Rect2, text: String, action: Callable) -> void:
	# interior doorway: entered deliberately with F, never by walking past
	var e := Util.area(self, rect, Color(0.35, 0.3, 0.45, 0.8))
	Util.label(e, Vector2(-24, -26), text)
	e.add_to_group("entrance")
	e.set_meta("action", action)


func _make_goal(rect: Rect2, text: String) -> void:
	var goal := Util.area(self, rect, Color(0.9, 0.8, 0.3, 0.4))
	Util.label(goal, Vector2(-40, -30), "EXIT")
	goal.body_entered.connect(func(body: Node) -> void:
		if body is Player:
			G.say(text)
	)


func _make_chime(pos: Vector2) -> void:
	# scenery only — the reset ward is rung with R from anywhere in the room
	var chime := Util.area(self, Rect2(pos.x - 16, pos.y - 48, 32, 48), Color(0.85, 0.85, 0.4, 0.6))
	Util.label(chime, Vector2(-52, -40), "Reset ward (R)")


func _make_water(rect: Rect2) -> void:
	var wa := Util.area(self, rect, Color(0.25, 0.45, 0.85, 0.4))
	wa.body_entered.connect(func(body: Node) -> void:
		if body is Player:
			body.in_water = true
			body.water_surface_y = rect.position.y + 6.0
		elif body is StatueNPC:
			body.linear_damp = 3.0
			if body.soft:
				G.say("%s follows the light into the water — and sinks. Stone dreams don't swim."
						% body.npc_name)
		elif body is RigidBody2D:
			body.linear_damp = 3.0
	)
	wa.body_exited.connect(func(body: Node) -> void:
		if body is Player:
			body.in_water = false
		elif body is RigidBody2D:
			body.linear_damp = 0.0
	)


func _make_cracked(rect: Rect2) -> void:
	# breaks under a heavy falling body, or under a Chisel Dash strike
	var floor_body := Util.block(self, rect, Color(0.55, 0.5, 0.45))
	Util.label(floor_body, Vector2(-40, -28), "cracked")
	var sensor := Util.area(self,
			Rect2(rect.position.x, rect.position.y - 10, rect.size.x, 12),
			Color(0, 0, 0, 0))
	var shatter := func() -> void:
		G.say("The cracked stone shatters!")
		floor_body.queue_free()
		sensor.queue_free()
	floor_body.add_to_group("cracked")
	floor_body.set_meta("shatter", shatter)
	sensor.body_entered.connect(func(body: Node) -> void:
		if body is RigidBody2D and body.mass >= 10.0 and body.linear_velocity.y > 300.0:
			shatter.call()
	)


func _make_plate_and_door(plate_pos: Vector2, door_pos: Vector2, door_h := 96.0) -> void:
	_plate_door = Util.block(self, Rect2(door_pos.x, door_pos.y - door_h, 24, door_h),
			Color(0.5, 0.4, 0.2))
	_door_lift = door_h - 16.0
	_door_closed_pos = _plate_door.position
	Util.label(_plate_door, Vector2(-20, -64), "door")
	var plate := Util.area(self,
			Rect2(plate_pos.x - 32, plate_pos.y - 8, 64, 8), Color(0.7, 0.7, 0.75))
	Util.label(plate, Vector2(-60, -24), "plate (needs weight)")
	plate.set_meta("is_plate", true)


func _physics_process(_delta: float) -> void:
	if _grate != null and is_instance_valid(_grate) and player != null \
			and player.is_dashing() and _grate.overlaps_body(player):
		_grate = null
		G.seen["baths_open"] = true
		G.say("The grate shatters — the black water roars away down the stair. "
				+ "The Sunken Baths lie open.")
		_goto_room(6, "gate")
		return
	if _plate_door == null:
		return
	var pressed := false
	for a in get_children():
		if a is Area2D and a.has_meta("is_plate"):
			var weight := 0.0
			for body in a.get_overlapping_bodies():
				if body is RigidBody2D:
					weight += body.mass
				elif body is Player:
					weight += 4.0
			pressed = weight >= 10.0
	if pressed and not _door_open:
		_door_open = true
		var tw := create_tween()
		tw.tween_property(_plate_door, "position:y", _door_closed_pos.y - _door_lift, 0.4)
	elif not pressed and _door_open:
		_door_open = false
		var tw := create_tween()
		tw.tween_property(_plate_door, "position:y", _door_closed_pos.y, 0.4)


func _make_npc(pos: Vector2, npc_kind: String, npc_name: String,
		persist := true) -> StatueNPC:
	# a rescued person is home for good; callers must null-check rescuables
	if persist and G.seen.get("resc_" + npc_name, false):
		return null
	var npc := StatueNPC.new()
	npc.kind = npc_kind
	npc.npc_name = npc_name
	npc.position = pos
	add_child(npc)
	return npc


# ------------------------------------------------------------------ room 1
func _build_test_yard() -> void:
	Util.label(self, Vector2(60, 120),
			"TEST YARD — try: Q petrify (slope/plate/water/cracked), E soften the Kneeler")
	# main ground, with a pit under the cracked bridge and a water basin
	Util.block(self, Rect2(0, 480, 500, 240))       # left ground
	_make_cracked(Rect2(500, 480, 96, 16))          # cracked bridge
	Util.block(self, Rect2(500, 640, 96, 80))       # cellar floor under it
	Util.block(self, Rect2(596, 480, 404, 240))     # middle ground
	Util.block(self, Rect2(1000, 560, 160, 160))    # water basin floor
	Util.block(self, Rect2(1160, 480, 120, 240))    # right ground
	# sunken pool: surface 40 px below ground; flesh can only weakly hop from
	# water, so the far lip needs a sunken statue/crate to stand on
	_make_water(Rect2(1000, 520, 160, 40))
	Util.block(self, Rect2(1000, 520, 24, 40))      # re-entry shelf at waterline
	# cellar side walls so nothing escapes sideways, plus steps back out
	Util.block(self, Rect2(480, 496, 20, 224))
	Util.block(self, Rect2(596, 496, 20, 224))
	Util.block(self, Rect2(505, 588, 30, 12))
	Util.block(self, Rect2(560, 540, 30, 12))
	# high dive platform above the cracked bridge (petrify mid-fall to break it)
	Util.block(self, Rect2(420, 320, 120, 16))
	Util.block(self, Rect2(340, 400, 80, 16))       # step up
	Util.label(self, Vector2(430, 290), "petrify mid-fall here")
	# slope: stone form slides, flesh walks
	var slope := Util.block(self, Rect2(700, 430, 200, 20), Color(0.4, 0.4, 0.5))
	slope.rotation = -0.42
	Util.label(self, Vector2(760, 380), "slope (stone slides)")
	# plate + door + crate: the plate sits outside the door it opens
	_make_plate_and_door(Vector2(200, 480), Vector2(130, 480))
	Util.label(self, Vector2(40, 440), "storeroom")
	Util.crate(self, Vector2(300, 440))
	Util.label(self, Vector2(270, 420), "crate: too light")
	# a kneeler to soften and to dunk
	var odessa := _make_npc(Vector2(940, 460), "kneeler", "Odessa", false)
	odessa.stone_lines = [
		"Odessa knelt to pick up her daughter's doll when the wave came.",
		"Amethyst: \"I'll come back for you, Odessa. I promise.\"",
	]
	odessa.soft_lines = [
		"Odessa murmurs: \"...Amethyst? The light... it's warm here...\"",
	]
	Util.label(self, Vector2(1010, 380), "stone sinks, flesh floats —\npush something in to cross")
	_make_chime(Vector2(880, 480))
	_make_waystone(Vector2(1220, 480), false)
	_spawn_player({"default": Vector2(250, 460)})
	player.push_enabled = true
	player.dash_enabled = true


# --------------------------------------------------- room 3: village street
func _build_village_street() -> void:
	# ground, with the sealed cellar under a cracked patch: nothing in the
	# village can break it — it waits for Self-Petrification (the tutorial's
	# visible "come back later" promise)
	Util.block(self, Rect2(0, 480, 150, 240))
	_make_cracked(Rect2(150, 480, 80, 16))
	Util.block(self, Rect2(150, 624, 80, 96))      # cellar floor
	Util.block(self, Rect2(155, 584, 26, 10))      # cellar steps back out
	Util.block(self, Rect2(196, 540, 26, 10))
	_make_chisel_mote(Vector2(190, 608))
	var cellar_lore := Util.area(self, Rect2(150, 580, 80, 40), Color(0, 0, 0, 0))
	cellar_lore.body_entered.connect(func(body: Node) -> void:
		if body is Player:
			_skit_once("v0_cellar", [
				{"who": "narrator", "text": "Ida's cellar workshop. The bench is lined "
						+ "with half-carved amethyst geodes, every one worked by the "
						+ "same patient hand."},
				{"who": "ame", "text": "These are... me. Every one of them is my face. "
						+ "Ida — what were you making? And how long before the wave "
						+ "did you start?"},
			])
	)
	var crack_hint := Util.area(self, Rect2(150, 440, 80, 40), Color(0, 0, 0, 0))
	crack_hint.body_entered.connect(func(body: Node) -> void:
		if body is Player and not G.seen.get("v1_crack", false):
			G.seen["v1_crack"] = true
			G.say("The flagstones are cracked — something hollow below. "
					+ "Nothing she can do about it. Yet.")
	)
	Util.block(self, Rect2(230, 480, 670, 240))
	Util.block(self, Rect2(900, 400, 380, 320))    # raised lane out of the square
	var petra := _make_npc(Vector2(300, 464), "kneeler", "Petra")
	petra.anchored = true
	petra.char_id = "petra"
	petra.stone_lines = [
		"Petra the Mason, kneeling at her whetstone. The wave took her mid-sharpen.",
		"Amethyst: \"Master Petra taught me to read the grain of marble. Her stone is... deep.\"",
		"Amethyst: \"I can't reach her. Not yet. Not with this little light.\"",
	]
	var lina := _make_npc(Vector2(600, 452), "runner", "Lina")
	lina.char_id = "lina"
	lina.stone_lines = [
		"Lina. Her best friend. Caught running toward Amethyst's cellar door, arm outstretched.",
		"Amethyst: \"You were coming to warn me. Weren't you.\"",
	]
	lina.soft_lines = ["Lina murmurs: \"...run, Amethyst... it's coming... run...\""]
	lina.refrozen.connect(func(_npc: StatueNPC) -> void:
		_skit_once("v1_first_refreeze", [
			{"who": "ame", "text": "I'm sorry, Lina. I need your shoulders."},
			{"who": "ame", "text": "I'll come back for you. I promise. I promise."},
		])
	)
	# Ida's chisel is a key item: taken once, forever; it wakes the amulet
	if not G.seen.get("v1_amulet_taken", false):
		var chisel := Util.area(self, Rect2(708, 440, 24, 24), Color(0.95, 0.85, 0.4))
		Util.label(chisel, Vector2(-40, -30), "Ida's chisel")
		chisel.body_entered.connect(func(body: Node) -> void:
			if body is Player and not body.soften_enabled:
				G.seen["v1_amulet_taken"] = true
				body.soften_enabled = true
				chisel.queue_free()
				_skit_once("v1_amulet", [
					{"who": "narrator", "text": "Ida's chisel, laid on the workshop step "
							+ "as if set down mid-thought. The amulet at Amethyst's "
							+ "throat flares to meet it."},
					{"who": "ame", "text": "Chisel and stone. Her two answers to everything. "
							+ "Ida, where ARE you?"},
					{"who": "narrator", "text": "Near a statue, press E: the woken amulet can "
							+ "soften stone — a few breaths, no more. The softened dream, "
							+ "and follow its light. F lets you look closer, or speak."},
				])
		)
	_make_door(Rect2(1256, 320, 24, 80), "well yard →", 4, "west")
	_spawn_player({"default": Vector2(80, 460), "east": Vector2(1160, 380)})
	player.soften_enabled = G.seen.get("v1_amulet_taken", false)
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	player.dash_enabled = G.seen.get("chisel_dash", false)
	_skit_once("v1_open", [
		{"who": "narrator", "text": "Stone. She remembers being stone. A year, a breath — "
				+ "the dark between doesn't count time."},
		{"who": "ame", "petrified": true, "text": "(Something is warm at her throat. "
				+ "One point of heat in a world gone cold.)"},
		{"who": "narrator", "text": "The amulet flares. The shell cracks and falls away "
				+ "like plaster. Amethyst breathes."},
		{"who": "ame", "text": "—AH. Air. Dust. ...An amulet? Whose— these are Ida's "
				+ "knots. Ida hung this on me. When?"},
		{"who": "narrator", "text": "No answer. The village is white and silent. And on "
				+ "the cellar stair, arm outstretched toward where Amethyst slept—"},
		{"who": "ame", "text": "Lina."},
	])


# ------------------------------------------------------ room 4: well yard
func _build_well_yard() -> void:
	G.say("— The Well Yard —")
	Util.block(self, Rect2(0, 480, 700, 240))
	Util.block(self, Rect2(840, 480, 440, 240))
	Util.block(self, Rect2(686, 496, 14, 224))     # pit wall left
	Util.block(self, Rect2(840, 496, 14, 224))     # pit wall right
	Util.block(self, Rect2(700, 572, 140, 148))    # pit floor: kneeler-viable depth
	Util.label(self, Vector2(730, 542), "stuck? R")
	# return overpass: reachable only from the east step, so backtracking
	# west is always possible, but it can never shortcut the pit eastward
	Util.block(self, Rect2(860, 416, 40, 12))      # east step up
	Util.block(self, Rect2(620, 352, 240, 14))     # overpass spanning the pit
	_make_waystone(Vector2(140, 480))
	var marla := _make_npc(Vector2(380, 464), "kneeler", "Marla")
	if marla:
		marla.char_id = "marla"
		marla.stone_lines = [
			"Marla the baker, kneeling over a dropped basket. Flour, fossilized mid-spill.",
			"Amethyst: \"The Waystone still glows. If she could just reach it...\"",
		]
		marla.soft_lines = ["Marla murmurs: \"...the bread... I can smell it burning...\""]
		marla.was_rescued.connect(func(_npc: StatueNPC) -> void:
			_skit_once("v2_rescue", [
				{"who": "marla", "text": "—flour. I was carrying flour, and then... "
						+ "Amethyst? Why are you crying?"},
				{"who": "ame", "text": "Welcome back, Marla. Go home. Bake something. "
						+ "Don't look at the square."},
				{"who": "narrator", "text": "First rescue. The ledger's first name, "
						+ "crossed out. The Waystone goes dark — one passage is all "
						+ "any of them hold."},
			])
		)
	var sena := _make_npc(Vector2(560, 452), "runner", "Sena")
	if sena:
		sena.char_id = "sena"
		sena.stone_lines = [
			"Sena, the well-keeper's daughter, frozen sprinting for the yard gate.",
			"Amethyst: \"The pit's too wide to jump, too deep to climb. "
					+ "But if she follows me down...\"",
		]
		sena.soft_lines = ["Sena whispers: \"...keep going... I'll follow the light...\""]
	var thesis := Util.area(self, Rect2(1040, 400, 30, 80), Color(0, 0, 0, 0))
	thesis.body_entered.connect(func(body: Node) -> void:
		if body is Player:
			_skit_once("v2_thesis", [
				{"who": "ame", "text": "One home safe. One left standing at the bottom "
						+ "of a ditch."},
				{"who": "ame", "text": "Is that what saving everyone looks like? ...It is. "
						+ "For now. I'm coming back, Sena."},
			])
	)
	_make_door(Rect2(0, 400, 24, 80), "", 3, "east")
	_make_door(Rect2(1256, 400, 24, 80), "steps →", 5, "west")
	_spawn_player({"default": Vector2(80, 460), "west": Vector2(60, 460),
			"east": Vector2(1180, 460)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	player.dash_enabled = G.seen.get("chisel_dash", false)


# ------------------------------------------------ room 5: sanctuary steps
func _build_sanctuary_steps() -> void:
	G.say("— The Sanctuary Steps —")
	# the climb occupies the right half; the left ground stays a clear
	# corridor so a softened NPC can be walked to the Waystone
	Util.block(self, Rect2(0, 480, 1280, 240))      # ground
	Util.block(self, Rect2(700, 424, 60, 56))       # surviving step
	Util.block(self, Rect2(820, 384, 110, 96))      # landing
	Util.block(self, Rect2(990, 364, 44, 116))      # stair pillar
	Util.block(self, Rect2(1090, 284, 190, 196))    # chapel porch
	_make_chisel_mote(Vector2(860, 354))
	_make_chisel_mote(Vector2(1060, 300))
	_make_chisel_mote(Vector2(1140, 254))
	_make_waystone(Vector2(80, 480))
	# Sister Aldith, anchored atop the pillar — the stair's missing step, forever
	var aldith := _make_npc(Vector2(1012, 348), "kneeler", "Sister Aldith")
	aldith.anchored = true
	aldith.char_id = "aldith"
	aldith.stone_lines = [
		"Sister Aldith of the Sanctuary, kneeling in prayer atop the stair pillar.",
		"Amethyst: \"Anchored, like Master Petra. The curse holds the pious hardest.\"",
		"Amethyst: \"...I'm going to step on a nun. Forgive me twice, Sister.\"",
	]
	# Odile — not needed for the climb; she is only there to be saved (or not)
	var odile := _make_npc(Vector2(550, 452), "runner", "Odile")
	if odile:
		odile.char_id = "odile"
		odile.stone_lines = [
			"Odile the bell-ringer, frozen sprinting from the chapel, hands over her ears.",
			"Amethyst: \"The Waystone is a long, long walk from here. "
					+ "Her grace might just cover it.\"",
		]
		odile.soft_lines = ["Odile whispers: \"...the bells... did the bells stop?...\""]
		odile.was_rescued.connect(func(_npc: StatueNPC) -> void:
			_skit_once("v3_rescue", [
				{"who": "ame", "text": "Every step of that walk, I was sure the light "
						+ "would run out. Go home, Odile. Ring nothing."},
			])
		)
	# the Sanctuary wakes for the warmth of the returned: 2 rescues open it.
	# It is an interior doorway — entered with F, never by walking past.
	var lit: bool = G.seen.get("masons_grip", false)
	_make_entrance(Rect2(1140, 204, 48, 80),
			"Sanctuary (F)" if lit else "Sanctuary (dark) (F)",
			func() -> void:
				if G.rescued >= 2 or G.seen.get("masons_grip", false):
					_goto_room(8)
					return
				_skit_once("v3_door", [
					{"who": "narrator", "text": "The Sanctuary door is cold. Behind it, "
							+ "something vast is holding its breath."},
					{"who": "ame", "text": "Dark. The whole Sanctuary, dark. The amulet "
							+ "flickers toward it like it wants to go home."},
					{"who": "ame", "text": "It isn't light it wants. It's warmth. "
							+ "The living kind."},
					{"who": "narrator", "text": "The door listens for footsteps coming "
							+ "home. Bring the rescued back to the Village."},
				])
				G.say("The door does not move. (Rescued: %d of 2 — it needs warmth.)"
						% G.rescued))
	_make_door(Rect2(0, 400, 24, 80), "", 4, "east")
	_make_door(Rect2(1256, 204, 24, 80), "square →", 6, "ledge")
	_spawn_player({"default": Vector2(60, 460), "west": Vector2(60, 460),
			"porch": Vector2(1180, 264)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	player.dash_enabled = G.seen.get("chisel_dash", false)


# ------------------------------------------------- room 6: the square (hub)
func _build_square() -> void:
	G.say("— The Square —")
	# breather room: no puzzle, no skit — the tableau speaks for itself.
	# Branches: west ledge back to the Steps, ground west door to the Bell
	# Tower, east the sealed Quarry gate, and the flooded Baths stair.
	Util.block(self, Rect2(0, 480, 900, 240))       # plaza, west of the stair
	Util.block(self, Rect2(980, 480, 300, 240))     # plaza, east of the stair
	# the drowned stair: shallow enough to stand up and climb back out.
	# Once the grate below is dashed open, the water drains and the stair
	# descends into the Sunken Baths.
	Util.block(self, Rect2(900, 516, 80, 204))
	if G.seen.get("baths_open", false):
		_make_door(Rect2(920, 456, 40, 60), "baths ↓", 23, "top")
	elif G.seen.get("chisel_dash", false):
		_grate = Util.area(self, Rect2(900, 476, 80, 40), Color(0.3, 0.4, 0.45, 0.6))
		Util.label(_grate, Vector2(-40, -40), "cracked grate")
		_make_water(Rect2(900, 496, 80, 20))
	else:
		_make_water(Rect2(900, 496, 80, 20))
	Util.block(self, Rect2(0, 320, 160, 16))        # raised entry from the Steps
	Util.block(self, Rect2(160, 380, 60, 12))
	Util.block(self, Rect2(230, 424, 60, 12))       # high enough to walk under
	Util.block(self, Rect2(600, 420, 120, 60), Color(0.45, 0.5, 0.55))  # fountain
	# the tableau — the moment of the wave, held
	var dancer := _make_npc(Vector2(420, 452), "runner", "a dancer")
	dancer.anchored = true
	dancer.stone_lines = [
		"She was mid-turn when it came. Weeks on, her skirt still swings.",
	]
	var sisters := _make_npc(Vector2(790, 464), "kneeler", "two sisters")
	sisters.anchored = true
	sisters.stone_lines = [
		"Two sisters, huddled over a game of knucklebones. The pieces never fell.",
	]
	var mercer := _make_npc(Vector2(1060, 452), "runner", "the mercer")
	mercer.anchored = true
	mercer.stone_lines = [
		"The mercer, scales still in her hand, mid-argument with nobody now.",
	]
	# rescued villagers gather at the fountain as the ledger fills
	for i in range(mini(G.rescued, 6)):
		var v := Util.make_sprite(Vector2(18, 40), Color(0.85, 0.7, 0.55))
		v.position = Vector2(610 + (i % 3) * 34, 398 - float(i / 3) * 4)
		add_child(v)
	# west, on the ledge: back to the Sanctuary Steps
	_make_door(Rect2(0, 240, 24, 80), "← steps", 5, "porch")
	# west, on the ground: the bell tower door (interior — F to enter)
	_make_entrance(Rect2(40, 420, 40, 60), "bell tower (F)",
			func() -> void: _goto_room(7))
	# east: the Quarry gate — Mason's Grip shifts the fallen arch
	if G.seen.get("masons_grip", false):
		_make_door(Rect2(1256, 400, 24, 80), "quarry →", 9, "west")
	else:
		Util.block(self, Rect2(1240, 360, 40, 120), Color(0.4, 0.36, 0.32))
		var gate := Util.area(self, Rect2(1216, 400, 24, 80), Color(0, 0, 0, 0))
		gate.body_entered.connect(func(body: Node) -> void:
			if body is Player and not G.seen.get("v4_gate", false):
				G.seen["v4_gate"] = true
				G.say("The Quarry gate, buried under half its own arch. "
						+ "It would take a mason's strength to shift it.")
		)
	# the flooded stair announces itself once
	var stair_hint := Util.area(self, Rect2(900, 460, 80, 40), Color(0, 0, 0, 0))
	stair_hint.body_entered.connect(func(body: Node) -> void:
		if body is Player and not G.seen.get("v4_stair", false):
			G.seen["v4_stair"] = true
			G.say("The stair to the Sunken Baths drowns in black water. Not yet.")
	)
	_spawn_player({"default": Vector2(300, 460), "ledge": Vector2(80, 300),
			"tower": Vector2(120, 460), "gate": Vector2(1180, 460),
			"stair": Vector2(850, 460)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	player.dash_enabled = G.seen.get("chisel_dash", false)


# --------------------------------------------- room 7: bell tower (optional)
func _build_bell_tower() -> void:
	G.say("— The Bell Tower —")
	# optional vertical challenge: nothing new to learn, just climbing.
	Util.block(self, Rect2(0, 480, 1280, 240))      # ground
	Util.block(self, Rect2(480, -200, 20, 700))     # shaft walls
	Util.block(self, Rect2(780, -200, 20, 700))
	var rungs := [
		Rect2(540, 420, 60, 12), Rect2(660, 360, 60, 12),
		Rect2(540, 300, 60, 12), Rect2(660, 240, 60, 12),
		Rect2(540, 180, 60, 12), Rect2(660, 120, 60, 12),
		Rect2(540, 60, 60, 12), Rect2(660, 0, 60, 12),
		Rect2(540, -60, 60, 12),
	]
	for r in rungs:
		Util.block(self, r)
	Util.block(self, Rect2(560, -120, 160, 16))     # bell gallery
	Util.block(self, Rect2(620, -170, 40, 50), Color(0.6, 0.45, 0.2))  # the bell
	_make_chisel_mote(Vector2(590, -140))
	_make_chisel_mote(Vector2(700, -140))
	var view := Util.area(self, Rect2(560, -180, 160, 60), Color(0, 0, 0, 0))
	view.body_entered.connect(func(body: Node) -> void:
		if body is Player:
			_skit_once("v5_view", [
				{"who": "narrator", "text": "From the bell gallery, the whole kingdom "
						+ "lies still and white under the morning."},
				{"who": "ame", "text": "The quarry cliffs... there's something on them. "
						+ "Coiled. Still as stone — but nothing that big should look "
						+ "like it's breathing."},
			])
	)
	_make_entrance(Rect2(520, 420, 40, 60), "← square (F)",
			func() -> void: _goto_room(6, "tower"))
	_spawn_player({"default": Vector2(640, 460)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	player.dash_enabled = G.seen.get("chisel_dash", false)


# ------------------------------------------------------------------ room 2
func _build_chamber() -> void:
	Util.label(self, Vector2(60, 120),
			"CHAMBER — the pit is too wide to jump, too deep to climb. "
			+ "She follows your light — even over an edge.")
	Util.label(self, Vector2(60, 150), "(stuck in the pit alone? press R)")
	Util.block(self, Rect2(0, 480, 500, 240))       # start side
	Util.block(self, Rect2(640, 480, 640, 240))     # far side
	# pit: 140 px wide, 110 px deep — she is the missing step
	Util.block(self, Rect2(486, 496, 14, 224))      # pit wall left
	Util.block(self, Rect2(640, 496, 14, 224))      # pit wall right
	Util.block(self, Rect2(500, 590, 140, 130))     # pit floor
	# Maren the Runner, frozen mid-stride, facing the pit
	var maren := _make_npc(Vector2(340, 452), "runner", "Maren", false)
	maren.stone_lines = [
		"Maren was running for the bridge when the wave caught her mid-stride.",
		"Amethyst: \"Forgive me, Maren. I need your shoulders.\"",
	]
	maren.soft_lines = [
		"Maren whispers: \"...keep going... I'll follow the light...\"",
	]
	_make_waystone(Vector2(100, 480), false)
	_make_chime(Vector2(200, 480))
	_make_goal(Rect2(1180, 400, 60, 80),
			"Chamber complete. You left her standing at the bottom of the pit. "
			+ "The ledger remembers. (Or: F1 debug-soften and walk her to the Waystone.)")
	_spawn_player({"default": Vector2(80, 460)})
	player.push_enabled = true
	player.dash_enabled = true


# --------------------------------------------- room 8: village sanctuary
func _build_sanctuary() -> void:
	G.say("— The Village Sanctuary —")
	Util.block(self, Rect2(0, 480, 1280, 240))
	# columns and braziers are decor sprites, not bodies
	for x in [260, 460, 860, 1060]:
		var col := Util.make_sprite(Vector2(30, 240), Color(0.42, 0.42, 0.52))
		col.position = Vector2(x, 360)
		add_child(col)
	var lit: bool = G.seen.get("masons_grip", false)
	for x in [540, 780]:
		var brazier := Util.make_sprite(Vector2(20, 30),
				Color(1.0, 0.7, 0.3) if lit else Color(0.3, 0.28, 0.34))
		brazier.position = Vector2(x, 425)
		add_child(brazier)
	Util.block(self, Rect2(620, 440, 80, 40), Color(0.6, 0.6, 0.7))  # the altar
	var altar := Util.area(self, Rect2(600, 400, 120, 40), Color(0, 0, 0, 0))
	altar.body_entered.connect(func(body: Node) -> void:
		if body is Player and not G.seen.get("masons_grip", false):
			G.seen["masons_grip"] = true
			body.push_enabled = true
			G.save_state(room)
			_skit_once("v6_relight", [
				{"who": "narrator", "text": "Amethyst sets the amulet on the altar. "
						+ "One by one, the braziers remember fire."},
				{"who": "ame", "text": "...Ida? No. Just the warmth. Just the walls, waking."},
				{"who": "narrator", "text": "The Sanctuary grants what it can: MASON'S GRIP. "
						+ "Her hands remember her trade — statues can now be pushed, "
						+ "slowly and surely."},
				{"who": "ame", "text": "Stone moves for me now. Hold on, everyone. "
						+ "I'm coming."},
			])
	)
	_make_door(Rect2(0, 400, 24, 80), "", 5, "porch")
	_spawn_player({"default": Vector2(100, 460)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	player.dash_enabled = G.seen.get("chisel_dash", false)


# ------------------------------------------ room 9: quarry gate terraces
func _build_quarry_terraces() -> void:
	G.say("— The Quarry: Gate Terraces —")
	# branch room: climb the slabs to the Crane Yard (top-east door) or walk
	# the lower corridor to The Cut (ground-east door)
	Util.block(self, Rect2(0, 480, 1280, 240))      # floor
	Util.block(self, Rect2(300, 432, 50, 48))       # step, west face
	Util.block(self, Rect2(350, 384, 250, 96))      # terrace ledge
	Util.block(self, Rect2(600, 432, 40, 48))       # step, east face — the
	# terrace is climbable from both sides, so entering from the haul road
	# can always reach the west door even with Brona rescued
	Util.block(self, Rect2(640, 336, 60, 16))       # hop slab
	Util.block(self, Rect2(700, 288, 300, 16))      # slab B (floating scaffold)
	Util.block(self, Rect2(960, 240, 50, 16))       # hop slab
	Util.block(self, Rect2(1000, 208, 280, 16))     # slab C
	_make_chisel_mote(Vector2(480, 352))
	_make_chisel_mote(Vector2(1100, 176))
	_make_waystone(Vector2(1080, 480))
	var surveyor := _make_npc(Vector2(850, 272), "kneeler", "the surveyor")
	surveyor.anchored = true
	surveyor.stone_lines = [
		"The quarry surveyor, kneeling over her charts on the scaffold. Anchored.",
		"Amethyst: \"She measured every cut in this cliff. Now the cliff keeps her.\"",
	]
	var brona := _make_npc(Vector2(900, 452), "runner", "Brona")
	if brona:
		brona.stone_lines = [
			"Brona the hauler, sprinting for the gate with empty hands.",
			"Amethyst: \"The Waystone hums right there. A short walk. An easy promise.\"",
		]
		brona.soft_lines = ["Brona murmurs: \"...drop the load... run...\""]
	_make_door(Rect2(0, 400, 24, 80), "", 6, "gate")
	_make_door(Rect2(1256, 128, 24, 80), "crane yard →", 10, "west")
	_make_door(Rect2(1256, 400, 24, 80), "haul road →", 17, "west")
	_spawn_player({"default": Vector2(60, 460), "west": Vector2(60, 460),
			"top": Vector2(1180, 188), "lower": Vector2(1160, 460)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	player.dash_enabled = G.seen.get("chisel_dash", false)


# ----------------------------------------------- room 10: the crane yard
func _build_crane_yard() -> void:
	G.say("— The Quarry: Crane Yard —")
	# counterweight lesson: only Hetta is heavy enough for the plate.
	# A jumpable drop shaft east of the plate falls through to the Haul Road.
	Util.block(self, Rect2(0, 480, 900, 240))
	Util.block(self, Rect2(1000, 480, 280, 240))
	var hatch := Util.area(self, Rect2(900, 700, 100, 20), Color(0, 0, 0, 0))
	hatch.body_entered.connect(func(body: Node) -> void:
		if body is Player:
			_goto_room(17, "hatch")
	)
	Util.label(self, Vector2(910, 500), "drop shaft")
	# tall enough that even standing on Hetta can't clear it — the plate
	# is the only way through
	_make_plate_and_door(Vector2(500, 480), Vector2(700, 480), 128.0)
	Util.crate(self, Vector2(300, 440))
	var hetta := _make_npc(Vector2(600, 464), "kneeler", "Hetta")
	if hetta:
		hetta.stone_lines = [
			"Hetta the crane-hand, kneeling to check a knot that will never slip.",
			"Amethyst: \"The Waystone is a room away. Too far for a few seconds of grace.\"",
			"Amethyst: \"But she's heavier than any crate here. Forgive me, Hetta.\"",
		]
		hetta.soft_lines = [
			"Hetta murmurs: \"...the counterweight... mind the counterweight...\"",
		]
	# crane decor
	var mast := Util.make_sprite(Vector2(16, 300), Color(0.45, 0.4, 0.3))
	mast.position = Vector2(950, 330)
	add_child(mast)
	var jib := Util.make_sprite(Vector2(260, 12), Color(0.45, 0.4, 0.3))
	jib.position = Vector2(950, 190)
	add_child(jib)
	_make_chisel_mote(Vector2(860, 440))
	_make_door(Rect2(0, 400, 24, 80), "", 9, "top")
	_make_door(Rect2(1256, 400, 24, 80), "scaffold →", 16, "west")
	_spawn_player({"default": Vector2(60, 460), "west": Vector2(60, 460),
			"east": Vector2(1180, 460)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	player.dash_enabled = G.seen.get("chisel_dash", false)


# ---------------------------------------------------- room 11: the cut
func _build_the_cut() -> void:
	G.say("— The Quarry: The Cut —")
	# a deep excavation between two grounds; a cracked seam hides an alcove
	Util.block(self, Rect2(0, 480, 400, 240))       # west ground
	Util.block(self, Rect2(400, 640, 20, 80))       # pit floor, west sliver
	_make_cracked(Rect2(420, 640, 80, 16))          # cracked seam in the pit floor
	Util.block(self, Rect2(420, 700, 80, 20))       # cavity floor beneath it
	Util.block(self, Rect2(500, 640, 400, 80))      # pit floor, east of the seam
	Util.block(self, Rect2(400, 544, 20, 12))       # west climb steps (thin,
	Util.block(self, Rect2(400, 600, 20, 12))       # clear of the falling block)
	Util.block(self, Rect2(840, 544, 30, 12))       # east climb steps
	Util.block(self, Rect2(870, 600, 30, 12))
	Util.block(self, Rect2(900, 480, 380, 240))     # east ground
	_make_chisel_mote(Vector2(475, 685))            # inside the hidden cavity
	var twins := _make_npc(Vector2(650, 624), "kneeler", "the digger twins")
	twins.anchored = true
	twins.stone_lines = [
		"Two diggers back to back at the bottom of the Cut, anchored fast.",
		"Amethyst: \"They dug toward each other for luck. The curse liked the shape of it.\"",
	]
	var vess := _make_npc(Vector2(1060, 452), "runner", "Vess")
	if vess:
		vess.stone_lines = [
			"Vess the powder-girl, running the rim with a fuse that never burned down.",
			"Amethyst: \"The Waystone's close. For once, an easy one.\"",
		]
		vess.soft_lines = ["Vess whispers: \"...cut the fuse... cut it...\""]
	Util.crate(self, Vector2(350, 440), Vector2(40, 40), 14.0, Color(0.55, 0.5, 0.42))
	Util.label(self, Vector2(320, 400), "quarry block")
	_make_waystone(Vector2(1180, 480))
	_make_door(Rect2(0, 400, 24, 80), "", 17, "east")
	_make_door(Rect2(1256, 400, 24, 80), "switchback →", 18, "bottom")
	_spawn_player({"default": Vector2(50, 460), "west": Vector2(50, 460),
			"east": Vector2(1130, 460)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	player.dash_enabled = G.seen.get("chisel_dash", false)


# ------------------------------------------ room 16: scaffold heights
func _build_scaffold_heights() -> void:
	G.say("— The Quarry: Scaffold Heights —")
	# the high route: planks climbing east to the Switchback's upper door
	Util.block(self, Rect2(0, 480, 1280, 240))      # quarry floor, far below
	Util.block(self, Rect2(200, 420, 90, 14))
	Util.block(self, Rect2(360, 360, 90, 14))
	Util.block(self, Rect2(520, 300, 90, 14))
	Util.block(self, Rect2(680, 240, 90, 14))
	Util.block(self, Rect2(840, 208, 440, 14))      # high gallery to the east wall
	var rigger := _make_npc(Vector2(560, 284), "kneeler", "the rigger")
	rigger.anchored = true
	rigger.stone_lines = [
		"A rigger, kneeling to splice rope forty feet up. Anchored to her perch.",
		"Amethyst: \"Don't look down. She never did.\"",
	]
	_make_chisel_mote(Vector2(400, 330))
	_make_chisel_mote(Vector2(900, 180))
	_make_door(Rect2(0, 400, 24, 80), "", 10, "east")
	_make_door(Rect2(1256, 128, 24, 80), "switchback →", 18, "top")
	_spawn_player({"default": Vector2(60, 460), "west": Vector2(60, 460),
			"east": Vector2(1180, 188)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	player.dash_enabled = G.seen.get("chisel_dash", false)


# ----------------------------------------------- room 17: the haul road
func _build_haul_road() -> void:
	G.say("— The Quarry: Haul Road —")
	# the low route: a long flat road; the Crane Yard's shaft drops in here
	Util.block(self, Rect2(0, 480, 1280, 240))
	for x in range(100, 1200, 200):
		var rail := Util.make_sprite(Vector2(120, 6), Color(0.4, 0.35, 0.28))
		rail.position = Vector2(x, 474)
		add_child(rail)
	Util.crate(self, Vector2(400, 460))
	Util.crate(self, Vector2(432, 460))
	Util.label(self, Vector2(600, 380), "shaft overhead")
	var rutta := _make_npc(Vector2(760, 452), "runner", "Rutta")
	if rutta:
		rutta.stone_lines = [
			"Rutta the ox-girl, hauling a cart that is no longer behind her.",
			"Amethyst: \"Strongest back in the quarry, and I still can't carry her.\"",
		]
		rutta.soft_lines = ["Rutta murmurs: \"...the load's light... too light...\""]
	_make_waystone(Vector2(940, 480))
	_make_chisel_mote(Vector2(1100, 440))
	_make_door(Rect2(0, 400, 24, 80), "", 9, "lower")
	_make_door(Rect2(1256, 400, 24, 80), "the cut →", 11, "west")
	_spawn_player({"default": Vector2(60, 460), "west": Vector2(60, 460),
			"east": Vector2(1180, 460), "hatch": Vector2(640, 460)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	player.dash_enabled = G.seen.get("chisel_dash", false)


# ---------------------------------------------- room 18: the switchback
func _build_switchback() -> void:
	G.say("— The Quarry: The Switchback —")
	# junction: the high and low routes meet; the Depths continue east
	Util.block(self, Rect2(0, 480, 1280, 240))      # ground
	Util.block(self, Rect2(0, 208, 300, 16))        # upper ledge, west
	Util.block(self, Rect2(340, 420, 80, 14))       # zigzag up
	Util.block(self, Rect2(200, 360, 80, 14))
	Util.block(self, Rect2(340, 300, 80, 14))
	Util.block(self, Rect2(200, 240, 80, 14))
	_make_chisel_mote(Vector2(150, 180))
	_make_door(Rect2(1256, 400, 24, 80), "wisp gallery →", 20, "west")
	_make_door(Rect2(0, 400, 24, 80), "", 11, "east")
	_make_door(Rect2(0, 128, 24, 80), "scaffold ↑", 16, "east")
	_spawn_player({"default": Vector2(60, 460), "bottom": Vector2(60, 460),
			"top": Vector2(60, 188), "east": Vector2(1180, 460)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	player.dash_enabled = G.seen.get("chisel_dash", false)


# --------------------------------------------- room 19: foredame's dig
func _build_foredame_dig() -> void:
	G.say("— The Quarry: Foredame's Dig —")
	Util.block(self, Rect2(0, 480, 1280, 240))
	_make_door(Rect2(0, 400, 24, 80), "", 21, "east")
	if G.seen.get("foredame_down", false):
		# the dig, collapsed and quiet
		for x in [420, 660, 900]:
			var rubble := Util.make_sprite(Vector2(70, 26), Color(0.4, 0.37, 0.34))
			rubble.position = Vector2(x, 467)
			add_child(rubble)
		_make_entrance(Rect2(1150, 400, 48, 80), "Quarry Sanctuary (F)",
				func() -> void: _goto_room(22))
		_spawn_player({"default": Vector2(60, 460), "west": Vector2(60, 460),
				"east": Vector2(1080, 460)})
		player.petrify_enabled = false
		player.push_enabled = G.seen.get("masons_grip", false)
		player.dash_enabled = G.seen.get("chisel_dash", false)
		return
	var boss := Foredame.new()
	boss.position = Vector2(640, 480)
	add_child(boss)
	for x in [400.0, 640.0, 880.0]:
		var pillar := Util.block(self, Rect2(x - 20, 420, 40, 60), Color(0.55, 0.5, 0.45))
		Util.label(pillar, Vector2(-30, -46), "cracked pillar")
		boss.add_pillar(pillar, x)
	boss.defeated.connect(func() -> void:
		G.seen["foredame_down"] = true
		G.save_state(room)
		_skit_once("q_boss_down", [
			{"who": "narrator", "text": "The scaffolding shrieks. The half-carved "
					+ "colossus folds into her own excavation, fist still open."},
			{"who": "ame", "text": "You were somebody's work. Somebody stood where I'm "
					+ "standing and carved your face. Rest now."},
			{"who": "narrator", "text": "In the settling dust, the way to the Quarry "
					+ "Sanctuary stands clear."},
		])
		_make_entrance(Rect2(1150, 400, 48, 80), "Quarry Sanctuary (F)",
				func() -> void: _goto_room(22))
	)
	_spawn_player({"default": Vector2(60, 460), "west": Vector2(60, 460),
			"east": Vector2(1080, 460)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	player.dash_enabled = G.seen.get("chisel_dash", false)
	_skit_once("q_boss_intro", [
		{"who": "narrator", "text": "The dig is a cathedral of cut stone. At its head, "
				+ "a colossus no one finished — and the curse got into what was "
				+ "carved of her."},
		{"who": "ame", "text": "She swings like a hammer. And a hammer doesn't care "
				+ "what it hits — not even its own scaffolding."},
	])


# --------------------------------------------- room 20: wisp gallery
func _build_wisp_gallery() -> void:
	G.say("— The Quarry: Wisp Gallery —")
	# resource pressure: wisps chase the amulet's glow and sip Chisel Light.
	# Stone-Amethyst carries no light; a Chisel Dash bursts them.
	# the sealed powder store lies UNDER the gallery floor behind a cracked
	# patch (a wall-vault blocked the hall entirely — this stays passable)
	Util.block(self, Rect2(0, 480, 900, 240))
	_make_cracked(Rect2(900, 480, 60, 16))
	Util.block(self, Rect2(900, 544, 60, 176))      # store floor
	Util.block(self, Rect2(960, 480, 320, 240))
	Util.label(self, Vector2(890, 448), "sealed store")
	_make_chisel_mote(Vector2(915, 528))
	_make_chisel_mote(Vector2(945, 528))
	for pos in [Vector2(400, 380), Vector2(700, 320), Vector2(1000, 260)]:
		var wisp := Wisp.new()
		wisp.position = pos
		add_child(wisp)
	_make_chisel_mote(Vector2(500, 440))
	_make_chisel_mote(Vector2(800, 440))
	_make_door(Rect2(0, 400, 24, 80), "", 18, "east")
	_make_door(Rect2(1256, 400, 24, 80), "colossus shelf →", 21, "west")
	_spawn_player({"default": Vector2(60, 460), "west": Vector2(60, 460),
			"east": Vector2(1180, 460)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	player.dash_enabled = G.seen.get("chisel_dash", false)


# ------------------------------------------- room 21: colossus shelf
func _build_colossus_shelf() -> void:
	G.say("— The Quarry: Colossus Shelf —")
	# half-carved colossus blocks; push one against the shelf face to climb.
	Util.block(self, Rect2(0, 480, 1280, 240))
	Util.block(self, Rect2(900, 384, 380, 96))      # the shelf
	for head in [Vector2(460, 410), Vector2(1120, 320)]:
		var colossus := Util.make_sprite(Vector2(90, 130), Color(0.5, 0.46, 0.42), true)
		Util.set_petrify(colossus, 1.0)
		colossus.position = head
		add_child(colossus)
	# the blocks start in the escort corridor: clear her path or climb with
	# them — the same stones serve both, and the testimony walk is earned
	Util.crate(self, Vector2(400, 440), Vector2(40, 40), 14.0, Color(0.55, 0.5, 0.42))
	Util.crate(self, Vector2(500, 440), Vector2(40, 40), 14.0, Color(0.55, 0.5, 0.42))
	_make_waystone(Vector2(150, 480))
	var sableth := _make_npc(Vector2(820, 452), "runner", "Sableth")
	if sableth:
		sableth.char_id = "sableth"
		sableth.stone_lines = [
			"Sableth the forewoman, striding the shelf-foot mid-order, iron "
					+ "whistle half-raised.",
			"Amethyst: \"The Waystone is the whole shelf away — and her road "
					+ "is blocked with her own stone.\"",
		]
		sableth.soft_lines = ["Sableth murmurs: \"...off the shelf... whistle them OFF...\""]
		sableth.was_rescued.connect(func(_npc: StatueNPC) -> void:
			G.truths += 1
			_skit_once("witness_sableth", [
				{"who": "sableth", "text": "You want truth for that ledger, mason? "
						+ "Here. We never carved the Foredame's face."},
				{"who": "sableth", "text": "She wore it out of the rock herself. Nights, "
						+ "we heard her chisel. Tap. Tap. Tap."},
				{"who": "narrator", "text": "Witness testimony recorded (1 of 6). "
						+ "Truth is a kind of light."},
			])
		)
	_make_chisel_mote(Vector2(1000, 354))
	_make_door(Rect2(0, 400, 24, 80), "", 20, "east")
	_make_door(Rect2(1256, 304, 24, 80), "the dig →", 19, "west")
	_spawn_player({"default": Vector2(60, 460), "west": Vector2(60, 460),
			"east": Vector2(1180, 364)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	player.dash_enabled = G.seen.get("chisel_dash", false)


# ------------------------------------------ room 22: quarry sanctuary
func _build_quarry_sanctuary() -> void:
	G.say("— The Quarry Sanctuary —")
	Util.block(self, Rect2(0, 480, 1280, 240))
	for x in [260, 460, 860, 1060]:
		var col := Util.make_sprite(Vector2(30, 240), Color(0.45, 0.4, 0.34))
		col.position = Vector2(x, 360)
		add_child(col)
	var lit: bool = G.seen.get("chisel_dash", false)
	for x in [540, 780]:
		var brazier := Util.make_sprite(Vector2(20, 30),
				Color(1.0, 0.7, 0.3) if lit else Color(0.3, 0.28, 0.34))
		brazier.position = Vector2(x, 425)
		add_child(brazier)
	Util.block(self, Rect2(620, 440, 80, 40), Color(0.6, 0.55, 0.5))  # the altar
	var altar := Util.area(self, Rect2(600, 400, 120, 40), Color(0, 0, 0, 0))
	altar.body_entered.connect(func(body: Node) -> void:
		if body is Player and not G.seen.get("chisel_dash", false):
			G.seen["chisel_dash"] = true
			(body as Player).dash_enabled = true
			G.save_state(room)
			_skit_once("q_relight", [
				{"who": "narrator", "text": "Amethyst lays the amulet and Ida's chisel "
						+ "on the altar. The Sanctuary reads the chisel's memory: "
						+ "every strike Ida ever made."},
				{"who": "narrator", "text": "CHISEL DASH — Shift: a mason's strike with "
						+ "her whole body behind it. Cracked stone shatters."},
				{"who": "ame", "text": "The cracked street floor. The cellar. "
						+ "Ida — I can finally get into your workshop."},
			])
	)
	_make_door(Rect2(0, 400, 24, 80), "", 19, "east")
	_spawn_player({"default": Vector2(100, 460)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	player.dash_enabled = G.seen.get("chisel_dash", false)


# ------------------------------------------ room 23: drowned vestibule
func _build_drowned_vestibule() -> void:
	G.say("— The Sunken Baths: Drowned Vestibule —")
	Util.block(self, Rect2(0, 300, 220, 16))        # entry ledge from the stair
	Util.block(self, Rect2(260, 420, 40, 12))       # steps back up
	Util.block(self, Rect2(180, 364, 40, 12))
	Util.block(self, Rect2(0, 480, 1280, 240))      # hall floor
	Util.block(self, Rect2(400, 560, 300, 160))     # pool basin
	_make_water(Rect2(400, 500, 300, 60))
	Util.block(self, Rect2(400, 520, 24, 40))       # in-pool escape shelves
	Util.block(self, Rect2(676, 520, 24, 40))
	_make_chisel_mote(Vector2(550, 532))            # drowned light
	for x in [340, 760, 1060]:
		var mosaic := Util.make_sprite(Vector2(120, 8), Color(0.3, 0.5, 0.5))
		mosaic.position = Vector2(x, 477)
		add_child(mosaic)
	var nerissa := _make_npc(Vector2(900, 464), "kneeler", "Nerissa")
	nerissa.anchored = true
	nerissa.char_id = "nerissa"
	nerissa.stone_lines = [
		"Nerissa the doorkeeper, kneeling at her post with the bath-keys fanned "
				+ "out like a hand of cards. Anchored.",
		"Amethyst: \"Still on duty. Of course you are.\"",
	]
	_make_door(Rect2(0, 220, 24, 80), "square ↑", 6, "stair")
	_make_door(Rect2(1256, 400, 24, 80), "the long soak →", 24, "west")
	_spawn_player({"default": Vector2(60, 280), "top": Vector2(60, 280),
			"east": Vector2(1180, 460)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	player.dash_enabled = G.seen.get("chisel_dash", false)
	_skit_once("b_enter", [
		{"who": "narrator", "text": "The Sunken Baths. Verdigris and black water, "
				+ "candles drowned in their sconces. Somewhere below, faint and "
				+ "wet, something is singing."},
		{"who": "ame", "text": "The softened follow my light. Whatever that is — "
				+ "they'd follow it too. Careful, now."},
	])


# ---------------------------------------------- room 24: the long soak
func _build_long_soak() -> void:
	G.say("— The Sunken Baths: The Long Soak —")
	# the valve choice: one Waystone, two kneelers — rescue one, the other
	# opens the sluice. The siren's song only takes the *softened*.
	Util.block(self, Rect2(0, 480, 300, 240))       # west ground
	Util.block(self, Rect2(300, 600, 600, 120))     # pool basin
	_make_water(Rect2(300, 500, 600, 100))
	Util.block(self, Rect2(300, 520, 24, 40))       # west in-pool shelf
	Util.block(self, Rect2(852, 496, 24, 24))       # east shelf at the waterline
	Util.block(self, Rect2(900, 480, 380, 240))     # east ground
	_make_plate_and_door(Vector2(350, 600), Vector2(1000, 480))
	_make_waystone(Vector2(150, 480))
	var ottilie := _make_npc(Vector2(220, 464), "kneeler", "Ottilie")
	if ottilie:
		ottilie.char_id = "ottilie"
		ottilie.stone_lines = [
			"Ottilie the bath-mistress, kneeling to test water that will never "
					+ "warm again.",
			"Amethyst: \"She ran this whole house. She'd know what happened here.\"",
		]
		ottilie.soft_lines = ["Ottilie murmurs: \"...the water knew... it knew first...\""]
		ottilie.was_rescued.connect(func(_npc: StatueNPC) -> void:
			G.truths += 1
			_skit_once("witness_ottilie", [
				{"who": "ottilie", "text": "Truth? The water knew first. The fish "
						+ "turned to pebbles a full day before the wave."},
				{"who": "ottilie", "text": "We sent word to the Sanctuary. The "
						+ "Sanctuary sent back one line: *pray, and do not look "
						+ "at the water.*"},
				{"who": "narrator", "text": "Witness testimony recorded (2 of 6)."},
			])
		)
	var casta := _make_npc(Vector2(270, 464), "kneeler", "Casta")
	if casta:
		casta.stone_lines = [
			"Casta the towel-girl, kneeling at the pool lip, forever about to dive.",
			"Amethyst: \"The sluice-plate is right under her. The stone won't "
					+ "hear the song — only the softened do.\"",
		]
	var siren := Siren.new()
	siren.position = Vector2(700, 470)
	add_child(siren)
	_make_door(Rect2(0, 400, 24, 80), "", 23, "east")
	_make_door(Rect2(1256, 400, 24, 80), "cisterns →", 25, "west")
	_spawn_player({"default": Vector2(60, 460), "west": Vector2(60, 460),
			"east": Vector2(1180, 460)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	player.dash_enabled = G.seen.get("chisel_dash", false)


# ------------------------------------------------ room 25: the cisterns
func _build_cisterns() -> void:
	G.say("— The Sunken Baths: The Cisterns —")
	# the drowned Waystone: Brigid must cross the basin floor while Amethyst
	# hops the maintenance planks above — and the siren mid-basin will steal
	# her unless a stone is dropped on the song first
	Util.block(self, Rect2(0, 480, 200, 240))       # west ground
	Util.block(self, Rect2(200, 620, 800, 100))     # basin floor
	_make_water(Rect2(200, 496, 800, 124))
	Util.block(self, Rect2(200, 496, 24, 40))       # in-basin escape shelves
	Util.block(self, Rect2(976, 496, 24, 40))
	Util.block(self, Rect2(1000, 480, 280, 240))    # east ground
	Util.block(self, Rect2(260, 420, 60, 14))       # maintenance planks
	Util.block(self, Rect2(420, 380, 60, 14))
	Util.block(self, Rect2(580, 340, 60, 14))
	Util.block(self, Rect2(740, 380, 60, 14))
	Util.block(self, Rect2(900, 440, 60, 14))
	Util.crate(self, Vector2(600, 326), Vector2(40, 40), 14.0, Color(0.55, 0.5, 0.42))
	Util.label(self, Vector2(560, 292), "loose block")
	var siren := Siren.new()
	siren.position = Vector2(640, 560)
	add_child(siren)
	var brigid := _make_npc(Vector2(120, 452), "runner", "Brigid")
	if brigid:
		brigid.stone_lines = [
			"Brigid the water-carrier, frozen mid-stride with yokes for two pails "
					+ "that rolled away weeks ago.",
			"Amethyst: \"The old Waystone at the basin's bottom still glows. "
					+ "She could walk the floor to it — if nothing sings her aside.\"",
		]
		brigid.soft_lines = ["Brigid murmurs: \"...heavy... why is the water heavy...\""]
	_make_waystone(Vector2(940, 600))
	_make_door(Rect2(0, 400, 24, 80), "", 24, "east")
	_make_door(Rect2(1256, 400, 24, 80), "deep sanctuary →", 26, "west")
	_spawn_player({"default": Vector2(60, 460), "west": Vector2(60, 460),
			"east": Vector2(1180, 460)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	player.dash_enabled = G.seen.get("chisel_dash", false)


# ---------------------------------------- room 26: sanctuary of the deep
func _build_deep_sanctuary() -> void:
	G.say("— The Sanctuary of the Deep —")
	Util.block(self, Rect2(0, 480, 1280, 240))
	for x in [260, 460, 860, 1060]:
		var col := Util.make_sprite(Vector2(30, 240), Color(0.32, 0.45, 0.45))
		col.position = Vector2(x, 360)
		add_child(col)
	var lit: bool = G.seen.get("soften2", false)
	for x in [540, 780]:
		var brazier := Util.make_sprite(Vector2(20, 30),
				Color(0.5, 0.95, 0.85) if lit else Color(0.3, 0.28, 0.34))
		brazier.position = Vector2(x, 425)
		add_child(brazier)
	Util.block(self, Rect2(620, 440, 80, 40), Color(0.45, 0.6, 0.6))  # the altar
	var altar := Util.area(self, Rect2(600, 400, 120, 40), Color(0, 0, 0, 0))
	altar.body_entered.connect(func(body: Node) -> void:
		if body is Player and not G.seen.get("soften2", false):
			G.seen["soften2"] = true
			G.save_state(room)
			_skit_once("b_soften2", [
				{"who": "narrator", "text": "A drowned mini-sanctuary, older than the "
						+ "baths above it. The altar takes the amulet's measure — "
						+ "and gives back more than it took."},
				{"who": "narrator", "text": "SOFTEN II — half a minute of almost-back. "
						+ "The window grows to 25 seconds; each person's grace "
						+ "deepens to 40."},
				{"who": "ame", "text": "Half a minute. Long enough to walk beside "
						+ "someone. Long enough to almost forget what happens at "
						+ "the end of it."},
			])
	)
	var maud := _make_npc(Vector2(900, 452), "runner", "Maud")
	if maud:
		maud.stone_lines = [
			"Maud the stoker, running with an armful of kindling for boilers "
					+ "that went cold mid-breath.",
			"Amethyst: \"A long walk to the Waystone. With half a minute — easy.\"",
		]
		maud.soft_lines = ["Maud murmurs: \"...the fires... who's minding the fires...\""]
	_make_waystone(Vector2(1100, 480))
	# the boiler gate: Mother Lye beyond (boss, next slice)
	Util.block(self, Rect2(1240, 360, 40, 120), Color(0.3, 0.35, 0.35))
	var gate := Util.area(self, Rect2(1216, 400, 24, 80), Color(0, 0, 0, 0))
	gate.body_entered.connect(func(body: Node) -> void:
		if body is Player and not G.seen.get("b_gate", false):
			G.seen["b_gate"] = true
			G.say("The boiler gate. Beyond it, Mother Lye's choir hums through "
					+ "the wall. (Boss — next slice.)")
	)
	_make_door(Rect2(0, 400, 24, 80), "", 25, "east")
	_spawn_player({"default": Vector2(60, 460), "west": Vector2(60, 460)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	player.dash_enabled = G.seen.get("chisel_dash", false)


# ----------------------------------- room 12: sample — sunken baths idea
func _build_sample_baths() -> void:
	G.say("— Sample: Sunken Baths (statue as sunken valve) —")
	Util.block(self, Rect2(0, 480, 400, 240))       # west ground
	Util.block(self, Rect2(400, 620, 400, 100))     # pool floor
	Util.block(self, Rect2(800, 480, 480, 240))     # east ground
	_make_water(Rect2(400, 500, 400, 120))
	Util.block(self, Rect2(400, 556, 26, 12))       # escape steps, west wall
	Util.block(self, Rect2(426, 510, 26, 12))
	# the valve: a plate on the pool floor, the door on dry land
	_make_plate_and_door(Vector2(460, 620), Vector2(200, 480))
	_make_chisel_mote(Vector2(120, 440))
	var attendant := _make_npc(Vector2(330, 464), "kneeler", "the attendant", false)
	attendant.stone_lines = [
		"A bath attendant, kneeling with towels that turned to slate.",
		"Amethyst: \"Stone sinks. The sluice-plate is right below the lip...\"",
	]
	_spawn_player({"default": Vector2(60, 460)})
	player.push_enabled = true
	player.dash_enabled = true


# ------------------------------- room 13: sample — gorgon gardens idea
func _build_sample_gardens() -> void:
	G.say("— Sample: Gorgon Gardens (the gaze; statues are cover) —")
	Util.block(self, Rect2(0, 480, 1280, 240))
	var gaze := GazeEmitter.new()
	gaze.position = Vector2(1100, 450)
	add_child(gaze)
	var cover1 := _make_npc(Vector2(400, 464), "kneeler", "a gardener", false)
	cover1.stone_lines = ["A gardener, low over her shears. Low enough to hide behind."]
	var cover2 := _make_npc(Vector2(650, 452), "runner", "a lady-in-waiting", false)
	cover2.stone_lines = [
		"A lady-in-waiting, tall and straight. A walking wall, if walked.",
	]
	_make_chisel_mote(Vector2(1220, 440))
	Util.label(self, Vector2(1180, 380), "reach the mote")
	_spawn_player({"default": Vector2(60, 460)})
	player.push_enabled = true
	player.dash_enabled = true


# ---------------------------- room 14: sample — crystal undercroft idea
func _build_sample_undercroft() -> void:
	G.say("— Sample: Crystal Undercroft (dark; light the braziers) —")
	var dark := CanvasModulate.new()
	dark.color = Color(0.14, 0.12, 0.2)
	add_child(dark)
	Util.block(self, Rect2(0, 480, 1280, 240))
	Util.block(self, Rect2(300, 420, 80, 16))
	Util.block(self, Rect2(480, 360, 80, 16))
	Util.block(self, Rect2(660, 300, 80, 16))
	Util.block(self, Rect2(840, 240, 80, 16))
	_make_brazier(Vector2(340, 404))
	_make_brazier(Vector2(700, 284))
	_make_brazier(Vector2(880, 224))
	_make_chisel_mote(Vector2(1100, 440))
	_spawn_player({"default": Vector2(60, 460)})
	player.add_child(_make_lamp(0.9))
	player.push_enabled = true
	player.dash_enabled = true


func _make_lamp(energy: float) -> PointLight2D:
	var lamp := PointLight2D.new()
	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 1.0)
	tex.width = 256
	tex.height = 256
	lamp.texture = tex
	lamp.energy = energy
	lamp.texture_scale = 1.6
	return lamp


func _make_brazier(pos: Vector2) -> void:
	var bowl := Util.make_sprite(Vector2(18, 24), Color(0.3, 0.28, 0.34))
	bowl.position = pos
	add_child(bowl)
	var spark := Util.area(self, Rect2(pos.x - 14, pos.y - 26, 28, 40), Color(0, 0, 0, 0))
	spark.body_entered.connect(func(body: Node) -> void:
		if body is Player:
			bowl.modulate = Color(1.0, 0.7, 0.3)
			var light := _make_lamp(1.4)
			light.position = pos
			add_child(light)
			spark.queue_free()
	)


# ------------------------------- room 15: sample — marble palace idea
func _build_sample_palace() -> void:
	G.say("— Sample: Marble Palace (the warden re-seals the softened) —")
	Util.block(self, Rect2(0, 480, 1280, 240))
	for x in [200, 500, 800, 1100]:
		var col := Util.make_sprite(Vector2(26, 220), Color(0.7, 0.68, 0.72))
		col.position = Vector2(x, 370)
		add_child(col)
	var warden := Warden.new()
	warden.position = Vector2(700, 450)
	warden.patrol_left = 520.0
	warden.patrol_right = 920.0
	add_child(warden)
	var exhibit := _make_npc(Vector2(350, 452), "runner", "the exhibit", false)
	exhibit.stone_lines = [
		"A brass placard at her feet: 'GIRL, RUNNING. Do not touch.'",
		"Amethyst: \"She has a name. I'll ask it when she's free.\"",
	]
	exhibit.soft_lines = ["She whispers: \"...is the tall one looking?...\""]
	_make_waystone(Vector2(1180, 480), false)
	_spawn_player({"default": Vector2(60, 460)})
	player.push_enabled = true
	player.dash_enabled = true
