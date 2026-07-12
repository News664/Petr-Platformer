shader_type canvas_item;

// 0.0 = flesh, 1.0 = fully petrified. The wipe travels bottom-to-top.
uniform float petrify : hint_range(0.0, 1.0) = 0.0;
// The amulet senses the person inside: a soft violet rim that breathes.
// It fades to zero while the statue is being used as an object.
uniform float presence : hint_range(0.0, 1.0) = 0.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec4 base = COLOR;
	float lum = dot(base.rgb, vec3(0.299, 0.587, 0.114));
	float n = hash(floor(UV * 24.0)) * 0.14 - 0.07;
	vec3 stone = (vec3(lum) + n) * vec3(0.82, 0.85, 0.92);
	float m = smoothstep(1.0 - petrify - 0.06, 1.0 - petrify + 0.06, UV.y);
	// thin glow line at the wipe front
	float front = smoothstep(0.05, 0.0, abs(UV.y - (1.0 - petrify))) * step(0.001, petrify) * step(petrify, 0.999);
	vec3 col = mix(base.rgb, stone, m) + vec3(0.35, 0.3, 0.5) * front;
	float edge = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
	float breathe = 0.6 + 0.4 * sin(TIME * 2.2);
	float rim = smoothstep(0.16, 0.0, edge) * presence * breathe * m;
	col += vec3(0.45, 0.35, 0.72) * rim;
	COLOR = vec4(col, base.a);
}
