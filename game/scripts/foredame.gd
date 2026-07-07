class_name Foredame
extends Node2D
# Quarry boss graybox: a colossal half-carved statue puppeted by the
# curse. Her fist telegraphs over Amethyst's position, then slams.
# She cannot be hurt — she can only be tricked: lure the slams onto the
# three cracked pillars holding up her dig, and the dig takes her.

signal defeated

const AIM_TIME := 1.0
const SLAM_TIME := 0.22
const REST_TIME := 0.9
const RISE_TIME := 0.6
const FIST_REST_Y := 150.0
const FIST_FLOOR_Y := 445.0
const HIT_RANGE := 48.0
const PILLAR_RANGE := 55.0

var pillars: Array = []  # [{body, x, broken}]

var _fist: Sprite2D = null
var _marker: Sprite2D = null
var _state := "idle"
var _timer := 1.5
var _broken := 0


func _ready() -> void:
	# the torso, looming half-carved out of the back wall
	var torso := Util.make_sprite(Vector2(220, 190), Color(0.5, 0.47, 0.44), true)
	torso.position = Vector2(0, -330)
	Util.set_petrify(torso, 1.0)
	add_child(torso)
	Util.label(self, Vector2(-50, -440), "THE FOREDAME")
	_fist = Util.make_sprite(Vector2(64, 64), Color(0.45, 0.42, 0.4), true)
	Util.set_petrify(_fist, 1.0)
	_fist.position = Vector2(0, FIST_REST_Y - 480.0)
	add_child(_fist)
	_marker = Util.make_sprite(Vector2(64, 6), Color(0.9, 0.3, 0.3, 0.7))
	_marker.visible = false
	add_child(_marker)


func add_pillar(body: StaticBody2D, x: float) -> void:
	pillars.append({"body": body, "x": x, "broken": false})


func _physics_process(delta: float) -> void:
	_timer -= delta
	match _state:
		"idle":
			if _timer <= 0.0:
				_state = "aim"
				_timer = AIM_TIME
				_marker.visible = true
		"aim":
			# the fist shadows Amethyst until the last instant
			var target_x: float = G.player_focus().x - global_position.x
			_fist.position.x = target_x
			_marker.position = Vector2(target_x, FIST_FLOOR_Y - 480.0 + 32.0)
			if _timer <= 0.0:
				_state = "slam"
				_timer = SLAM_TIME
				_marker.visible = false
		"slam":
			_fist.position.y = lerpf(FIST_REST_Y - 480.0, FIST_FLOOR_Y - 480.0,
					1.0 - _timer / SLAM_TIME)
			if _timer <= 0.0:
				_land()
				_state = "rest"
				_timer = REST_TIME
		"rest":
			if _timer <= 0.0:
				_state = "rise"
				_timer = RISE_TIME
		"rise":
			_fist.position.y = lerpf(FIST_FLOOR_Y - 480.0, FIST_REST_Y - 480.0,
					1.0 - _timer / RISE_TIME)
			if _timer <= 0.0:
				_state = "idle"
				_timer = 0.6


func _land() -> void:
	var fist_x := global_position.x + _fist.position.x
	var player := G.player as Player
	if player != null and is_instance_valid(player) \
			and absf(player.global_position.x - fist_x) < HIT_RANGE \
			and player.global_position.y > 380.0:
		player.respawn("The fist of the Foredame. The world rings like a struck slab.")
	for p in pillars:
		if not p.broken and absf(p.x - fist_x) < PILLAR_RANGE:
			p.broken = true
			_broken += 1
			(p.body as Node).queue_free()
			if _broken >= pillars.size():
				G.say("The last pillar shatters — the dig groans, and takes her.")
				set_physics_process(false)
				_fist.visible = false
				_marker.visible = false
				defeated.emit()
			else:
				G.say("The pillar shatters under her own fist! (%d of %d)"
						% [_broken, pillars.size()])
			return
