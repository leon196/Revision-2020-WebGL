precision mediump float;

const float PI = 3.1415;
const float TAU = 6.283;
mat2 rotation (float a) { float c=cos(a),s=sin(a); return mat2(c,-s,s,c); }
float random (in vec2 st) { return fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123); }

uniform float time;

const float _TrunkHeight = 8.0;
const float _TrunkExpansion = 0.3;

const float _BranchHeight = 2.0;
const float _BranchExpansion = 2.5;
const float _BranchAnimation = 0.0;

const float _BranchCount = 20.0;
const float _SubbranchHeight = 1.0;
const float _SubbranchOffset = 1.;

const float _Thin = 0.2;
const float _ThinSubbranch = 0.1;
const float _ThinBranch = 0.4;
const float _ThinTrunk = 2.0;
const float animation = 0.;

vec3 trunk (float ratio, float salt) {
	vec3 p = vec3(0,ratio * _TrunkHeight,0);
	// float a = sin(ratio * TAU * .5 + time * _BranchAnimation);
	// p.xz += ratio * vec2(cos(a),sin(a)) * sin(ratio*PI) * _TrunkExpansion;
	return p;
}

vec3 branch (float id, float ratio, float salt) {
	float spice = random(vec2(id));
	vec3 p = trunk(0.1+0.6*mod((id*.2354),1.0), salt);
	vec3 t = p;
	p.yz *= rotation(.3 * ratio * sin(id * .1 + ratio) + .05 * ratio * sin(ratio * 10.));
	p.xz *= rotation(TAU * sin(id * .2) * 4. + animation*.4 * sin(time + ratio * TAU * 2.));
	p.y += sin(ratio * PI / 2.) * _BranchHeight + .5 * sin(id * .1234 - ratio * TAU * 1.);
	p.xz *= 1. + _BranchExpansion;// + .5 * sin(id * .18765 + time * 1. + ratio * TAU);
	// p = mix(t, p, ratio);
	return p;
}

vec3 subbranch (float id, float ratio, float salt) {
	vec3 p = branch(1.0+mod(id,_BranchCount), 0.8 + 0.2 * mod((id*.98765),1.0), salt);
	vec3 offset = vec3(random(vec2(id)), random(vec2(id)+.216), random(vec2(id)*45.546)) * 2. - 1.;
	offset.xz *= rotation(sin(ratio*PI*4.) * .2);
	offset.yz *= rotation(sin(ratio*PI) * .4);
	offset.y = abs(offset.y) * _SubbranchHeight;
	p += offset * ratio * _SubbranchOffset;
	return p;
}