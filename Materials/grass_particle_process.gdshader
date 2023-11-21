shader_type particles;

uniform float rows = 4.0f;
uniform float spacing = 1.0f;
uniform sampler2D srcTex;
uniform sampler2D noisemap;
uniform sampler2D heightmap : repeat_disable;
uniform float heightmapIntensity = 10.0f;
uniform vec2 heightmapSize = vec2(1024.0f, 1024.0f);
uniform vec3 playerPosition = vec3(0.0f, 0.0f, 0.0f);
uniform float playerRadius = 1.0f;
uniform float renderRadius = 40.0f;

float GetHeight(vec2 pos) {
	pos += 0.5 * heightmapSize;
	pos /= heightmapSize;
	float srcValue = texture(srcTex, pos).r;
	
	if (srcValue < 0.95f || pos.x < 0.0f || pos.x > 1.0f || pos.y < 0.0f || pos.y > 1.0f) {
		return -4096.0f;
	}
	
	return heightmapIntensity * texture(heightmap, pos).r * srcValue;
}

void start() {
	// Place start code here.
}

void process() {
	vec3 pos = vec3(0.0f, 0.0f, 0.0f);
	pos.z = float(INDEX);
	pos.x = mod(pos.z, rows);
	pos.z = (pos.z - pos.x) / rows;
	
	pos.x -= rows * 0.5f;
	pos.z -= rows * 0.5f;
	
	pos *= spacing;
	
	pos.x += EMISSION_TRANSFORM[3][0] - mod(EMISSION_TRANSFORM[3][0], spacing);
	pos.z += EMISSION_TRANSFORM[3][2] - mod(EMISSION_TRANSFORM[3][2], spacing);
	
	vec3 noise = texture(noisemap, pos.xz * 0.1).rgb;
	pos.x += noise.x * spacing;
	pos.z += noise.y * spacing;
	
	float dist = distance(pos.xz, playerPosition.xz);
	pos.y = GetHeight(pos.xz) - 0.6f * clamp(-0.5f * (dist - (playerRadius + 1.0f)), 0.0f, 1.0f) - 1.1f * clamp(0.05f * (dist - (renderRadius)), 0.0f, 1.0f);
	
	TRANSFORM[0][0] = cos(PI * noise.z);
	TRANSFORM[0][2] = -sin(PI * noise.z);
	TRANSFORM[2][0] = sin(PI * noise.z);
	TRANSFORM[2][2] = cos(PI * noise.z);
	
	TRANSFORM[3][0] = pos.x;
	TRANSFORM[3][1] = pos.y;
	TRANSFORM[3][2] = pos.z;
}