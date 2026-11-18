shader_type canvas_item;

uniform sampler2D mask_texture : filter_nearest, repeat_disable;
uniform float cell = 32.0;
uniform float threshold = 0.5;
uniform float shine = 0.55;
uniform vec3 light_direction = vec3(-0.45, -0.55, 0.7);

void fragment() {
	vec2 grid_size = vec2(textureSize(mask_texture, 0));
	vec2 pixel_position = UV * grid_size * cell;
	vec2 cell_position = floor(pixel_position / cell);
	float is_solid_here = texture(mask_texture, (cell_position + vec2(0.5)) / grid_size).r;
	float is_solid_below = texture(mask_texture, (cell_position + vec2(0.5, 1.5)) / grid_size).r;
	float local_y = pixel_position.y - cell_position.y * cell;
	float visibility = max(is_solid_here, step(0.5, is_solid_below) * step(cell - 2.0, local_y));

	vec4 blood_sample = texture(TEXTURE, UV);
	float edge_factor = smoothstep(threshold - 0.07, threshold + 0.07, blood_sample.a);
	if (visibility < 0.5 || edge_factor < 0.002) {
		COLOR = vec4(0.0);
	} else {
		vec2 texel_size = TEXTURE_PIXEL_SIZE;
		float gradient_x = texture(TEXTURE, UV + vec2(texel_size.x, 0.0)).a - texture(TEXTURE, UV - vec2(texel_size.x, 0.0)).a;
		float gradient_y = texture(TEXTURE, UV + vec2(0.0, texel_size.y)).a - texture(TEXTURE, UV - vec2(0.0, texel_size.y)).a;
		vec3 normal = normalize(vec3(-gradient_x * 2.5, -gradient_y * 2.5, 1.0));
		vec3 light_vector = normalize(light_direction);
		float diffuse = clamp(dot(normal, light_vector), 0.0, 1.0);
		float specular = pow(clamp(dot(reflect(-light_vector, normal), vec3(0.0, 0.0, 1.0)), 0.0, 1.0), 20.0);

		vec3 color = blood_sample.rgb / max(blood_sample.a, 0.001);
		float wetness = smoothstep(0.30, 0.60, color.r);
		float thickness = smoothstep(threshold, threshold + 0.45, blood_sample.a);
		color *= mix(0.6, 1.1, thickness);
		color *= 0.8 + 0.4 * diffuse;
		color += vec3(1.0, 0.75, 0.75) * specular * shine * wetness;
		COLOR = vec4(color, edge_factor);
	}
}
