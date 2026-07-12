class_name HelpOverlay
extends CanvasLayer
# Floating key-binding reference (H). Pauses the game while open.

const LINES := """MOVEMENT
  A / D  or  ← / →      move
  W / Space / ↑          jump

THE AMULET
  E                      soften the nearest statue / re-freeze her early
                         (also advances dialogue)
  F                      look at / speak to a statue · enter doorways
  Q                      petrify yourself (once learned)
  Shift                  chisel dash — shatters cracked stone (once learned)

WORLD
  M                      ledger map
  L                      the Ledger — everyone found, and their fate
  R                      reset the room (returns to the door you entered by)
  H                      this help

DEV / TEST
  1–7                    jump to a room · [ ] step through all rooms
  F1                     debug long soften (60 s)
  F2                     new game (wipes the autosave)"""

var open := false


func _ready() -> void:
	layer = 11
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.04, 0.09, 0.94)
	bg.size = Vector2(960, 540)
	add_child(bg)
	var title := Label.new()
	title.text = "KEYS        (H to close)"
	title.position = Vector2(200, 60)
	add_child(title)
	var body := Label.new()
	body.text = LINES
	body.position = Vector2(200, 100)
	add_child(body)


func toggle() -> void:
	open = not open
	visible = open
	get_tree().paused = open


func _unhandled_input(event: InputEvent) -> void:
	if open and event.is_action_pressed("help"):
		get_viewport().set_input_as_handled()
		toggle()
