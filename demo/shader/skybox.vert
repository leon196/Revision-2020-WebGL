precision mediump float;

attribute vec4 position;

uniform mat4 viewProjection;
uniform vec3 camera;
uniform vec2 resolution;
uniform float time;

varying vec3 vColor, vView;

const float PI = 3.1415;

mat2 rotation (float a) { float c=cos(a),s=sin(a); return mat2(c,-s,s,c); }

void main () {
	vec4 pos = position;
	vColor = vec3(1);
	vView = camera - pos.xyz;
	gl_Position = viewProjection * pos;
}

