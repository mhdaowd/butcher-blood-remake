shader_type canvas_item;

uniform float amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 blood_color : source_color = vec4(0.72, 0.03, 0.05, 1.0);

float hash(vec2 position) {
	return fract(sin(dot(position, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 position) {
	vec2 cell = floor(position);
	vec2 fraction = fract(position);
	fraction = fraction * fraction * (3.0 - 2.0 * fraction);
	return mix(mix(hash(cell), hash(cell + vec2(1.0, 0.0)), fraction.x), mix(hash(cell + vec2(0.0, 1.0)), hash(cell + vec2(1.0, 1.0)), fraction.x), fraction.y);
}

void fragment() {
	vec4 base_color = COLOR;
	float noise_value = noise(UV * vec2(8.0, 3.0)) * 0.6 + noise(UV * vec2(22.0, 9.0)) * 0.4;
	float score = noise_value * 0.55 + smoothstep(0.2, 1.0, UV.x) * 0.55;
	float threshold = mix(1.15, 0.3, amount);
	float blood_mask = smoothstep(threshold, threshold + 0.05, score);
	vec3 color = mix(blood_color.rgb * 0.65, blood_color.rgb, smoothstep(threshold, threshold + 0.25, score));
	COLOR = vec4(mix(base_color.rgb, color, blood_mask * 0.92), base_color.a);
}
