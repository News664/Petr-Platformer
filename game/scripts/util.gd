class_name Util
# Graybox helpers: everything visual is a tinted 1x1 white texture.

static var _white: ImageTexture = null


static func white_tex() -> ImageTexture:
	if _white == null:
		var img := Image.create(1, 1, false, Image.FORMAT_RGBA8)
		img.set_pixel(0, 0, Color.WHITE)
		_white = ImageTexture.create_from_image(img)
	return _white


static func make_sprite(size: Vector2, color: Color, with_stone_shader := false) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = white_tex()
	s.scale = size
	s.modulate = color
	if with_stone_shader:
		var mat := ShaderMaterial.new()
		mat.shader = load("res://shaders/stone.gdshader")
		s.material = mat
	return s


static func set_petrify(node: CanvasItem, value: float) -> void:
	var mat := node.material as ShaderMaterial
	if mat != null:
		mat.set_shader_parameter("petrify", value)


static func animate_petrify(node: CanvasItem, from_v: float, to_v: float, dur := 0.4) -> void:
	var tw := node.create_tween()
	tw.tween_method(func(v: float): set_petrify(node, v), from_v, to_v, dur)


static func block(parent: Node, rect: Rect2, color := Color(0.35, 0.35, 0.4)) -> StaticBody2D:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = rect.size
	shape.shape = rs
	body.add_child(shape)
	body.add_child(make_sprite(rect.size, color))
	body.position = rect.position + rect.size / 2.0
	parent.add_child(body)
	return body


static func area(parent: Node, rect: Rect2, color: Color) -> Area2D:
	var a := Area2D.new()
	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = rect.size
	shape.shape = rs
	a.add_child(shape)
	a.add_child(make_sprite(rect.size, color))
	a.position = rect.position + rect.size / 2.0
	parent.add_child(a)
	return a


static func label(parent: Node, pos: Vector2, text: String) -> Label:
	# world labels stay small and quiet; anything important should be a
	# message, an inspect line, or a skit instead
	var l := Label.new()
	l.text = text
	l.scale = Vector2(0.6, 0.6)
	l.position = pos
	l.modulate = Color(1, 1, 1, 0.55)
	parent.add_child(l)
	return l


static func crate(parent: Node, pos: Vector2, size := Vector2(28, 28),
		mass := 5.0, color := Color(0.6, 0.45, 0.3)) -> RigidBody2D:
	var b := RigidBody2D.new()
	b.mass = mass
	b.lock_rotation = true
	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = size
	shape.shape = rs
	b.add_child(shape)
	b.add_child(make_sprite(size, color))
	b.position = pos
	parent.add_child(b)
	return b
