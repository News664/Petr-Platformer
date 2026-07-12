extends Node
# Autoloaded as "G". Session-wide state and the message bus.

signal message(text: String)

const SAVE_PATH := "user://petr_save.json"

var chisel := 9
var rescued := 0
var truths := 0  # Witness testimonies heard (endings currency)
var debug_soften := false
var player: Player = null
var dialogue: Dialogue = null
var seen := {}     # one-shot story beats already shown this session
var visited := {}  # rooms the player has entered (fills in the map)


func say(text: String) -> void:
	message.emit(text)


func save_state(current_room: int) -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify({
		"room": current_room,
		"rescued": rescued,
		"truths": truths,
		"seen": seen,
		"visited": visited,
	}))


func load_state() -> int:
	# returns the saved room, or -1 when there is no usable save
	if not FileAccess.file_exists(SAVE_PATH):
		return -1
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if typeof(data) != TYPE_DICTIONARY:
		return -1
	rescued = int(data.get("rescued", 0))
	truths = int(data.get("truths", 0))
	seen = data.get("seen", {})
	visited = {}
	for k in data.get("visited", {}):
		visited[int(k)] = true  # JSON stringifies the int room keys
	return int(data.get("room", 3))


func wipe_save() -> void:
	rescued = 0
	truths = 0
	seen = {}
	visited = {}
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


func player_focus() -> Vector2:
	if player == null or not is_instance_valid(player):
		return Vector2.ZERO
	return player.focus_position()
