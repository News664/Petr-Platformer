class_name MapOverlay
extends CanvasLayer
# Castlevania-style pause map (M). Room cells match each room's rough
# shape (in map-cell units), visited rooms fill in, sealed neighbor areas
# show as stubs, and hidden spaces are hinted with a faint unlabeled cell.
# Layout mirrors docs/AREA_VILLAGE.md.

const UNIT := Vector2(56, 44)
const GAP := 6.0
const ORIGIN := Vector2(150, 170)

# playable rooms: rect is (cell x, cell y, w, h) in map-cell units
const ROOMS := {
	3: {"rect": Rect2i(0, 2, 2, 1), "label": "The Street"},
	4: {"rect": Rect2i(2, 2, 2, 1), "label": "Well Yard"},
	5: {"rect": Rect2i(4, 1, 1, 2), "label": "Sanctuary\nSteps"},
	6: {"rect": Rect2i(5, 1, 2, 2), "label": "The Square"},
	7: {"rect": Rect2i(6, 0, 1, 1), "label": "Bell Tower"},
	1: {"rect": Rect2i(0, 0, 1, 1), "label": "dev 1"},
	2: {"rect": Rect2i(1, 0, 1, 1), "label": "dev 2"},
}
# unexplored neighbors: sealed major areas
const STUBS := [
	{"rect": Rect2i(4, 0, 1, 1), "label": "Sanctuary (dark)"},
	{"rect": Rect2i(7, 1, 2, 1), "label": "Quarry (sealed)"},
	{"rect": Rect2i(5, 3, 2, 1), "label": "Baths (flooded)"},
]
# hidden spaces: barely-there outlines, no label — the map keeps secrets
const HIDDEN := [
	Rect2i(0, 3, 1, 1),  # the cellar under the street
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
	title.position = Vector2(150, 120)
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


func _cell_rect(cells: Rect2i) -> Rect2:
	var pos := ORIGIN + Vector2(cells.position) * (UNIT + Vector2(GAP, GAP))
	var size := Vector2(cells.size) * UNIT + Vector2(cells.size - Vector2i.ONE) * GAP
	return Rect2(pos, size)


func _redraw(current_room: int) -> void:
	for child in _grid.get_children():
		child.queue_free()
	for cells in HIDDEN:
		_draw_cell(_cell_rect(cells), "", Color(0.09, 0.08, 0.13),
				Color.TRANSPARENT, Color(0.3, 0.3, 0.38, 0.25))
	for stub in STUBS:
		_draw_cell(_cell_rect(stub.rect), stub.label,
				Color(0.14, 0.13, 0.19), Color(0.45, 0.45, 0.5, 0.6))
	for room_id in ROOMS:
		var info: Dictionary = ROOMS[room_id]
		var visited: bool = G.visited.get(room_id, false)
		var fill := Color(0.3, 0.26, 0.42) if visited else Color(0.12, 0.11, 0.16)
		var text_col := Color(0.9, 0.88, 1.0) if visited else Color(0.5, 0.5, 0.55, 0.7)
		var label: String = info.label if visited else "?"
		if room_id == current_room:
			fill = Color(0.45, 0.3, 0.62)
		_draw_cell(_cell_rect(info.rect), label, fill, text_col)


func _draw_cell(rect: Rect2, text: String, fill: Color, text_col: Color,
		border_col := Color(0.55, 0.5, 0.7, 0.5)) -> void:
	var border := ColorRect.new()
	border.position = rect.position - Vector2(2, 2)
	border.size = rect.size + Vector2(4, 4)
	border.color = border_col
	_grid.add_child(border)
	var body := ColorRect.new()
	body.position = rect.position
	body.size = rect.size
	body.color = fill
	_grid.add_child(body)
	if text != "":
		var label := Label.new()
		label.text = text
		label.scale = Vector2(0.7, 0.7)
		label.position = rect.position + Vector2(6, 6)
		label.modulate = text_col
		_grid.add_child(label)
