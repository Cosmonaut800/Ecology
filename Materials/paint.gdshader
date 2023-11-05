shader_type spatial;
render_mode diffuse_lambert_wrap;

uniform sampler2D staticTex;
uniform sampler2D staticNorm : hint_normal;
uniform sampler2D revealedTex;
uniform sampler2D revealedNorm : hint_normal;
uniform sampler2D heightmap : filter_nearest;
uniform float heightIntensity = 1.0f;
uniform sampler2D srcTex : repeat_disable;
uniform sampler2D secondMask;
uniform vec2 repeat = vec2(1.0f, 1.0f);
uniform vec2 splatUVStart = vec2(0.0f, 0.0f);
uniform vec2 splatUVEnd = vec2(1.0f, 1.0f);

void vertex() {
	vec3 worldPosition = (MODEL_MATRIX * vec4(VERTEX, 1.0f)).xyz;
	vec2 splatRange = splatUVEnd - splatUVStart;
	VERTEX.y = heightIntensity * texture(heightmap, worldPosition.xz / 256.0f + vec2(0.5f, 0.5f)/*splatRange*UV+splatUVStart*/).r;
}

void fragment() {
	vec2 splatRange = splatUVEnd - splatUVStart;
	
	ALBEDO = (texture(revealedTex, repeat*UV).rgb * texture(srcTex, splatRange*UV+splatUVStart).r) + (texture(staticTex,repeat*UV).rgb * (1.0f - texture(srcTex, splatRange*UV+splatUVStart).r));
	METALLIC = (texture(revealedTex, repeat*UV).a * texture(srcTex, splatRange*UV+splatUVStart).r) + (texture(staticTex,repeat*UV).a * (1.0f - texture(srcTex, splatRange*UV+splatUVStart).r));
	NORMAL_MAP = (texture(revealedNorm, repeat*UV).rgb * texture(srcTex, splatRange*UV+splatUVStart).r) + (texture(staticNorm,repeat*UV).rgb * (1.0f - texture(srcTex, splatRange*UV+splatUVStart).r));
	
}
