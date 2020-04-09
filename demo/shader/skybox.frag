precision mediump float;

uniform float time;
uniform vec4 tint;

varying vec3 vColor, vView;

void main() {
	vec3 view = normalize(vView);
	gl_FragColor = vec4(view*.5+.5, 1);
}