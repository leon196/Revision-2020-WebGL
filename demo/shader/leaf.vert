attribute vec4 position;
attribute vec2 anchor, quantity;

uniform mat4 viewProjection;
uniform vec3 camera;
uniform vec2 resolution;

varying vec3 vColor;
varying vec2 vUV;

void main () {
	vec3 pos = position.xyz;

	float salt = random(pos.xz);
	float pepper = random(pos.yz);
	float curry = random(pos.yx);
	float spice = position.x;

	pepper = pow(pepper, 4.);

	float y = anchor.y * 0.5 + 0.5;
	float thin = 0.02+pepper*.03;
	float normal_epsilon = 0.01;

	thin *= sin(y * PI);

	vec2 q = quantity;

	float speed = 10.;

	float yy = spice * TAU + y * 2.;
	float ya = 0.3;
	float yb = 0.5;

	// pos = subbranch(mod(q.y, 100.), fract(curry+time), salt);
	pos = subbranch(q.y, sin(yy)*ya+yb, salt);


	// vec3 forward = normalize(pos.xyz+vec3(0,100,0));
	// vec3 right = normalize(cross(forward, normalize(position.xyz*2.-1.)));
	// vec3 up = normalize(cross(right, forward));
	// vec2 anc = anchor.xy * rotation(PI/4.);
	// pos += (right * anchor.x - up * (anchor.y+1.) * 2.) * thin;

	float camdist = length(camera-pos.xyz);

	vec3 forward = normalize(subbranch(q.y, sin(yy+0.01)*ya+yb, salt) - pos);
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
	vColor = vColor.bgr;
	// vColor *= smoothstep(length(camera)+4., 2., camdist);
	// vColor = vColor.bbb * .5;

	vUV = anchor;
	gl_Position = viewProjection * vec4(pos, 1);
}