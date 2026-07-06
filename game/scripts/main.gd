extends Node2D
# Bootstraps input, HUD, camera, and room switching.

var current_room := 1
var level: Level = null
var camera: Camera2D = null
var map: MapOverlay = null

var _msg_label: Label = null
var _stats_label: Label = null
var _stamina_fill: ColorRect = null
var _msg_timer := 0.0
var _status_figure: Control = null
var _figure_petrify := 0.0


func _ready() -> void:
	_setup_input()
	_build_hud()
	camera = Camera2D.new()
	camera.limit_left = 0
	camera.limit_right = int(Level.ROOM_W)
	camera.limit_top = -200
	camera.limit_bottom = int(Level.ROOM_H)
	camera.position_smoothing_enabled = true
	add_child(camera)
	camera.make_current()
	var dlg := Dialogue.new()
	add_child(dlg)
	G.dialogue = dlg
	map = MapOverlay.new()
	add_child(map)
	G.message.connect(_on_message)
	load_room(3)
	G.say("A/D move · W/Space jump · E soften · F look/speak · Q petrify · "
			+ "M map · R reset room · rooms 1-5 · F1 debug-soften")


func load_room(n: int) -> void:
	if level != null:
		level.queue_free()
	current_room = n
	G.chisel = 9  # test-mode: every room (re)load restores the budget
	G.visited[n] = true
	level = Level.new(n)
	add_child(level)


func _process(delta: float) -> void:
	if level != null and level.player != null and is_instance_valid(level.player):
		var target := level.player.focus_position()
		camera.position = camera.position.lerp(target, minf(10.0 * delta, 1.0))
		_stamina_fill.size.x = 120.0 * (level.player.stamina / Player.STAMINA_MAX)
		# the little Amethyst in the corner turns to stone when you do
		var goal := 1.0 if level.player.is_stone else 0.0
		_figure_petrify = move_toward(_figure_petrify, goal, 4.0 * delta)
		Dialogue.set_figure_petrify(_status_figure, _figure_petrify)
	_stats_label.text = "Room %d · Chisel Light %d · Rescued %d%s" % [
		current_room, G.chisel, G.rescued,
		" · DEBUG SOFTEN" if G.debug_soften else "",
	]
	if _msg_timer > 0.0:
		_msg_timer -= delta
		if _msg_timer <= 0.0:
			_msg_label.text = ""


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("map"):
		if not G.dialogue.is_active():
			map.toggle(current_room)
		return
	if map.open:
		return
	if event.is_action_pressed("restart"):
		load_room(current_room)
		G.say("Room reset.")
	elif event.is_action_pressed("room_1"):
		load_room(1)
	elif event.is_action_pressed("room_2"):
		load_room(2)
	elif event.is_action_pressed("room_3"):
		load_room(3)
	elif event.is_action_pressed("room_4"):
		load_room(4)
	elif event.is_action_pressed("room_5"):
		load_room(5)
	elif event.is_action_pressed("room_6"):
		load_room(6)
	elif event.is_action_pressed("room_7"):
		load_room(7)
	elif event.is_action_pressed("debug_soften"):
		G.debug_soften = not G.debug_soften
		G.say("Debug long soften: %s" % ("ON (60 s)" if G.debug_soften else "off"))
	elif event.is_action_pressed("interact"):
		_interact()


func _interact() -> void:
	if level == null or level.player == null:
		return
	var ppos := level.player.global_position
	var best: StatueNPC = null
	var best_d := 100.0
	for npc in get_tree().get_nodes_in_group("npc"):
		var d: float = npc.global_position.distance_to(ppos)
		if d < best_d:
			best_d = d
			best = npc
	if best != null:
		best.talk()


func _on_message(text: String) -> void:
	_msg_label.text = text
	_msg_timer = 5.0


func _build_hud() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)
	_stats_label = Label.new()
	_stats_label.position = Vector2(16, 12)
	hud.add_child(_stats_label)
	var stamina_back := ColorRect.new()
	stamina_back.position = Vector2(16, 40)
	stamina_back.size = Vector2(120, 10)
	stamina_back.color = Color(0, 0, 0, 0.5)
	hud.add_child(stamina_back)
	_stamina_fill = ColorRect.new()
	_stamina_fill.position = Vector2(16, 40)
	_stamina_fill.size = Vector2(120, 10)
	_stamina_fill.color = Color(0.55, 0.3, 0.75)
	hud.add_child(_stamina_fill)
	var stamina_tag := Label.new()
	stamina_tag.position = Vector2(142, 34)
	stamina_tag.text = "stone stamina"
	stamina_tag.scale = Vector2(0.7, 0.7)
	hud.add_child(stamina_tag)
	_status_figure = Dialogue.make_figure("ame", false)
	_status_figure.scale = Vector2(0.5, 0.5)
	_status_figure.position = Vector2(6, 412)
	hud.add_child(_status_figure)
	_msg_label = Label.new()
	_msg_label.position = Vector2(80, 500)
	_msg_label.size = Vector2(864, 30)
	hud.add_child(_msg_label)


func _setup_input() -> void:
	_add_key_action("move_left", [KEY_A, KEY_LEFT])
	_add_key_action("move_right", [KEY_D, KEY_RIGHT])
	_add_key_action("jump", [KEY_W, KEY_SPACE, KEY_UP])
	_add_key_action("petrify", [KEY_Q])
	_add_key_action("soften", [KEY_E])
	_add_key_action("interact", [KEY_F])
	_add_key_action("restart", [KEY_R])
	_add_key_action("room_1", [KEY_1])
	_add_key_action("room_2", [KEY_2])
	_add_key_action("room_3", [KEY_3])
	_add_key_action("room_4", [KEY_4])
	_add_key_action("room_5", [KEY_5])
	_add_key_action("room_6", [KEY_6])
	_add_key_action("room_7", [KEY_7])
	_add_key_action("map", [KEY_M])
	_add_key_action("debug_soften", [KEY_F1])


func _add_key_action(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)
