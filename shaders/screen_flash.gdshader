shader_type canvas_item;

uniform float flash = 0.0;
uniform vec3 flash_color : source_color = vec3(1.0, 0.1, 0.1);
uniform float vignette = 0.45;

void fragment() {
	vec2 centered_uv = UV - 0.5;
	float vignette_factor = smoothstep(0.35, 0.85, length(centered_uv * vec2(1.0, 1.2))) * vignette;
	float flash_factor = clamp(flash, 0.0, 1.0) * 0.45;
	float alpha = clamp(vignette_factor + flash_factor, 0.0, 1.0);
	vec3 color = (flash_color * flash_factor) / max(alpha, 0.001);
	COLOR = vec4(color, alpha);
}
