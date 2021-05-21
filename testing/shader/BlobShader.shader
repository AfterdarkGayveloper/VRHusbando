shader_type spatial;
render_mode unshaded, cull_disabled;
uniform sampler2D noiseNormal;
uniform sampler2D noise1;
uniform float lod;
uniform float noiseLod;

void vertex()
{
	MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat4(CAMERA_MATRIX[0],CAMERA_MATRIX[1],CAMERA_MATRIX[2],WORLD_MATRIX[3]);
}
void fragment() {
	ALPHA_SCISSOR = 0.5;
	
	NORMALMAP = textureLod(noiseNormal,UV,lod).xyz;
	float mask = 1.0 - distance(UV,vec2(0.5));
	
	float noise = textureLod(noise1, UV + sin(TIME), noiseLod).r;
	ALPHA = mask*noise;
}