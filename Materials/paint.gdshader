shader_type spatial;

uniform sampler2D staticTex;
uniform sampler2D revealedTex;
uniform sampler2D heightmap: repeat_disable;
uniform float heightIntensity = 1.0f;
uniform sampler2D srcTex;
uniform vec2 repeat = vec2(1.0f, 1.0f);

void vertex() {
	VERTEX.y = heightIntensity * texture(heightmap, UV).r;
}

void fragment() {
	ALBEDO = (texture(revealedTex, repeat*UV).rgb * texture(srcTex, UV).r) + (texture(staticTex,repeat*UV).rgb * (1.0f - texture(srcTex, UV).r));
}
