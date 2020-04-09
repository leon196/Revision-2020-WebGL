
attribute vec4 position;
attribute vec2 anchor, quantity;

uniform mat4 viewProjection;
uniform vec3 camera;
uniform vec2 resolution;

varying vec3 vColor;
varying vec2 vUV;

vec3 curve (float ratio) {
	// vec3 seed = vec3(random(anchor.yy), random(anchor.yy+.1542), random(anchor.yy*.5748)) * 2. - 1.;//position.xyz;
	float salt = random(quantity.xy);
	vec3 p = normalize(position.xyz) * max(2., length(position.xyz) * 3.);//mod(time, 1.) * 2.;
	p.xz *= rotation(ratio +time + p.x * TAU);
	p.yz *= rotation(ratio +time + p.y * TAU);
	p.y += 3.5;
	vec3 lod = vec3(mix(1., 8., salt)*vec3(1,.2,1));
	p = mix(ceil(p*lod)/lod, p, ratio);
	// p += (1.-ratio) * seed * .1;
	return p;
}

void main () {
	vec3 pos = position.xyz;

	float y = anchor.y * 0.5 + 0.5;
	float thin = 0.02 * (y);

	pos = curve(y);
	vec3 forward = normalize((curve(y+1.)) - pos);
	vec3 right = -normalize(cross(-normalize(pos - camera), forward));
	vec3 up = normalize(cross(right, forward));

	pos += (right * anchor.x + up * anchor.y) * thin;

	vColor = vec3(1);
	vUV = vec2(0);
	gl_Position = viewProjection * vec4(pos,1);
}

