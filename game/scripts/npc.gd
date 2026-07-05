class_name StatueNPC
extends RigidBody2D
# A petrified friend. Rigid statue by default; Soften makes her briefly
# kinematic — she follows Iolite until the window closes, then re-freezes
# wherever (and however) she ended up. Stone-Heat: each consecutive soften
# halves duration and doubles cost until cleared at a Waystone.

signal was_rescued(npc: StatueNPC)

const BASE_DURATION := 8.0
const MAX_HEAT := 3
const FOLLOW_STOP := 34.0
const GRAVITY := 980.0

var npc_name := "Friend"
var kind := "runner"  # "runner" | "kneeler"
var soft := false
var heat := 0
var walk_speed := 90.0
var body_size := Vector2(20, 190)

var _soften_timer := 0.0
var _vy := 0.0
var _sprite: Sprite2D = null
var _tag: Label = null


func _ready() -> void:
	if kind == "kneeler":
		body_size = Vector2(48, 32)
		walk_speed = 60.0
		mass = 12.0
	else:
		body_size = Vector2(20, 190)
		walk_speed = 110.0
		mass = 15.0
		center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
		center_of_mass = Vector2(0, -body_size.y * 0.25)
	var pm := PhysicsMaterial.new()
	pm.friction = 1.0
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
	_tag = Util.label(self, Vector2(-30, -body_size.y / 2.0 - 26), "")
	_update_tag()
	add_to_group("npc")


func _update_tag() -> void:
	var state := "soft %ds" % int(ceilf(_soften_timer)) if soft else "stone"
	_tag.text = "%s (%s, heat %d)" % [npc_name, state, heat]


func try_soften() -> void:
	if soft:
		_refreeze()
		G.say("%s re-freezes at your word." % npc_name)
		return
	if heat >= MAX_HEAT:
		G.say("%s's stone is curse-hot — the amulet refuses. Attune at a Waystone." % npc_name)
		return
	var cost := 1 << heat
	if G.chisel < cost:
		G.say("Not enough Chisel Light (need %d, have %d)." % [cost, G.chisel])
		return
	G.chisel -= cost
	var dur := BASE_DURATION / float(1 << heat)
	if G.debug_soften:
		dur = 60.0
	heat += 1
	soft = true
	_soften_timer = dur
	_vy = 0.0
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true
	var tw := create_tween()
	tw.tween_property(self, "rotation", 0.0, 0.35)
	Util.animate_petrify(_sprite, 1.0, 0.0, 0.3)
	G.say("%s softens — %.0f seconds." % [npc_name, dur])


func _refreeze() -> void:
	soft = false
	_soften_timer = 0.0
	Util.animate_petrify(_sprite, 0.0, 1.0, 0.3)
	freeze = false
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	_update_tag()


func clear_heat() -> void:
	heat = 0
	_update_tag()


func _physics_process(delta: float) -> void:
	if not soft:
		# keep the tag readable even when the rigid body rotates
		_tag.rotation = -rotation
		return
	_soften_timer -= delta
	if _soften_timer <= 0.0:
		_refreeze()
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
	move_and_collide(Vector2(vx * delta, 0))
	var col := move_and_collide(Vector2(0, _vy * delta))
	if col:
		_vy = 0.0
	_update_tag()
