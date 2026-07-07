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


func _make_waystone(pos: Vector2) -> Area2D:
	var ws := Util.area(self, Rect2(pos.x - 24, pos.y - 64, 48, 64), Color(0.4, 0.8, 0.9, 0.5))
	Util.label(ws, Vector2(-32, -50), "Waystone")
	ws.body_entered.connect(_on_waystone_body.bind(ws))
	return ws


func _on_waystone_body(body: Node, _ws: Area2D) -> void:
	if body is StatueNPC and body.soft:
		G.rescued += 1
		G.say("%s reaches the Waystone — she is safe in the Village now. (Rescued: %d)"
				% [body.npc_name, G.rescued])
		body.was_rescued.emit(body)
		body.queue_free()


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
	var floor_body := Util.block(self, rect, Color(0.55, 0.5, 0.45))
	Util.label(floor_body, Vector2(-40, -28), "cracked")
	var sensor := Util.area(self,
			Rect2(rect.position.x, rect.position.y - 10, rect.size.x, 12),
			Color(0, 0, 0, 0))
	sensor.body_entered.connect(func(body: Node) -> void:
		if body is RigidBody2D and body.mass >= 10.0 and body.linear_velocity.y > 300.0:
			G.say("The cracked floor shatters under the stone's weight!")
			floor_body.queue_free()
			sensor.queue_free()
	)


func _make_plate_and_door(plate_pos: Vector2, door_pos: Vector2) -> void:
	_plate_door = Util.block(self, Rect2(door_pos.x, door_pos.y - 96, 24, 96), Color(0.5, 0.4, 0.2))
	_door_closed_pos = _plate_door.position
	Util.label(_plate_door, Vector2(-20, -64), "door")
	var plate := Util.area(self,
			Rect2(plate_pos.x - 32, plate_pos.y - 8, 64, 8), Color(0.7, 0.7, 0.75))
	Util.label(plate, Vector2(-60, -24), "plate (needs weight)")
	plate.set_meta("is_plate", true)


func _physics_process(_delta: float) -> void:
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
		tw.tween_property(_plate_door, "position:y", _door_closed_pos.y - 80.0, 0.4)
	elif not pressed and _door_open:
		_door_open = false
		var tw := create_tween()
		tw.tween_property(_plate_door, "position:y", _door_closed_pos.y, 0.4)


func _make_npc(pos: Vector2, npc_kind: String, npc_name: String) -> StatueNPC:
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
	var odessa := _make_npc(Vector2(940, 460), "kneeler", "Odessa")
	odessa.stone_lines = [
		"Odessa knelt to pick up her daughter's doll when the wave came.",
		"Amethyst: \"I'll come back for you, Odessa. I promise.\"",
	]
	odessa.soft_lines = [
		"Odessa murmurs: \"...Amethyst? The light... it's warm here...\"",
	]
	Util.label(self, Vector2(1010, 380), "stone sinks, flesh floats —\npush something in to cross")
	_make_chime(Vector2(880, 480))
	_make_waystone(Vector2(1220, 480))
	_spawn_player({"default": Vector2(250, 440)})
	player.push_enabled = true


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
	petra.stone_lines = [
		"Petra the Mason, kneeling at her whetstone. The wave took her mid-sharpen.",
		"Amethyst: \"Master Petra taught me to read the grain of marble. Her stone is... deep.\"",
		"Amethyst: \"I can't reach her. Not yet. Not with this little light.\"",
	]
	var lina := _make_npc(Vector2(600, 452), "runner", "Lina")
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
	# the amulet is a key item: taken once, forever (survives resets and saves)
	if not G.seen.get("v1_amulet_taken", false):
		var amulet := Util.area(self, Rect2(708, 440, 24, 24), Color(0.95, 0.85, 0.4))
		Util.label(amulet, Vector2(-56, -30), "the chisel-amulet")
		amulet.body_entered.connect(func(body: Node) -> void:
			if body is Player and not body.soften_enabled:
				G.seen["v1_amulet_taken"] = true
				body.soften_enabled = true
				amulet.queue_free()
				_skit_once("v1_amulet", [
					{"who": "narrator", "text": "Master Ida's chisel-amulet hums against "
							+ "Amethyst's palm, warm as a kept coal."},
					{"who": "ame", "text": "It's warm. Like her hands were."},
					{"who": "narrator", "text": "Near a statue, press E: the amulet can soften "
							+ "stone — for a few breaths, no more. The softened dream, and "
							+ "follow its light. F lets you look closer, or speak."},
				])
		)
	_make_door(Rect2(1220, 320, 40, 80), "well yard →", 4, "west")
	_spawn_player({"default": Vector2(80, 440), "east": Vector2(1160, 380)})
	player.soften_enabled = G.seen.get("v1_amulet_taken", false)
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)
	_skit_once("v1_open", [
		{"who": "ame", "text": "Dust. Why is everything white— why is everything so quiet?"},
		{"who": "narrator", "text": "The morning the wave came, Amethyst was underground, "
				+ "fetching marble for a headstone."},
		{"who": "ame", "text": "Lina? LINA— ...oh. Oh, no. No, no, no."},
		{"who": "narrator", "text": "Everyone. Everyone is stone."},
	])


