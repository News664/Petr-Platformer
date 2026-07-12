class_name LedgerOverlay
extends CanvasLayer
# The Rescue Ledger (L): every petrified person Amethyst has found, where
# she left them, and what became of them. Quest log, 100% tracker, and
# the emotional core in one screen. Rows appear once their room is visited.

const PEOPLE := [
	{"name": "Lina", "where": "The Street", "room": 3, "kind": ""},
	{"name": "Petra", "where": "The Street", "room": 3, "kind": "anchored"},
	{"name": "Marla", "where": "The Well Yard", "room": 4, "kind": ""},
	{"name": "Sena", "where": "The Well Yard", "room": 4, "kind": ""},
	{"name": "Odile", "where": "The Sanctuary Steps", "room": 5, "kind": ""},
	{"name": "Sister Aldith", "where": "The Sanctuary Steps", "room": 5, "kind": "anchored"},
	{"name": "a dancer", "where": "The Square", "room": 6, "kind": "anchored"},
	{"name": "two sisters", "where": "The Square", "room": 6, "kind": "anchored"},
	{"name": "the mercer", "where": "The Square", "room": 6, "kind": "anchored"},
	{"name": "Brona", "where": "Gate Terraces", "room": 9, "kind": ""},
	{"name": "the surveyor", "where": "Gate Terraces", "room": 9, "kind": "anchored"},
	{"name": "Hetta", "where": "The Crane Yard", "room": 10, "kind": ""},
	{"name": "Vess", "where": "The Cut", "room": 11, "kind": ""},
	{"name": "the digger twins", "where": "The Cut", "room": 11, "kind": "anchored"},
	{"name": "Rutta", "where": "The Haul Road", "room": 17, "kind": ""},
	{"name": "Sableth", "where": "Colossus Shelf", "room": 21, "kind": "witness"},
	{"name": "Nerissa", "where": "Drowned Vestibule", "room": 23, "kind": "anchored"},
	{"name": "Ottilie", "where": "The Long Soak", "room": 24, "kind": "witness"},
	{"name": "Casta", "where": "The Long Soak", "room": 24, "kind": ""},
	{"name": "Brigid", "where": "The Cisterns", "room": 25, "kind": ""},
	{"name": "Maud", "where": "Deep Sanctuary", "room": 26, "kind": ""},
]

var open := false

var _rows: Control = null


func _ready() -> void:
	layer = 9
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.05, 0.09, 0.95)
	bg.size = Vector2(960, 540)
	add_child(bg)
	_rows = Control.new()
	add_child(_rows)


func toggle() -> void:
	if open:
		open = false
		visible = false
		get_tree().paused = false
		return
	open = true
	_redraw()
	visible = true
	get_tree().paused = true


func _unhandled_input(event: InputEvent) -> void:
	if open and event.is_action_pressed("ledger"):
		get_viewport().set_input_as_handled()
		toggle()


func _status_of(person: Dictionary) -> Array:
	# returns [text, color]
	if G.seen.get("resc_" + str(person.name), false):
		if person.kind == "witness":
			return ["safe in the Village · her truth is told", Color(0.75, 0.95, 0.75)]
		return ["safe in the Village", Color(0.75, 0.95, 0.75)]
	if person.kind == "anchored":
		return ["anchored — beyond the amulet, for now", Color(0.6, 0.55, 0.75)]
	if G.seen.get("met_" + str(person.name), false):
		return ["stone, waiting. I promised.", Color(0.9, 0.85, 0.7)]
	return ["stone, waiting", Color(0.7, 0.7, 0.7)]


func _redraw() -> void:
	for child in _rows.get_children():
		child.queue_free()
	_line(Vector2(140, 60), "THE LEDGER        (L to close)", Color(0.85, 0.8, 1.0))
	_line(Vector2(140, 90), "Rescued %d · Truths heard %d · one passage per Waystone"
			% [G.rescued, G.truths], Color(0.65, 0.65, 0.75))
	var y := 130.0
	for person in PEOPLE:
		if not G.visited.get(int(person.room), false):
			continue
		var status: Array = _status_of(person)
		var name_text: String = str(person.name)
		if person.kind == "witness":
			name_text += " ✶"
		_line(Vector2(140, y), name_text, Color(0.95, 0.92, 1.0))
		_line(Vector2(360, y), str(status[0]), status[1])
		_line(Vector2(760, y), str(person.where), Color(0.55, 0.55, 0.62))
		y += 19.0


func _line(pos: Vector2, text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.modulate = color
	label.scale = Vector2(0.8, 0.8)
	_rows.add_child(label)
