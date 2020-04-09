precision mediump float;

attribute vec4 position;
attribute vec2 anchor, quantity;

uniform mat4 viewProjection;
uniform vec3 camera;
uniform vec2 resolution;
uniform float time, expansion, growth, timeRotation;

varying vec3 vColor;
varying vec2 vUV;

const float _TrunkHeight = 4.0;
const float _TrunkExpansion = 0.3;

const float _BranchHeight = 2.0;
const float _BranchExpansion = 2.5;
const float _BranchAnimation = 0.0;

const float _BranchCount = 30.0;
const float _SubbranchHeight = 0.8;
const float _SubbranchOffset = 0.4;

const float _Thin = 0.1;
const float _ThinSubbranch = 0.1;
const float _ThinBranch = 0.3;
const float _ThinTrunk = 1.0;
const float animation = 0.;

const float PI = 3.1415;
const float TAU = 6.283;

mat2 rotation (float a) { float c=cos(a),s=sin(a); return mat2(c,-s,s,c); }
float random (in vec2 st) { return fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123); }


vec3 trunk (float ratio, float salt) {
	vec3 p = vec3(0,ratio * _TrunkHeight,0);
	float a = sin(ratio * TAU * .5);
	p.xz += ratio * vec2(cos(a),sin(a)) * sin(ratio*PI) * _TrunkExpansion;
	return p;
}

vec3 branch (float id, float ratio, float salt) {
	vec3 p = trunk(0.2+0.7*mod((id*.2354),1.0), salt);
	vec3 t = p;
	p.yz *= rotation(.3 * ratio * sin(id * .1 + ratio) + .05 * ratio * sin(ratio * 20.));
	p.xz *= rotation(TAU * sin(id * .2) * 4. + animation*.4 * sin(time + ratio * TAU * 2.));
	p.y += sin(ratio * PI / 2.) * _BranchHeight + animation*.3 * sin(id * .1234 + time - ratio * TAU * 1.);
	p.xz *= sin(ratio * PI / 2.) * _BranchExpansion + animation*.2 * sin(id * .18765 + time + ratio * TAU) + 1.;
	p = mix(t, p, ratio);
	return p;
}

vec3 subbranch (float id, float ratio, float salt) {
	vec3 p = branch(1.0+mod(id,_BranchCount), 0.6 + 0.3 * mod((id*.98765),1.0), salt);
	vec3 offset = vec3(random(vec2(id)), random(vec2(id)+.216), random(vec2(id)*45.546)) * 2. - 1.;
	offset.xz *= rotation(sin(ratio*PI) * .2);
	offset.yz *= rotation(sin(ratio*PI) * .8);
	offset.y = abs(offset.y) * _SubbranchHeight;
	p += offset * ratio * _SubbranchOffset;
	return p;
}


void main () {
	vec3 pos = position.xyz;

	float salt = random(pos.xz);
	vec3 forward;

	float y = anchor.y * 0.5 + 0.5;
	float thin = _Thin;
	float normal_epsilon = 0.01;

	vec2 q = quantity;

	vColor = mix(vec3(0.211, 0.721, 0.866), 2.*vec3(0.211, 0.427, 0.925), smoothstep(0.0, 1.0, y));

	if (q.y > _BranchCount) {
		pos = subbranch(q.y, y, salt);
		forward = normalize(subbranch(q.y, y+normal_epsilon, salt)-pos);
		thin *= _ThinSubbranch*smoothstep(1.5, 0.,y);
	} else if (q.y > 0.0) {
		pos = branch(q.y, y, salt);
		forward = normalize(branch(q.y, y+normal_epsilon, salt)-pos);
		thin *= _ThinBranch*smoothstep(1.0, 0.1, y);
	} else {
		pos = trunk(y, salt);
		forward = normalize(trunk(y+normal_epsilon, salt)-pos);
		thin *= _ThinTrunk*(1.-y);
		vColor = vec3(0.211, 0.721, 0.866);
	} 

	vColor *= 0.5;

	vec3 right = -normalize(cross(-normalize(pos - camera), forward));
	vec3 up = normalize(cross(right, forward));
	pos += (right * anchor.x + up * anchor.y) * thin;

	// vColor = vec3(1);
	vColor = vColor.bbb;
	// vColor = vColor.grb;
	// vColor = vColor.bgr;
	vUV = anchor;

	gl_Position = viewProjection * vec4(pos, 1);
}