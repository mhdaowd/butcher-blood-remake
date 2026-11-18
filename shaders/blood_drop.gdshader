shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.72, 0.03, 0.05, 1.0);

varying vec2 vertex_position;
varying vec2 custom_data;

void vertex() {
	vertex_position = VERTEX;
	custom_data = INSTANCE_CUSTOM.xy;
}

void fragment() {
	float distance_to_center = length(vertex_position);
	float alpha = 1.0 - smoothstep(0.75, 1.0, distance_to_center);
	float highlight = (1.0 - smoothstep(0.0, 0.55, length(vertex_position - vec2(-0.3, -0.35)))) * 0.35;
	vec3 color = base_color.rgb * custom_data.x + vec3(highlight, highlight * 0.6, highlight * 0.6);
	COLOR = vec4(color, alpha * custom_data.y * base_color.a);
}
