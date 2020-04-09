precision mediump float;

uniform sampler2D frame, frameMotion, frameBlur;
uniform vec2 resolution;

varying vec2 texcoord;

void main() {
	vec2 uv = texcoord;
	vec4 blur = texture2D(frameBlur, vec2(uv.x,1.-uv.y));
	// vec4 neon = pow(max(vec4(0.),blur-vec4(.3)), vec4(.5));
	vec4 bloom = pow(max(vec4(0.),blur), vec4(2.));
	gl_FragColor  = texture2D(frame, uv);
	gl_FragColor += bloom;
}

