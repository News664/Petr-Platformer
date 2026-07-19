class_name Warden
extends CharacterBody2D
# Marble Palace prototype: a stone-warden that patrols and re-petrifies
# any softened NPC she touches — the anti-rescue enemy.

const GRAVITY := 980.0

var patrol_left := 0.0
var patrol_right := 0.0
var speed := 60.0

var _dir := 1.0


func _ready() -> void:
	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = Vector2(26, 50)
	shape.shape = rs
	add_child(shape)
	add_child(Util.make_sprite(Vector2(26, 50), Color(0.35, 0.32, 0.42)))
	Util.label(self, Vector2(-24, -48), "warden")


func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	velocity.x = _dir * speed
	move_and_slide()
	# a statue in the path is an obstacle, not a shrine — turn and keep
	# patrolling instead of pressing against it forever
	if is_on_wall():
		_dir = -_dir
	elif global_position.x <= patrol_left:
		_dir = 1.0
	elif global_position.x >= patrol_right:
		_dir = -1.0
	for npc in get_tree().get_nodes_in_group("npc"):
		if npc.soft and npc.global_position.distance_to(global_position) < 44.0:
			npc.force_refreeze()
			G.say("The warden's touch seals %s back into stone." % npc.npc_name)
