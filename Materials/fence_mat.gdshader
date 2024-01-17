shader_type spatial;
render_mode depth_draw_always;

uniform sampler2D tex;
uniform sampler2D heightmap;
uniform float heightIntensity = 1.0f;
uniform vec2 texRepeat = vec2(0.0f, 0.0f);
uniform float alphaCutoff = 0.5f;

void vertex() {
	vec3 worldPosition = (MODEL_MATRIX * vec4(VERTEX, 1.0f)).xyz;
	VERTEX.y = VERTEX.y + heightIntensity * texture(heightmap, worldPosition.xz / 256.0f + vec2(0.5f, 0.5f)).r;
}

void fragment() {
	ALBEDO = texture(tex, UV * texRepeat).rgb;
	
	/*if (texture(tex, UV * texRepeat).a > alphaCutoff)
	{
		ALPHA = 1.0f;
	} 
	else
	{
		ALPHA = 0.0f;
	}*/
	ALPHA = texture(tex, UV * texRepeat).a;
}
