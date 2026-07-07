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
	var to := global_position + Vector2.RIGHT.rotated(angle) * length
	var query := PhysicsRayQueryParameters2D.create(global_position, to)
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	var hit_dist := length
	if hit:
		hit_dist = global_position.distance_to(hit.position)
		if hit.collider is Player:
			(hit.collider as Player).respawn("The stone gaze finds her. Cold, then nothing "
					+ "— then the ward pulls her back.")
	_beam.scale.x = hit_dist
	_beam.position = Vector2(hit_dist / 2.0, 0)
