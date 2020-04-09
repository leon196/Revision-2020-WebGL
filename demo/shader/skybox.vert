attribute vec4 position;

uniform mat4 viewProjection;
uniform vec3 camera;
uniform vec2 resolution;

varying vec3 vColor, vView;

void main () {
	vec4 pos = position;
	vColor = vec3(1);
	vView = camera - pos.xyz;
	gl_Position = viewProjection * pos;
}

