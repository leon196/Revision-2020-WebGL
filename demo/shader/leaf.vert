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
const float _SubbranchOffset = 0.8;

const float _Thin = 0.1;
const float _ThinSubbranch = 0.1;
const float _ThinBranch = 0.3;
const float _ThinTrunk = 1.0;
const float animation = 0.;

const float PI = 3.1415;
const float TAU = 6.283;

// #define time (time+anchor.y*.1)

mat2 rotation (float a) { float c=cos(a),s=sin(a); return mat2(c,-s,s,c); }
float random (in vec2 st) { return fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123); }


vec3 trunk (float ratio, float salt) {
	vec3 p = vec3(0,ratio * _TrunkHeight,0);
	float a = sin(ratio * TAU * .5 + time * _BranchAnimation);
	p.xz += ratio * vec2(cos(a),sin(a)) * sin(ratio*PI) * _TrunkExpansion;
	return p;
}

vec3 branch (float id, float ratio, float salt) {
	vec3 p = trunk(0.5+0.5*mod((id*.2354),1.0), salt);
	vec3 t = p;
	p.yz *= rotation(.3 * ratio * sin(id * .1 + ratio) + .05 * ratio * sin(ratio * 20.));
	p.xz *= rotation(TAU * sin(id * .2) * 4. + animation*.4 * sin(time + ratio * TAU * 2.));
	p.y += sin(ratio * PI / 2.) * _BranchHeight + animation*.3 * sin(id * .1234 + time - ratio * TAU * 1.);
	p.xz *= sin(ratio * PI / 2.) * _BranchExpansion + animation*.2 * sin(id * .18765 + time + ratio * TAU) + 1.;
	p = mix(t, p, ratio);
	return p;
}

vec3 subbranch (float id, float ratio, float salt) {
	vec3 p = branch(1.0+mod(id,_BranchCount), 0.6 + 0.4 * mod((id*.98765),1.0), salt);
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
	float pepper = random(pos.yz);
	float curry = random(pos.yx);
	float spice = position.x;

	pepper = pow(pepper, 4.);

	float y = anchor.y * 0.5 + 0.5;
	float thin = 0.01+pepper*.03;
	float normal_epsilon = 0.01;

	thin *= sin(y * PI);

	vec2 q = quantity;

	// pos = subbranch(mod(q.y, 100.), fract(curry+time), salt);
	pos = subbranch(q.y, sin(spice * TAU + y * 3.)*0.5+0.5, salt);


	// vec3 forward = normalize(pos.xyz+vec3(0,100,0));
	// vec3 right = normalize(cross(forward, normalize(position.xyz*2.-1.)));
	// vec3 up = normalize(cross(right, forward));
	// vec2 anc = anchor.xy * rotation(PI/4.);
	// pos += (right * anchor.x - up * (anchor.y+1.) * 2.) * thin;

	float camdist = length(camera-pos.xyz);

	vec3 forward = normalize(subbranch(q.y, sin(spice * TAU + y * 3. + .01)*0.5+0.5, salt) - pos);
	// vec3 forward = normalize(camera-pos.xyz);
	// vec3 right = normalize(cross(forward, vec3(0,1,0)));
	// vec3 up = normalize(cross(forward, right));
	vec3 right = -normalize(cross(-normalize(pos - camera), forward));
	vec3 up = normalize(cross(right, forward));
	pos += (right * anchor.x + up * anchor.y) * thin;

	// vColor = mix(vec3(0.235, 0.588, 0.282), vec3(0.662, 0.894, 0.345), sin((salt*.4 + camdist)*TAU)*.5+.5);
	vColor = mix(vec3(0.211, 0.427, 0.925), vec3(0.458, 0.882, 1), sin((spice + camdist*2.))*.5+.5);
	// vColor = mix(vec3(0.901, 0.419, 0), vColor, (anc.y+1.0)*.1+.6);
	// vColor = vec3(1);
	// vColor = vColor.bgr;
	// vColor = vColor.bbb * .5;

	vUV = anchor;
	gl_Position = viewProjection * vec4(pos, 1);
}