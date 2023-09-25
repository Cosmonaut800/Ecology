shader_type spatial;

uniform sampler2D staticTex;
uniform sampler2D revealedTex;
uniform sampler2D srcTex;
uniform vec2 repeat;

void fragment() {
	ALBEDO = (texture(revealedTex, repeat*UV).rgb * texture(srcTex, UV).r) + (texture(staticTex,repeat*UV).rgb * (1.0f - texture(srcTex, UV).r));
}
