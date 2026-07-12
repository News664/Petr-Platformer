class_name Siren
extends Node2D
# Sunken Baths enemy: a silt siren. Her song captures any *softened* NPC
# in range — the dreaming feet turn toward the song instead of the light.
# Stone statues (pushed, not softened) don't hear it. She dies to a Chisel
# Dash, or to a heavy stone dropped on her from above.

const SONG_RANGE := 220.0

var _t := 0.0
var _body: Sprite2D = null
var _ring: Sprite2D = null


func _ready() -> void:
	_body = Util.make_sprite(Vector2(18, 28), Color(0.35, 0.6, 0.55))
	add_child(_body)
	_ring = Util.make_sprite(Vector2(SONG_RANGE * 2.0, 2), Color(0.5, 0.8, 0.75, 0.18))
	add_child(_ring)
	Util.label(self, Vector2(-26, -44), "silt siren")


func _physics_process(delta: float) -> void:
	_t += delta
	_body.position.y = sin(_t * 2.0) * 3.0
	_ring.scale.y = 1.0 + sin(_t * 4.0) * 0.6
	for npc in get_tree().get_nodes_in_group("npc"):
		var statue := npc as StatueNPC
		if statue.soft and statue.global_position.distance_to(global_position) < SONG_RANGE:
			statue.lure_target = self
		elif statue.lure_target == self:
			statue.lure_target = null
	var player := G.player
	if player != null and is_instance_valid(player) and player.is_dashing() \
			and player.global_position.distance_to(global_position) < 36.0:
		G.say("The chisel-strike shatters the song mid-note.")
		queue_free()
		return
	# a heavy stone falling onto her ends the music
	var space := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = global_position + Vector2(0, -20)
	for hit in space.intersect_point(query, 4):
		var collider: Object = hit.collider
		if collider is RigidBody2D and (collider as RigidBody2D).mass >= 10.0 \
				and (collider as RigidBody2D).linear_velocity.y > 80.0:
			G.say("The stone ends the song.")
			queue_free()
			return
