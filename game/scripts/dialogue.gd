class_name Dialogue
extends CanvasLayer
# Skit system: pauses the game, shows a placeholder full-body figure and
# lines, advances on jump/soften/interact. Figures are layered ColorRects
# sharing one stone-shader material, so every character has a petrified
# portrait variant for free.

const CHARS := {
	"ame": {"name": "Amethyst", "skin": Color(0.95, 0.78, 0.62),
			"hair": Color(0.55, 0.3, 0.75), "dress": Color(0.42, 0.36, 0.52)},
	"lina": {"name": "Lina", "skin": Color(0.93, 0.75, 0.6),
			"hair": Color(0.85, 0.68, 0.3), "dress": Color(0.35, 0.5, 0.45)},
	"petra": {"name": "Petra the Mason", "skin": Color(0.9, 0.72, 0.58),
			"hair": Color(0.75, 0.75, 0.78), "dress": Color(0.5, 0.45, 0.4)},
	"marla": {"name": "Marla", "skin": Color(0.88, 0.7, 0.55),
			"hair": Color(0.45, 0.3, 0.2), "dress": Color(0.6, 0.5, 0.35)},
	"sena": {"name": "Sena", "skin": Color(0.92, 0.74, 0.6),
			"hair": Color(0.2, 0.2, 0.25), "dress": Color(0.55, 0.35, 0.4)},
	"narrator": {},
}

var _queue: Array = []
var _active := false
var _panel: ColorRect = null
var _name_label: Label = null
var _text_label: Label = null
var _hint_label: Label = null
var _figure_slot: Control = null


static func make_figure(who: String, petrified: bool) -> Control:
	# ~120x240 placeholder full-body figure; meta "mat" carries the shader
	var c: Dictionary = CHARS.get(who, {})
	var root := Control.new()
	root.custom_minimum_size = Vector2(120, 240)
	if c.is_empty():
		return root
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/stone.gdshader")
	mat.set_shader_parameter("petrify", 1.0 if petrified else 0.0)
	root.set_meta("mat", mat)
	var parts: Array = [
		[Rect2(30, 40, 14, 150), c.hair],   # long hair, back
		[Rect2(32, 90, 56, 130), c.dress],  # dress
		[Rect2(42, 40, 36, 36), c.skin],    # head
		[Rect2(36, 28, 48, 26), c.hair],    # hair, top
		[Rect2(44, 220, 12, 20), c.skin],   # feet
		[Rect2(64, 220, 12, 20), c.skin],
	]
	for p in parts:
		var r := ColorRect.new()
		r.position = (p[0] as Rect2).position
		r.size = (p[0] as Rect2).size
		r.color = p[1]
		r.material = mat
		root.add_child(r)
	return root


static func set_figure_petrify(figure: Control, value: float) -> void:
	if figure.has_meta("mat"):
		(figure.get_meta("mat") as ShaderMaterial).set_shader_parameter("petrify", value)


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel = ColorRect.new()
	_panel.color = Color(0.08, 0.07, 0.12, 0.92)
	_panel.position = Vector2(0, 380)
	_panel.size = Vector2(960, 160)
	add_child(_panel)
	_figure_slot = Control.new()
	_figure_slot.position = Vector2(30, 150)
	add_child(_figure_slot)
	_name_label = Label.new()
	_name_label.position = Vector2(180, 392)
	_name_label.modulate = Color(0.8, 0.7, 1.0)
	add_child(_name_label)
	_text_label = Label.new()
	_text_label.position = Vector2(180, 420)
	_text_label.size = Vector2(740, 100)
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_text_label)
	_hint_label = Label.new()
	_hint_label.text = "▼ E"
	_hint_label.position = Vector2(900, 508)
	_hint_label.modulate = Color(1, 1, 1, 0.5)
	add_child(_hint_label)
	visible = false


func is_active() -> bool:
	return _active


func skit(lines: Array) -> void:
	_queue.append_array(lines)
	if not _active:
		_start.call_deferred()


func _start() -> void:
	_active = true
	visible = true
	get_tree().paused = true
	_next()


func _next() -> void:
	if _queue.is_empty():
		_end()
		return
	var line: Dictionary = _queue.pop_front()
	var who: String = line.get("who", "narrator")
	var char_info: Dictionary = CHARS.get(who, {})
	_name_label.text = str(char_info.get("name", ""))
	_text_label.text = str(line.get("text", ""))
	for child in _figure_slot.get_children():
		child.queue_free()
	if not char_info.is_empty():
		_figure_slot.add_child(make_figure(who, line.get("petrified", false)))


func _end() -> void:
	_active = false
	visible = false
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return
	if event.is_action_pressed("soften") or event.is_action_pressed("jump") \
			or event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_next()
