shader_type spatial;

uniform sampler2D faceTex;
uniform vec2 slices;
uniform vec2 index;
uniform float intensity = 1.0;

void fragment() {
	ALBEDO = vec3(0.0f, 0.0f, 0.0f);
	EMISSION = intensity * texture(faceTex, UV * (1.0f/slices) + ((index - 1.0f)/slices)).rgb;
}