# ------------------------------------------------------ room 4: well yard
func _build_well_yard() -> void:
	G.say("— The Well Yard —")
	Util.block(self, Rect2(0, 480, 700, 240))
	Util.block(self, Rect2(840, 480, 440, 240))
	Util.block(self, Rect2(686, 496, 14, 224))     # pit wall left
	Util.block(self, Rect2(840, 496, 14, 224))     # pit wall right
	Util.block(self, Rect2(700, 590, 140, 130))    # pit floor
	Util.label(self, Vector2(730, 560), "stuck? R")
	_make_waystone(Vector2(140, 480))
	var marla := _make_npc(Vector2(380, 464), "kneeler", "Marla")
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
			{"who": "narrator", "text": "First rescue. The ledger's first name, crossed out."},
		])
	)
	var sena := _make_npc(Vector2(560, 452), "runner", "Sena")
	sena.stone_lines = [
		"Sena, the well-keeper's daughter, frozen sprinting for the yard gate.",
		"Amethyst: \"The pit's too wide to jump, too deep to climb. But if she follows me down...\"",
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
	_make_door(Rect2(0, 400, 20, 80), "", 3, "east")
	_make_door(Rect2(1240, 400, 40, 80), "steps →", 5, "west")
	_spawn_player({"default": Vector2(80, 440), "west": Vector2(60, 440),
			"east": Vector2(1180, 440)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)


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
	aldith.stone_lines = [
		"Sister Aldith of the Sanctuary, kneeling in prayer atop the stair pillar.",
		"Amethyst: \"Anchored, like Master Petra. The curse holds the pious hardest.\"",
		"Amethyst: \"...I'm going to step on a nun. Forgive me twice, Sister.\"",
	]
	# Odile — not needed for the climb; she is only there to be saved (or not)
	var odile := _make_npc(Vector2(550, 452), "runner", "Odile")
	odile.stone_lines = [
		"Odile the bell-ringer, frozen sprinting from the chapel, hands over her ears.",
		"Amethyst: \"The Waystone is a long, long walk from here. Her grace might just cover it.\"",
	]
	odile.soft_lines = ["Odile whispers: \"...the bells... did the bells stop?...\""]
	odile.was_rescued.connect(func(_npc: StatueNPC) -> void:
		_skit_once("v3_rescue", [
			{"who": "ame", "text": "Every step of that walk, I was sure the light would "
					+ "run out. Go home, Odile. Ring nothing."},
		])
	)
	# the Sanctuary wakes for the warmth of the returned: 2 rescues open it
	var lit := G.seen.get("masons_grip", false)
	var door_col := Color(0.55, 0.5, 0.3) if lit else Color(0.3, 0.25, 0.4)
	var door := Util.area(self, Rect2(1200, 204, 48, 80), door_col)
	Util.label(door, Vector2(-52, -30), "Sanctuary" if lit else "Sanctuary (dark)")
	door.body_entered.connect(func(body: Node) -> void:
		if not body is Player:
			return
		if G.rescued >= 2 or G.seen.get("masons_grip", false):
			_goto_room(8)
			return
		_skit_once("v3_door", [
			{"who": "narrator", "text": "The Sanctuary door is cold. Behind it, "
					+ "something vast is holding its breath."},
			{"who": "ame", "text": "Dark. The whole Sanctuary, dark. The amulet flickers "
					+ "toward it like it wants to go home."},
			{"who": "ame", "text": "It isn't light it wants. It's warmth. The living kind."},
			{"who": "narrator", "text": "The door listens for footsteps coming home. "
					+ "Bring the rescued back to the Village."},
		])
		G.say("The door does not move. (Rescued: %d of 2 — the Sanctuary needs warmth.)"
				% G.rescued)
	)
	_make_door(Rect2(0, 400, 20, 80), "", 4, "east")
	_make_door(Rect2(1246, 184, 20, 96), "square →", 6, "ledge")
	_spawn_player({"default": Vector2(60, 440), "west": Vector2(60, 440),
			"porch": Vector2(1180, 262)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)


# ------------------------------------------------- room 6: the square (hub)
func _build_square() -> void:
	G.say("— The Square —")
	# breather room: no puzzle, no skit — the tableau speaks for itself.
	# Branches: west ledge back to the Steps, ground west door to the Bell
	# Tower, east the sealed Quarry gate, and the flooded Baths stair.
	Util.block(self, Rect2(0, 480, 900, 240))       # plaza, west of the stair
	Util.block(self, Rect2(980, 480, 300, 240))     # plaza, east of the stair
	# the drowned stair: shallow enough to stand up and climb back out
	Util.block(self, Rect2(900, 516, 80, 204))
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
	_make_door(Rect2(0, 240, 20, 80), "← steps", 5, "porch")
	# west, on the ground: the bell tower door
	_make_door(Rect2(20, 420, 24, 60), "bell tower", 7, "default")
	# east: the Quarry gate — Mason's Grip shifts the fallen arch
	if G.seen.get("masons_grip", false):
		_make_door(Rect2(1240, 400, 40, 80), "quarry →", 9, "west")
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
	_spawn_player({"default": Vector2(300, 440), "ledge": Vector2(80, 300),
			"tower": Vector2(90, 440), "gate": Vector2(1180, 440)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)


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
	_make_door(Rect2(504, 420, 20, 60), "← square", 6, "tower")
	_spawn_player({"default": Vector2(640, 440)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)


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
	var maren := _make_npc(Vector2(340, 452), "runner", "Maren")
	maren.stone_lines = [
		"Maren was running for the bridge when the wave caught her mid-stride.",
		"Amethyst: \"Forgive me, Maren. I need your shoulders.\"",
	]
	maren.soft_lines = [
		"Maren whispers: \"...keep going... I'll follow the light...\"",
	]
	_make_waystone(Vector2(100, 480))
	_make_chime(Vector2(200, 480))
	_make_goal(Rect2(1180, 400, 60, 80),
			"Chamber complete. You left her standing at the bottom of the pit. "
			+ "The ledger remembers. (Or: F1 debug-soften and walk her to the Waystone.)")
	_spawn_player({"default": Vector2(80, 440)})
	player.push_enabled = true


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
	_make_door(Rect2(0, 400, 20, 80), "", 5, "porch")
	_spawn_player({"default": Vector2(100, 440)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)


# ------------------------------------------ room 9: quarry gate terraces
func _build_quarry_terraces() -> void:
	G.say("— The Quarry: Gate Terraces —")
	# branch room: climb the slabs to the Crane Yard (top-east door) or walk
	# the lower corridor to The Cut (ground-east door)
	Util.block(self, Rect2(0, 480, 1280, 240))      # floor
	Util.block(self, Rect2(300, 432, 50, 48))       # step
	Util.block(self, Rect2(350, 384, 250, 96))      # terrace ledge
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
	brona.stone_lines = [
		"Brona the hauler, sprinting for the gate with empty hands.",
		"Amethyst: \"The Waystone hums right there. A short walk. An easy promise.\"",
	]
	brona.soft_lines = ["Brona murmurs: \"...drop the load... run...\""]
	_make_door(Rect2(0, 400, 20, 80), "", 6, "gate")
	_make_door(Rect2(1240, 128, 40, 80), "crane yard →", 10, "west")
	_make_door(Rect2(1240, 400, 40, 80), "the cut →", 11, "west")
	_spawn_player({"default": Vector2(60, 440), "west": Vector2(60, 440),
			"top": Vector2(1180, 188), "lower": Vector2(1160, 440)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)


# ----------------------------------------------- room 10: the crane yard
func _build_crane_yard() -> void:
	G.say("— The Quarry: Crane Yard —")
	# counterweight lesson: only Hetta is heavy enough for the plate
	Util.block(self, Rect2(0, 480, 1280, 240))
	_make_plate_and_door(Vector2(500, 480), Vector2(700, 480))
	Util.crate(self, Vector2(300, 440))
	var hetta := _make_npc(Vector2(600, 464), "kneeler", "Hetta")
	hetta.stone_lines = [
		"Hetta the crane-hand, kneeling to check a knot that will never slip.",
		"Amethyst: \"The Waystone is a room away. Too far for a few seconds of grace.\"",
		"Amethyst: \"But she's heavier than any crate here. Forgive me, Hetta.\"",
	]
	hetta.soft_lines = ["Hetta murmurs: \"...the counterweight... mind the counterweight...\""]
	# crane decor
	var mast := Util.make_sprite(Vector2(16, 300), Color(0.45, 0.4, 0.3))
	mast.position = Vector2(950, 330)
	add_child(mast)
	var jib := Util.make_sprite(Vector2(260, 12), Color(0.45, 0.4, 0.3))
	jib.position = Vector2(950, 190)
	add_child(jib)
	_make_chisel_mote(Vector2(900, 440))
	_make_door(Rect2(0, 400, 20, 80), "", 9, "top")
	_make_door(Rect2(1240, 400, 40, 80), "the cut ↓", 11, "east")
	_spawn_player({"default": Vector2(60, 440), "west": Vector2(60, 440),
			"east": Vector2(1180, 440)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)


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
	vess.stone_lines = [
		"Vess the powder-girl, running the rim with a fuse that never burned down.",
		"Amethyst: \"The Waystone's close. For once, an easy one.\"",
	]
	vess.soft_lines = ["Vess whispers: \"...cut the fuse... cut it...\""]
	Util.crate(self, Vector2(350, 440), Vector2(40, 40), 14.0, Color(0.55, 0.5, 0.42))
	Util.label(self, Vector2(320, 400), "quarry block")
	_make_waystone(Vector2(1190, 480))
	_make_door(Rect2(0, 400, 20, 80), "", 9, "lower")
	_make_door(Rect2(1246, 400, 34, 80), "crane yard ↑", 10, "east")
	_spawn_player({"default": Vector2(50, 440), "west": Vector2(50, 440),
			"east": Vector2(1130, 440)})
	player.petrify_enabled = false
	player.push_enabled = G.seen.get("masons_grip", false)


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
	var attendant := _make_npc(Vector2(330, 464), "kneeler", "the attendant")
	attendant.stone_lines = [
		"A bath attendant, kneeling with towels that turned to slate.",
		"Amethyst: \"Stone sinks. The sluice-plate is right below the lip...\"",
	]
	_spawn_player({"default": Vector2(60, 440)})
	player.push_enabled = true


# ------------------------------- room 13: sample — gorgon gardens idea
func _build_sample_gardens() -> void:
	G.say("— Sample: Gorgon Gardens (the gaze; statues are cover) —")
	Util.block(self, Rect2(0, 480, 1280, 240))
	var gaze := GazeEmitter.new()
	gaze.position = Vector2(1100, 450)
	add_child(gaze)
	var cover1 := _make_npc(Vector2(400, 464), "kneeler", "a gardener")
	cover1.stone_lines = ["A gardener, low over her shears. Low enough to hide behind."]
	var cover2 := _make_npc(Vector2(650, 452), "runner", "a lady-in-waiting")
	cover2.stone_lines = [
		"A lady-in-waiting, tall and straight. A walking wall, if walked.",
	]
	_make_chisel_mote(Vector2(1220, 440))
	Util.label(self, Vector2(1180, 380), "reach the mote")
	_spawn_player({"default": Vector2(60, 440)})
	player.push_enabled = true


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
	_spawn_player({"default": Vector2(60, 440)})
	player.add_child(_make_lamp(0.9))
	player.push_enabled = true


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
	var exhibit := _make_npc(Vector2(350, 452), "runner", "the exhibit")
	exhibit.stone_lines = [
		"A brass placard at her feet: 'GIRL, RUNNING. Do not touch.'",
		"Amethyst: \"She has a name. I'll ask it when she's free.\"",
	]
	exhibit.soft_lines = ["She whispers: \"...is the tall one looking?...\""]
	_make_waystone(Vector2(1180, 480))
	_spawn_player({"default": Vector2(60, 440)})
	player.push_enabled = true
