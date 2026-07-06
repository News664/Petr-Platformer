class_name MapOverlay
extends CanvasLayer
# Castlevania-style pause map (M). Visited rooms fill in; neighboring major
# areas show as sealed stubs so the world's shape is visible early.

const CELL := Vector2(170, 76)
const GAP := 10.0
const ORIGIN := Vector2(170, 200)

const ROOMS := {
	3: {"cell": Vector2i(0, 0), "label": "The Street"},
	4: {"cell": Vector2i(1, 0), "label": "Well Yard"},
	5: {"cell": Vector2i(2, 0), "label": "Sanctuary Steps"},
	1: {"cell": Vector2i(0, 1), "label": "Test Yard (dev)"},
	2: {"cell": Vector2i(1, 1), "label": "Chamber (dev)"},
}
const STUBS := [
	{"cell": Vector2i(2, -1), "label": "Village Sanctuary (dark)"},
	{"cell": Vector2i(3, 0), "label": "The Quarry (sealed)"},
	{"cell": Vector2i(3, 1), "label": "Sunken Baths (flooded)"},
]

var open := false

var _grid: Control = null


func _ready() -> void:
	layer = 9
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.04, 0.09, 0.94)
	bg.size = Vector2(960, 540)
	add_child(bg)
	var title := Label.new()
	title.text = "LEDGER MAP — Petrified Village        (M to close)"
	title.position = Vector2(170, 140)
	add_child(title)
	_grid = Control.new()
	add_child(_grid)


func toggle(current_room: int) -> void:
	if open:
		open = false
		visible = false
		get_tree().paused = false
		return
	open = true
	_redraw(current_room)
	visible = true
	get_tree().paused = true


func _unhandled_input(event: InputEvent) -> void:
	# while the tree is paused, ordinary nodes can't hear the close key
	if open and event.is_action_pressed("map"):
		get_viewport().set_input_as_handled()
		toggle(0)


func _cell_rect(cell: Vector2i) -> Rect2:
	var pos := ORIGIN + Vector2(cell) * (CELL + Vector2(GAP, GAP))
	return Rect2(pos, CELL)


func _redraw(current_room: int) -> void:
	for child in _grid.get_children():
		child.queue_free()
	for stub in STUBS:
		_draw_cell(_cell_rect(stub.cell), stub.label,
				Color(0.15, 0.14, 0.2), Color(0.45, 0.45, 0.5, 0.6))
	for room_id in ROOMS:
		var info: Dictionary = ROOMS[room_id]
		var visited: bool = G.visited.get(room_id, false)
		var fill := Color(0.3, 0.26, 0.42) if visited else Color(0.12, 0.11, 0.16)
		var text_col := Color(0.9, 0.88, 1.0) if visited else Color(0.5, 0.5, 0.55, 0.7)
		var label: String = info.label if visited else "?"
		if room_id == current_room:
			fill = Color(0.45, 0.3, 0.62)
		_draw_cell(_cell_rect(info.cell), label, fill, text_col)


func _draw_cell(rect: Rect2, text: String, fill: Color, text_col: Color) -> void:
	var border := ColorRect.new()
	border.position = rect.position - Vector2(2, 2)
	border.size = rect.size + Vector2(4, 4)
	border.color = Color(0.55, 0.5, 0.7, 0.5)
	_grid.add_child(border)
	var body := ColorRect.new()
	body.position = rect.position
	body.size = rect.size
	body.color = fill
	_grid.add_child(body)
	var label := Label.new()
	label.text = text
	label.position = rect.position + Vector2(10, 26)
	label.modulate = text_col
	_grid.add_child(label)
