precision mediump float;

uniform float time;
uniform vec4 tint;

varying vec3 vColor, vView;

mat2 rotation (float a) { float c=cos(a),s=sin(a); return mat2(c,-s,s,c); }
float random (in vec2 st) { return fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123); }

void main() {
	vec3 view = normalize(vView);
	float dither = 0.01*random(vView.xy);
	// vec3 gradient1 = vec3(1) * pow(clamp(dither+(dot(view, normalize(vec3(0,2,4)))*.5+.5), 0., 1.), 2.);
	vec3 gradient1 = vec3(0.282, 0.678, 0.898) * pow(clamp(dither+(dot(view, normalize(vec3(0,2,4)))*.5+.5), 0., 1.), 2.);
	// vec3 gradient2 = vec3(1) * pow(clamp(dither+(dot(view, normalize(vec3(0,1,-2)))*.5+.5), 0., 1.), 2.);
	vec3 gradient2 = vec3(0.282, 0.678, 0.898) * pow(clamp(dither+(dot(view, normalize(vec3(0,1,-2)))*.5+.5), 0., 1.), 2.);
	vec3 gradient = gradient1+gradient2;
	gradient = gradient.brg;
	gl_FragColor = vec4(gradient*.3, 1);
}