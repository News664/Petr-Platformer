class_name Level
extends Node2D
# Builds the two graybox rooms in code. Room 1: mechanics test yard.
# Room 2: the Runner puzzle chamber (expedient exit vs. Waystone rescue).

const ROOM_W := 1280.0
const ROOM_H := 720.0

var room := 1
var player: Player = null

var _plate_door: StaticBody2D = null
var _door_closed_pos := Vector2.ZERO
var _door_open := false


func _init(room_index: int) -> void:
	room = room_index


func _ready() -> void:
	_build_bounds()
	match room:
		1:
			_build_test_yard()
		2:
			_build_chamber()
		3:
			_build_village_street()
		_:
			_build_well_yard()


func _skit_once(key: String, lines: Array) -> void:
	if G.seen.get(key, false):
		return
	G.seen[key] = true
	G.dialogue.skit(lines)


func _goto_room(n: int) -> void:
	(get_parent() as Node).call_deferred("load_room", n)


func _spawn_player(pos: Vector2) -> void:
	player = Player.new()
	player.position = pos
	add_child(player)


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
		"Amé: \"I'll come back for you, Odessa. I promise.\"",
	]
	odessa.soft_lines = [
		"Odessa murmurs: \"...Amé? The light... it's warm here...\"",
	]
	Util.label(self, Vector2(1010, 380), "stone sinks, flesh floats —\npush something in to cross")
	_make_chime(Vector2(880, 480))
	_make_waystone(Vector2(1220, 480))
	_spawn_player(Vector2(250, 440))


# --------------------------------------------------- room 3: village street
func _build_village_street() -> void:
	Util.label(self, Vector2(60, 200), "PETRIFIED VILLAGE — the street where it happened")
	Util.block(self, Rect2(0, 480, 900, 240))
	Util.block(self, Rect2(900, 400, 380, 320))    # raised lane out of the square
	var petra := _make_npc(Vector2(300, 464), "kneeler", "Petra")
	petra.anchored = true
	petra.stone_lines = [
		"Petra the Mason, kneeling at her whetstone. The wave took her mid-sharpen.",
		"Amé: \"Master Petra taught me to read the grain of marble. Her stone is... deep.\"",
		"Amé: \"I can't reach her. Not yet. Not with this little light.\"",
	]
	var lina := _make_npc(Vector2(600, 452), "runner", "Lina")
	lina.stone_lines = [
		"Lina. Her best friend. Caught running toward Amé's cellar door, arm outstretched.",
		"Amé: \"You were coming to warn me. Weren't you.\"",
	]
	lina.soft_lines = ["Lina murmurs: \"...run, Amé... it's coming... run...\""]
	lina.refrozen.connect(func(_npc: StatueNPC) -> void:
		_skit_once("v1_first_refreeze", [
			{"who": "ame", "text": "I'm sorry, Lina. I need your shoulders."},
			{"who": "ame", "text": "I'll come back for you. I promise. I promise."},
		])
	)
	var amulet := Util.area(self, Rect2(708, 440, 24, 24), Color(0.95, 0.85, 0.4))
	Util.label(amulet, Vector2(-56, -30), "the chisel-amulet")
	amulet.body_entered.connect(func(body: Node) -> void:
		if body is Player and not body.soften_enabled:
			body.soften_enabled = true
			amulet.queue_free()
			_skit_once("v1_amulet", [
				{"who": "narrator", "text": "Master Ida's chisel-amulet hums against Amé's "
						+ "palm, warm as a kept coal."},
				{"who": "ame", "text": "It's warm. Like her hands were."},
				{"who": "narrator", "text": "Near a statue, press E: the amulet can soften "
						+ "stone — for a few breaths, no more. The softened dream, and "
						+ "follow its light. F lets you look closer, or speak."},
			])
	)
	var exit := Util.area(self, Rect2(1220, 320, 40, 80), Color(0.9, 0.8, 0.3, 0.4))
	Util.label(exit, Vector2(-40, -30), "to the well yard →")
	exit.body_entered.connect(func(body: Node) -> void:
		if body is Player:
			_goto_room(4)
	)
	_spawn_player(Vector2(80, 440))
	player.soften_enabled = false
	player.petrify_enabled = false
	_skit_once("v1_open", [
		{"who": "ame", "text": "Dust. Why is everything white— why is everything so quiet?"},
		{"who": "narrator", "text": "The morning the wave came, Amethyst was underground, "
				+ "fetching marble for a headstone."},
		{"who": "ame", "text": "Lina? LINA— ...oh. Oh, no. No, no, no."},
		{"who": "narrator", "text": "Everyone. Everyone is stone."},
	])


# ------------------------------------------------------ room 4: well yard
func _build_well_yard() -> void:
	Util.label(self, Vector2(60, 200), "THE WELL YARD — the first Waystone still glows")
	Util.label(self, Vector2(60, 230), "(stuck in the pit alone? press R)")
	Util.block(self, Rect2(0, 480, 700, 240))
	Util.block(self, Rect2(840, 480, 440, 240))
	Util.block(self, Rect2(686, 496, 14, 224))     # pit wall left
	Util.block(self, Rect2(840, 496, 14, 224))     # pit wall right
	Util.block(self, Rect2(700, 590, 140, 130))    # pit floor
	_make_waystone(Vector2(140, 480))
	var marla := _make_npc(Vector2(380, 464), "kneeler", "Marla")
	marla.stone_lines = [
		"Marla the baker, kneeling over a dropped basket. Flour, fossilized mid-spill.",
		"Amé: \"The Waystone still glows. If she could just reach it...\"",
	]
	marla.soft_lines = ["Marla murmurs: \"...the bread... I can smell it burning...\""]
	marla.was_rescued.connect(func(_npc: StatueNPC) -> void:
		_skit_once("v2_rescue", [
			{"who": "marla", "text": "—flour. I was carrying flour, and then... "
					+ "Amé? Why are you crying?"},
			{"who": "ame", "text": "Welcome back, Marla. Go home. Bake something. "
					+ "Don't look at the square."},
			{"who": "narrator", "text": "First rescue. The ledger's first name, crossed out."},
		])
	)
	var sena := _make_npc(Vector2(560, 452), "runner", "Sena")
	sena.stone_lines = [
		"Sena, the well-keeper's daughter, frozen sprinting for the yard gate.",
		"Amé: \"The pit's too wide to jump, too deep to climb. But if she follows me down...\"",
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
				{"who": "narrator", "text": "End of the M0 story slice. "
						+ "(Rooms: 1/2 test, 3 restarts the street.)"},
			])
	)
	_spawn_player(Vector2(80, 440))
	player.petrify_enabled = false


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
		"Amé: \"Forgive me, Maren. I need your shoulders.\"",
	]
	maren.soft_lines = [
		"Maren whispers: \"...keep going... I'll follow the light...\"",
	]
	_make_waystone(Vector2(100, 480))
	_make_chime(Vector2(200, 480))
	_make_goal(Rect2(1180, 400, 60, 80),
			"Chamber complete. You left her standing at the bottom of the pit. "
			+ "The ledger remembers. (Or: F1 debug-soften and walk her to the Waystone.)")
	_spawn_player(Vector2(80, 440))
