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
	vec3 forward;

	float y = anchor.y * 0.5 + 0.5;
	float thin = _Thin;
	float normal_epsilon = 0.01;

	vec2 q = quantity;

	// vColor = mix(vec3(0.211, 0.721, 0.866), 2.*vec3(0.211, 0.427, 0.925), smoothstep(0.0, 1.0, y));

	if (q.y > _BranchCount) {
		pos = subbranch(q.y, y, salt);
		forward = normalize(subbranch(q.y, y+normal_epsilon, salt)-pos);
		thin *= _ThinSubbranch*smoothstep(1.5, 0.,y);
	} else if (q.y > 0.0) {
		pos = branch(q.y, y, salt);
		forward = normalize(branch(q.y, y+normal_epsilon, salt)-pos);
		thin *= _ThinBranch*smoothstep(1.5, 0.1, y);
	} else {
		pos = trunk(y, salt);
		forward = normalize(trunk(y+normal_epsilon, salt)-pos);
		thin *= _ThinTrunk*(1.-y);
	} 

	// vColor *= 0.5;
	float camdist = smoothstep(length(camera)*2., 1.0, length(camera-pos));
		vColor = vec3(0.211, 0.427, 0.925) * 2. * camdist;

	vec3 right = -normalize(cross(-normalize(pos - camera), forward));
	vec3 up = normalize(cross(right, forward));
	pos += (right * anchor.x + up * anchor.y) * thin;

	// vColor = vec3(1);
	// vColor = vColor.bbb;
	// vColor = 1.-vColor;
	// vColor = vColor.grb;
	vColor = vColor.bgr;
	vUV = anchor;

	gl_Position = viewProjection * vec4(pos, 1);
}