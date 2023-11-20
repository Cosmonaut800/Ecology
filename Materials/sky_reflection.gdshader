shader_type spatial;
render_mode unshaded, cull_front;

uniform vec3 skyColor : source_color = vec3(1.0f, 1.0f, 1.0f);
uniform vec3 groundColor : source_color = vec3(0.0f, 0.0f, 0.0f);

void fragment() {
	ALBEDO = mix(skyColor, groundColor, clamp(-1.5f + 5.0f * UV.y, 0.0f, 1.0f));
}
