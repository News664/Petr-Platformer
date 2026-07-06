class_name StatueNPC
extends RigidBody2D
# A petrified friend. Rigid statue by default; Soften makes her briefly
# kinematic. Softened people are stone-dreamers: not truly awake, they
# follow the amulet's light (Amethyst) blindly — off ledges, into water.
# Grace: the amulet can hold the curse off each person for only a fixed
# total time per Soften tier. When her Grace is spent, she cannot be
# softened again until Amethyst's amulet grows stronger.

signal was_rescued(npc: StatueNPC)
signal refrozen(npc: StatueNPC)

const WINDOW := 8.0          # max seconds per single soften at Soften I
const GRACE_MAX := 12.0      # total soften seconds per person at Soften I
const CHISEL_COST := 1
const FOLLOW_STOP := 34.0
const GRAVITY := 980.0

var npc_name := "Friend"
var kind := "runner"  # "runner" | "kneeler"
var soft := false
var anchored := false  # curse-bound: cannot be softened at all (yet)
var grace_left := GRACE_MAX
var walk_speed := 90.0
var body_size := Vector2(26, 55)
var stone_lines: Array[String] = []
var soft_lines: Array[String] = []

var _soften_timer := 0.0
var _vy := 0.0
var _sprite: Sprite2D = null
var _tag: Label = null
var _line_index := 0
var _barked := false


func _ready() -> void:
	if kind == "kneeler":
		body_size = Vector2(48, 32)
		walk_speed = 60.0
		mass = 12.0
	else:
		body_size = Vector2(26, 55)
		walk_speed = 110.0
		mass = 15.0
		center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
		center_of_mass = Vector2(0, -body_size.y * 0.25)
	var pm := PhysicsMaterial.new()
	pm.friction = 0.75
	physics_material_override = pm
	angular_damp = 1.0
	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = body_size
	shape.shape = rs
	add_child(shape)
	_sprite = Util.make_sprite(body_size, Color(0.8, 0.7, 0.6), true)
	add_child(_sprite)
	Util.set_petrify(_sprite, 1.0)
	_tag = Util.label(self, Vector2(-34, -body_size.y / 2.0 - 26), "")
	_update_tag()
	add_to_group("npc")


func _update_tag() -> void:
	if anchored:
		_tag.text = "%s (anchored)" % npc_name
		return
	var state := "soft %ds" % int(ceilf(_soften_timer)) if soft else "stone"
	_tag.text = "%s (%s, grace %ds)" % [npc_name, state, int(ceilf(grace_left))]


func talk() -> void:
	var lines := soft_lines if soft else stone_lines
	if lines.is_empty():
		G.say("She is somewhere far away, behind the stone.")
		return
	G.say(lines[_line_index % lines.size()])
	_line_index += 1


func try_soften() -> void:
	if soft:
		_refreeze()
		G.say("%s re-freezes at your word." % npc_name)
		return
	if anchored:
		G.say("%s's stone is deep as bedrock — the amulet's light doesn't reach her." % npc_name)
		return
	if grace_left < 0.5 and not G.debug_soften:
		G.say("%s's grace is spent — the amulet cannot reach her again. Not yet." % npc_name)
		return
	if G.chisel < CHISEL_COST:
		G.say("Not enough Chisel Light (need %d, have %d)." % [CHISEL_COST, G.chisel])
		return
	G.chisel -= CHISEL_COST
	var dur := minf(WINDOW, grace_left)
	if G.debug_soften:
		dur = 60.0
	soft = true
	_soften_timer = dur
	_vy = 0.0
	_barked = false
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true
	Util.animate_petrify(_sprite, 1.0, 0.0, 0.3)
	G.say("%s softens — %.0f seconds. She dreams toward your light." % [npc_name, dur])


func _refreeze() -> void:
	soft = false
	_soften_timer = 0.0
	_sprite.self_modulate.a = 1.0
	Util.animate_petrify(_sprite, 0.0, 1.0, 0.3)
	freeze = false
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	_update_tag()
	refrozen.emit(self)


func _physics_process(delta: float) -> void:
	# name tags only when Amethyst is close — keeps the screen quiet
	_tag.visible = G.player_focus().distance_to(global_position) < 140.0
	if not soft:
		# keep the tag readable even when the rigid body rotates
		_tag.rotation = -rotation
		return
	# straighten continuously while soft (a tween can leave her tilted if
	# she was leaning on something when the soften began)
	rotation = move_toward(rotation, 0.0, 3.0 * delta)
	_soften_timer -= delta
	if not G.debug_soften:
		grace_left = maxf(grace_left - delta, 0.0)
	if _soften_timer <= 0.0 or (grace_left <= 0.0 and not G.debug_soften):
		_refreeze()
		if grace_left <= 0.0:
			G.say("%s turns back to stone. Her grace is spent." % npc_name)
		else:
			G.say("%s turns back to stone." % npc_name)
		return
	# flash warning in the last 2 seconds
	if _soften_timer < 2.0:
		_sprite.self_modulate.a = 0.6 + 0.4 * sin(_soften_timer * 20.0)
	else:
		_sprite.self_modulate.a = 1.0

	var dx := G.player_focus().x - global_position.x
	var vx := 0.0
	if absf(dx) > FOLLOW_STOP:
		vx = signf(dx) * walk_speed
	_vy += GRAVITY * delta
	var col_x := move_and_collide(Vector2(vx * delta, 0))
	if col_x and col_x.get_collider() is Player and not _barked:
		_barked = true
		G.say("%s sways against you, eyes half-shut, dreaming of stone." % npc_name)
	var col_y := move_and_collide(Vector2(0, _vy * delta))
	if col_y:
		_vy = 0.0
	_update_tag()
