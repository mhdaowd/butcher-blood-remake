shader_type canvas_item;

uniform vec4 pool_color : source_color = vec4(0.55, 0.02, 0.05, 0.95);
uniform float box_height = 8.0;
uniform float max_height = 5.0;

varying vec2 local_position;
varying vec3 instance_info;

void vertex() {
	local_position = VERTEX;
	instance_info = INSTANCE_CUSTOM.xyz;
}

void fragment() {
	float horizontal_ratio = local_position.x + 0.5;
	float vertical_position = local_position.y + 0.5 * box_height;
	float floor_height = box_height - 1.0;
	float height = min(instance_info.x, max_height);
	float profile = pow(max(sin(horizontal_ratio * 3.14159265), 0.0), 0.55);
	float wobble = 1.0 + 0.18 * instance_info.y * sin(TIME * 16.0 + instance_info.z + horizontal_ratio * 9.0);
	float top_height = floor_height - height * profile * wobble;
	float alpha = smoothstep(top_height - 0.5, top_height + 0.5, vertical_position);
	float depth = clamp((vertical_position - top_height) / max(height, 1.0), 0.0, 1.0);
	vec3 color = mix(pool_color.rgb * 1.25, pool_color.rgb * 0.7, depth);
	float band = (1.0 - smoothstep(0.0, 1.0, abs(vertical_position - (top_height + 0.9)))) * step(0.2, horizontal_ratio) * step(horizontal_ratio, 0.62);
	color += vec3(1.0, 0.6, 0.6) * band * 0.35 * step(1.6, height);
	COLOR = vec4(color, alpha * pool_color.a);
}
