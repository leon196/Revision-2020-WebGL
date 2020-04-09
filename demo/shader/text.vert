precision mediump float;

attribute vec4 position;
attribute vec4 seed;

uniform mat4 viewProjection;
uniform float time;
uniform vec2 resolution;
uniform vec3 location, orientation, scale;

varying vec3 vColor;
varying vec2 vUV;

const float PI = 3.1415;

mat2 rotation (float a) { float c=cos(a),s=sin(a); return mat2(c,-s,s,c); }

void main () {
	vec4 pos = position;
	pos.xyz *= scale;
	pos.yz *= rotation(orientation.x);
	pos.zx *= rotation(orientation.y);
	pos.xy *= rotation(orientation.z);
	pos.xyz += location;
	vColor = vec3(1);
	vUV = vec2(0);
	gl_Position = viewProjection * pos;
}

