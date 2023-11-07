shader_type spatial;
render_mode diffuse_lambert_wrap, depth_draw_always;

uniform sampler2D staticTex;
uniform sampler2D staticNorm : hint_normal;
uniform sampler2D revealedTex;
uniform sampler2D revealedNorm : hint_normal;
uniform sampler2D heightmap : filter_nearest;
uniform float heightIntensity = 1.0f;
uniform sampler2D srcTex : repeat_disable;
uniform sampler2D secondMask : hint_default_white;
uniform vec2 repeat = vec2(1.0f, 1.0f);
uniform vec2 splatUVStart = vec2(0.0f, 0.0f);
uniform vec2 splatUVEnd = vec2(1.0f, 1.0f);

void vertex() {
	vec3 worldPosition = (MODEL_MATRIX * vec4(VERTEX, 1.0f)).xyz;
	vec2 splatRange = splatUVEnd - splatUVStart;
	VERTEX.y = heightIntensity * texture(heightmap, worldPosition.xz / 256.0f + vec2(0.5f, 0.5f)).r;
}

void fragment() {
	vec2 splatRange = splatUVEnd - splatUVStart;
	float alphaRamp = 1.0f;
	
	ALBEDO = mix(vec3(0.5f, 0.5f, 0.5f), mix(texture(staticTex,repeat*UV).rgb, texture(revealedTex, repeat*UV).rgb, texture(srcTex, splatRange*UV+splatUVStart).r), texture(secondMask, splatRange*UV+splatUVStart).r);
	METALLIC = mix(0.0f, mix(texture(staticTex,repeat*UV).a, texture(revealedTex, repeat*UV).a, texture(srcTex, splatRange*UV+splatUVStart).r), texture(secondMask, splatRange*UV+splatUVStart).r);
	NORMAL_MAP = mix(vec3(0.5f, 0.5f, 0.5f), mix(texture(staticNorm,repeat*UV).rgb, texture(revealedNorm, repeat*UV).rgb, texture(srcTex, splatRange*UV+splatUVStart).r), texture(secondMask, splatRange*UV+splatUVStart).r);
	
	ALPHA = clamp(alphaRamp * texture(secondMask, splatRange*UV+splatUVStart).r + (1.0f - alphaRamp), 0.0f, 1.0f);
	
	//float opacity = clamp(alphaRamp * texture(secondMask, splatRange*UV+splatUVStart).r + (1.0f - alphaRamp), 0.0f, 1.0f);
    
	//if(opacity < 0.5f) discard;
	
	/*int x = int(FRAGCOORD.x) % 4;
    int y = int(FRAGCOORD.y) % 4;
    int index = x + y * 4;
    float limit = 0.0;

    if (x < 8) {
        if (index == 0) limit = 0.0625;
        if (index == 1) limit = 0.5625;
        if (index == 2) limit = 0.1875;
        if (index == 3) limit = 0.6875;
        if (index == 4) limit = 0.8125;
        if (index == 5) limit = 0.3125;
        if (index == 6) limit = 0.9375;
        if (index == 7) limit = 0.4375;
        if (index == 8) limit = 0.25;
        if (index == 9) limit = 0.75;
        if (index == 10) limit = 0.125;
        if (index == 11) limit = 0.625;
        if (index == 12) limit = 1.0;
        if (index == 13) limit = 0.5;
        if (index == 14) limit = 0.875;
        if (index == 15) limit = 0.375;
    }
    // Is this pixel below the opacity limit? Skip drawing it
    if (opacity < limit)
        discard;*/
}
