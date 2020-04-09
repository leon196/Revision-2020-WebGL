precision mediump float;

uniform float time;
uniform vec4 tint;

varying vec3 vColor;
varying vec2 vUV;

void main() {
	float d = length(vUV);
	if (d > 1.0) discard;
	gl_FragColor = vec4(vColor*.7, 1);
}