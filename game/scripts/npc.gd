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
var char_id := ""  # dialogue portrait id; first inspect shows her petrified figure
var soft := false
var anchored := false  # curse-bound: cannot be softened at all (yet)
var grace_left := GRACE_MAX
var walk_speed := 90.0
var body_size := Vector2(26, 55)
var stone_lines: Array[String] = []
var soft_lines: Array[String] = []

var _soften_timer := 0.0
var _presence := 0.0
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
	# upright while grounded: pushing drags the base against friction and
	# the torque would tip her over. Rotation unlocks only while falling.
	lock_rotation = true
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
	# the first close look at a named person is a held moment: her petrified
	# figure, full frame, and her frozen story
	if char_id != "" and not soft and not G.seen.get("met_" + npc_name, false):
		G.seen["met_" + npc_name] = true
		G.dialogue.skit([{"who": char_id, "petrified": true, "text": lines[0]}])
		_line_index = 1
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


func force_refreeze() -> void:
	# an outside force (stone-warden) seals her early
	if soft:
		_refreeze()


func _update_presence(player_dist: float, delta: float) -> void:
	# the amulet senses the person inside when Amethyst stands close — but
	# the glow dies the moment the statue is used as an object: pushed
	# around, or stood on. She reads as a thing exactly when treated as one.
	var being_pushed := not soft and absf(linear_velocity.x) > 5.0
	var player := G.player
	var stood_on := false
	if player != null and is_instance_valid(player) and player.is_on_floor():
		var top := global_position.y - body_size.y / 2.0
		stood_on = absf(player.global_position.x - global_position.x) \
				< body_size.x / 2.0 + 12.0 \
				and absf((player.global_position.y + 20.0) - top) < 8.0
	var used := being_pushed or stood_on
	if used and npc_name != "Friend":
		if being_pushed and not G.seen.get("bark_pushed", false):
			G.seen["bark_pushed"] = true
			G.say("(She pushes. The stone doesn't complain. That's the worst part.)")
		elif stood_on and not G.seen.get("bark_stood", false):
			G.seen["bark_stood"] = true
			G.say("(Her shoulders hold. They always did.)")
	var target := 0.0
	if player_dist < 90.0 and not used:
		target = 1.0
	_presence = move_toward(_presence, target, 3.0 * delta)
	Util.set_presence(_sprite, _presence)


func _physics_process(delta: float) -> void:
	# name tags only when Amethyst is close — keeps the screen quiet
	var player_dist := G.player_focus().distance_to(global_position)
	_tag.visible = player_dist < 140.0
	_update_presence(player_dist, delta)
	if not soft:
		# free rotation only while falling, so drops and edge-pushes topple
		# but flat-ground shoves never do
		lock_rotation = absf(linear_velocity.y) < 60.0
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
