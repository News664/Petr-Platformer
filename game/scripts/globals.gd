extends Node
# Autoloaded as "G". Session-wide state and the message bus.

signal message(text: String)

var chisel := 9
var rescued := 0
var debug_soften := false
var player: Node2D = null
var dialogue: CanvasLayer = null
var seen := {}  # one-shot story beats already shown this session


func say(text: String) -> void:
	message.emit(text)


func player_focus() -> Vector2:
	if player == null or not is_instance_valid(player):
		return Vector2.ZERO
	return player.focus_position()
