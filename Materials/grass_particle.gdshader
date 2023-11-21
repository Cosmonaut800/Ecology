shader_type spatial;
render_mode cull_disabled, diffuse_lambert_wrap;

uniform sampler2D waveNoise;
uniform float waveIntensity = 0.5f;
uniform float waveSpeed = 0.25f;
uniform float waveDirectionRatio = 1.0f;
uniform vec3 colorTip : source_color = vec3(1.0f, 1.0f, 1.0f);
uniform vec3 colorBase : source_color = vec3(0.0f, 0.0f, 0.0f);
uniform float lightIntensity = 0.2f;

void vertex() {
	vec3 worldPosition = (MODEL_MATRIX * vec4(VERTEX, 1.0f)).xyz;
	vec3 waveDirection = texture(waveNoise, vec2(worldPosition.x + waveSpeed * TIME, worldPosition.z + waveSpeed * waveDirectionRatio * TIME)/32.0f).rgb * 2.0f - 1.0f;
	VERTEX.x = VERTEX.x + (1.0f - UV.y) * waveIntensity * waveDirection.x;//waveIntensity * waveDirection.x * cos(TIME * waveSpeed);
	VERTEX.z = VERTEX.z + (1.0f - UV.y) * waveIntensity * waveDirection.z;//waveIntensity * waveDirection.z * sin(TIME * waveSpeed * waveDirectionRatio);
}

void fragment() {
	ALBEDO = mix(colorBase, colorTip, 1.0 - UV.y);
	//vec3 worldPosition = (MODEL_MATRIX * vec4(VERTEX, 1.0f)).xyz;
	//ALBEDO = texture(waveNoise, vec2(worldPosition.x + waveSpeed * TIME, worldPosition.z + waveSpeed * waveDirectionRatio * TIME)/32.0f).rgb;
}

void light() {
    DIFFUSE_LIGHT += lightIntensity * ATTENUATION * LIGHT_COLOR;
}