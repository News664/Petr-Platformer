class_name GazeEmitter
extends Node2D
# Gorgon Gardens prototype: a sweeping petrifying gaze. The beam is a
# raycast — anything solid blocks it, so statues are cover, and stone
# Amethyst is immune (the ray hits her stone form, not her).

var length := 900.0
var sweep := 0.15      # radians each side of facing
var sweep_speed := 0.7
var facing := PI       # default: looks west

var _t := 0.0
var _beam: Sprite2D = null


func _ready() -> void:
	add_child(Util.make_sprite(Vector2(28, 28), Color(0.5, 0.75, 0.4)))
	_beam = Util.make_sprite(Vector2(length, 3), Color(0.75, 0.9, 0.5, 0.35))
	_beam.position = Vector2(length / 2.0, 0)
	var pivot := Node2D.new()
	pivot.add_child(_beam)
	add_child(pivot)


func _physics_process(delta: float) -> void:
	_t += delta * sweep_speed
	var angle := facing + sin(_t) * sweep
	var pivot := _beam.get_parent() as Node2D
	pivot.rotation = angle
	# beam visual: terminate at the first solid thing along the sweep
	var to := global_position + Vector2.RIGHT.rotated(angle) * length
	var query := PhysicsRayQueryParameters2D.create(global_position, to)
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	var hit_dist := length
	if hit:
		hit_dist = global_position.distance_to(hit.position)
	_beam.scale.x = hit_dist
	_beam.position = Vector2(hit_dist / 2.0, 0)
	# the catch: when the gaze is roughly aligned with Amethyst AND has a
	# clear line to her, she is seen — a thin exact-ray test made it
	# trivially passable. Statues (and her own stone form) break the line.
	var player := G.player
	if player == null or not is_instance_valid(player) or player.is_stone:
		return
	var to_player := player.global_position - global_position
	if to_player.length() > length:
		return
	if absf(angle_difference(angle, to_player.angle())) > 0.09:
		return
	var los := PhysicsRayQueryParameters2D.create(global_position, player.global_position)
	var seen := get_world_2d().direct_space_state.intersect_ray(los)
	if seen and seen.collider is Player:
		(seen.collider as Player).respawn("The stone gaze finds her. Cold, then "
				+ "nothing — then the ward pulls her back.")
