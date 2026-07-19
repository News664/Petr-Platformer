class_name Wisp
extends Node2D
# Quarry wisp: a skittish light-eater. Drifts toward the amulet's glow and
# sips Chisel Light on touch. It ignores stone (no light in stone), and a
# Chisel Dash bursts it — the Quarry's resource-pressure enemy.

const CHASE_RANGE := 260.0
const SPEED := 55.0
const SIP_RANGE := 22.0

var home := Vector2.ZERO

var _cooldown := 0.0
var _t := 0.0
var _body: Sprite2D = null


func _ready() -> void:
	home = position
	_body = Util.make_sprite(Vector2(14, 14), Color(0.6, 0.95, 1.0, 0.85))
	add_child(_body)


func _physics_process(delta: float) -> void:
	_t += delta
	_cooldown = maxf(_cooldown - delta, 0.0)
	_body.position.y = sin(_t * 3.0) * 4.0
	var player := G.player
	if player == null or not is_instance_valid(player):
		return
	var to_player := player.global_position - global_position
	var dist := to_player.length()
	if player.is_dashing() and dist < 34.0:
		G.say("The wisp bursts like a soap bubble of cold light.")
		queue_free()
		return
	if dist < CHASE_RANGE and not player.is_stone:
		global_position += to_player.normalized() * SPEED * delta
	else:
		global_position = global_position.move_toward(home, SPEED * 0.6 * delta)
	if dist < SIP_RANGE and _cooldown <= 0.0 and not player.is_stone:
		_cooldown = 1.5
		if not G.debug_soften:
			G.chisel = maxi(G.chisel - 1, 0)
		G.say("A wisp sips at the amulet's light. (-1 Chisel Light)")
		global_position -= to_player.normalized() * 46.0
