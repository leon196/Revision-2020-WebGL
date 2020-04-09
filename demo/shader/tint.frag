precision mediump float;

uniform float time;
uniform vec4 tint;

varying vec3 vColor;
varying vec2 vUV;

void main() {
	gl_FragColor = vec4(vColor, 1);
}