class_name Player
extends CharacterBody2D
# Amethyst: flesh form (CharacterBody2D) with a spawnable rigid stone form.

const SPEED := 160.0
const JUMP_VELOCITY := -400.0
const GRAVITY := 1200.0
const COYOTE_TIME := 0.1
const JUMP_BUFFER := 0.12
const STAMINA_MAX := 100.0
const STAMINA_DRAIN := 20.0
const STAMINA_REGEN := 30.0
const MIN_PETRIFY_STAMINA := 25.0
const SWIM_JUMP_VELOCITY := -260.0
const SOFTEN_RANGE := 80.0
# push: per-second force just above static friction, so statues start
# moving slowly and feel heavy
const PUSH_FORCE := 13000.0

var soften_enabled := true
var petrify_enabled := true
var stamina := STAMINA_MAX
var is_stone := false
var stone_form: RigidBody2D = null
var coyote_timer := 0.0
var buffer_timer := 0.0
var in_water := false
var water_surface_y := 0.0
var spawn_point := Vector2.ZERO

var _body_sprite: Sprite2D = null


func _ready() -> void:
	spawn_point = position
	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = Vector2(24, 40)
	shape.shape = rs
	shape.name = "Shape"
	add_child(shape)
	_body_sprite = Util.make_sprite(Vector2(24, 40), Color(0.95, 0.78, 0.62), true)
	add_child(_body_sprite)
	# long purple hair, the one non-negotiable aesthetic
	var hair := Util.make_sprite(Vector2(24, 12), Color(0.55, 0.3, 0.75))
	hair.position = Vector2(0, -16)
	add_child(hair)
	G.player = self


func focus_position() -> Vector2:
	if is_stone and stone_form != null and is_instance_valid(stone_form):
		return stone_form.global_position
	return global_position


func respawn(msg := "") -> void:
	if is_stone:
		_unpetrify(false)
	global_position = spawn_point
	velocity = Vector2.ZERO
	if msg != "":
		G.say(msg)


func _physics_process(delta: float) -> void:
	if global_position.y > 900.0 or focus_position().y > 900.0:
		respawn("You fell out of the world. Back to the start.")
		return
	if is_stone:
		_stone_process(delta)
		return
	stamina = minf(stamina + STAMINA_REGEN * delta, STAMINA_MAX)

	var dir := Input.get_axis("move_left", "move_right")
	velocity.x = dir * SPEED

	if in_water and global_position.y > water_surface_y:
		# flesh floats: strong buoyancy toward the surface, damped
		velocity.y += (GRAVITY - 3200.0) * delta
		velocity.y *= 0.92
	else:
		velocity.y += GRAVITY * delta

	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = maxf(coyote_timer - delta, 0.0)
	buffer_timer = maxf(buffer_timer - delta, 0.0)
	if Input.is_action_just_pressed("jump"):
		buffer_timer = JUMP_BUFFER
	var can_swim_jump := in_water and global_position.y > water_surface_y - 10.0
	if buffer_timer > 0.0 and (coyote_timer > 0.0 or can_swim_jump):
		# from solid ground: full jump; treading water: only a weak hop
		velocity.y = JUMP_VELOCITY if coyote_timer > 0.0 else SWIM_JUMP_VELOCITY
		coyote_timer = 0.0
		buffer_timer = 0.0

	move_and_slide()
	_push_bodies()

	if Input.is_action_just_pressed("petrify"):
		if not petrify_enabled:
			G.say("Only the wave decides who is stone. For now.")
		elif stamina >= MIN_PETRIFY_STAMINA:
			_petrify()
		else:
			G.say("Too exhausted to hold the stone (stamina %d%%)." % int(stamina))
	if Input.is_action_just_pressed("soften"):
		if soften_enabled:
			_try_soften_nearest()
		else:
			G.say("The stone doesn't answer you. Not with bare hands.")


func _push_bodies() -> void:
	var delta := get_physics_process_delta_time()
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var body := col.get_collider()
		if body is RigidBody2D and not body.freeze:
			var n := col.get_normal()
			if absf(n.x) > 0.5:
				# central push only — no lean torque, so a flat-ground push can
				# never topple a statue; toppling happens only deliberately
				# (edges, slopes, drops)
				body.apply_central_impulse(Vector2(-n.x * PUSH_FORCE * delta, 0))


func _try_soften_nearest() -> void:
	var best: StatueNPC = null
	var best_d := SOFTEN_RANGE
	for npc in get_tree().get_nodes_in_group("npc"):
		var d: float = npc.global_position.distance_to(global_position)
		if d < best_d:
			best_d = d
			best = npc
	if best == null:
		G.say("No one in reach of the amulet.")
	else:
		best.try_soften()


func _petrify() -> void:
	is_stone = true
	visible = false
	($Shape as CollisionShape2D).set_deferred("disabled", true)
	stone_form = RigidBody2D.new()
	stone_form.mass = 25.0
	var pm := PhysicsMaterial.new()
	pm.friction = 0.3
	stone_form.physics_material_override = pm
	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = Vector2(24, 40)
	shape.shape = rs
	stone_form.add_child(shape)
	var spr := Util.make_sprite(Vector2(24, 40), Color(0.95, 0.78, 0.62), true)
	stone_form.add_child(spr)
	get_parent().add_child(stone_form)
	stone_form.global_position = global_position
	stone_form.linear_velocity = velocity
	Util.animate_petrify(spr, 0.0, 1.0, 0.25)


func _stone_process(delta: float) -> void:
	stamina -= STAMINA_DRAIN * delta
	if stamina <= 0.0:
		_unpetrify(true)
		G.say("The stone lets go of you.")
		return
	if Input.is_action_just_pressed("petrify"):
		_unpetrify(true)


func _unpetrify(take_position: bool) -> void:
	is_stone = false
	visible = true
	($Shape as CollisionShape2D).set_deferred("disabled", false)
	if stone_form != null and is_instance_valid(stone_form):
		if take_position:
			global_position = stone_form.global_position
			velocity = stone_form.linear_velocity
		stone_form.queue_free()
	stone_form = null
	Util.animate_petrify(_body_sprite, 1.0, 0.0, 0.25)
