// Leon Denise 
// Revision 2020

window.onload = function () {

	var button = document.getElementById('button');
	button.innerHTML = 'loading';

	var music = new Audio('animation/music.mp3');

// shaders file to load
loadFiles('shader/',['screen.vert','blur.frag','text.vert','screen.frag','tree.vert','leaf.vert','tint.frag','circle.frag','skybox.vert','skybox.frag','lines.vert'], function(shaders) {

// animation data
loadFiles('animation/',['animation.json'], function(animationData) {

// texts
var textList = ['cookie.obj', 'revision.obj'];
loadFiles('animation/',textList, function(meshes) {

	const gl = document.getElementById('canvas').getContext('webgl');
	const v3 = twgl.v3;
	const m4 = twgl.m4;
	var uniforms = {};
	var frames = [];
	var currentFrame = 0;

	setupMotionBlur();

	var materials = {};
	var materialMap = {
		'text': 			['text.vert', 			'tint.frag'],
		'tree': 			['tree.vert', 			'tint.frag'],
		'leaf': 			['leaf.vert', 			'circle.frag'],
		'lines': 			['lines.vert', 			'tint.frag'],
		'skybox': 		['skybox.vert', 		'skybox.frag'],
		'blur': 			['screen.vert', 		'blur.frag'],
		'motion': 		['screen.vert', 		'motion.frag'],
		'screen': 		['screen.vert', 		'screen.frag'] };

		loadMaterials();

		generateBuffers(gl, meshes);

// Screen
const geometryQuad = twgl.createBufferInfoFromArrays(gl, { 
	position:[-1,-1,0,1,-1,0,-1,1,0,-1,1,0,1,-1,0,1,1,0]
});
  const arrays = {
    position: [-1, -1, 0, 1, -1, 0, -1, 1, 0, -1, 1, 0, 1, -1, 0, 1, 1, 0],
  };
  const bufferInfo = twgl.createBufferInfoFromArrays(gl, arrays);

	// camera
	var camera = [0,0,6];
	var target = [0,0,0];
	var projection, cameraLeft, cameraRight;

	// framebuffers
	var frameMotion = twgl.createFramebufferInfo(gl);
	var frameScreen = twgl.createFramebufferInfo(gl);
	var frameBlurA = twgl.createFramebufferInfo(gl);
	var frameBlurB = twgl.createFramebufferInfo(gl);
	var frameToResize = [frameMotion,frameScreen,frameBlurA,frameBlurB].concat(frames);

	// blender animation
	var animations = new blenderHTML5Animations.ActionLibrary(JSON.parse(animationData[Object.keys(animationData)[0]]));
	var timeElapsed = 0;
	uniforms.time = 0;
	uniforms.timeRotation = 0;
	var blenderSocket = new BlenderWebSocket();
	blenderSocket.addListener('time', function(newTime) { timeElapsed = newTime; });

	function render(elapsed) {
		// elapsed /= 1000;

		elapsed = timeElapsed;
		// elapsed = music.currentTime;

		var deltaTime = elapsed - uniforms.time;
		uniforms.time = elapsed;
		
		camera = animations['camera'].paths['location'].evaluate(elapsed);
		target = animations['target'].paths['location'].evaluate(elapsed);
		var z = v3.normalize(v3.subtract(camera,target));
		var x = v3.normalize(v3.cross([0,1,0],z));
		var y = v3.normalize(v3.cross(z,x));
		cameraMatrix  = m4.lookAt(camera, target, [0,1,0]);
		var fieldOfView = 50;//20+60*getAnimation('fov', elapsed);
		projection = m4.perspective(fieldOfView*Math.PI/180, gl.canvas.width/gl.canvas.height, 0.01, 200.0);
		uniforms.camera = camera;
		uniforms.target = target;

		// render scene
		gl.bindFramebuffer(gl.FRAMEBUFFER, frames[currentFrame].framebuffer);
		gl.clearColor(0,0,0,1);
		gl.clear(gl.COLOR_BUFFER_BIT|gl.DEPTH_BUFFER_BIT);
		gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);
		uniforms.viewProjection = m4.multiply(projection, m4.inverse(cameraMatrix));
		gl.enable(gl.DEPTH_TEST);
		gl.enable(gl.CULL_FACE);
		gl.cullFace(gl.BACK);

		// tree and leaves
		draw(materials['tree'], geometryTree, gl.TRIANGLES);
		draw(materials['leaf'], geometryLeaf, gl.TRIANGLES);
		// draw(materials['lines'], geometryLines, gl.TRIANGLES);

		// text
		drawMesh('cookie');
		drawMesh('revision');

		// skybox
		gl.cullFace(gl.FRONT);
		draw(materials['skybox'], geometrySkybox, gl.TRIANGLES);

		// motion blur
		currentFrame = (currentFrame+1)%motionFrames;
		drawFrame(materials['motion'], geometryQuad, frameMotion.framebuffer);

		// gaussian blur
		var iterations = 8;
		var writeBuffer = frameBlurA;
		var readBuffer = frameBlurB;
		for (var i = 0; i < iterations; i++) {
			var radius = (iterations - i - 1)
			if (i === 0) uniforms.frame = frameMotion.attachments[0];
			else uniforms.frame = readBuffer.attachments[0];
			uniforms.flip = true;
			uniforms.direction = i % 2 === 0 ? [radius, 0] : [0, radius];
			drawFrame(materials['blur'], geometryQuad, writeBuffer.framebuffer);
			var t = writeBuffer;
			writeBuffer = readBuffer;
			readBuffer = t;
		}
		// final composition
		uniforms.frame = frameMotion.attachments[0];
		uniforms.frameBlur = writeBuffer.attachments[0];

		drawFrame(materials['screen'], geometryQuad, null);

		requestAnimationFrame(render);
	}
	function drawFrame(shader, geometry, frame) {
		gl.bindFramebuffer(gl.FRAMEBUFFER, frame);
		gl.disable(gl.CULL_FACE);
		gl.disable(gl.DEPTH_TEST);
		gl.clear(gl.COLOR_BUFFER_BIT|gl.DEPTH_BUFFER_BIT);
		gl.clearColor(0,0,0,1);
		gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);
		draw(shader, geometry, gl.TRIANGLES);
	}
	function draw(shader, geometry, mode) {
		gl.useProgram(shader.program);
		twgl.setBuffersAndAttributes(gl, shader, geometry);
		twgl.setUniforms(shader, uniforms);
		twgl.drawBufferInfo(gl, geometry, mode);
	}
	function drawMesh(meshName) {
		uniforms.location = animations[meshName].paths['location'].evaluate(timeElapsed);
		uniforms.orientation = animations[meshName].paths['rotation_euler'].evaluate(timeElapsed);
		uniforms.scale = animations[meshName].paths['scale'].evaluate(timeElapsed);
		uniforms.scale = [uniforms.scale[0], uniforms.scale[1], -uniforms.scale[2]];
		draw(materials['text'], geometryMesh[meshName+'.obj'], gl.TRIANGLES);
	}
	function onWindowResize() {
		twgl.resizeCanvasToDisplaySize(gl.canvas);
		for (var index = 0; index < frameToResize.length; ++index)
			twgl.resizeFramebufferInfo(gl, frameToResize[index]);
		uniforms.resolution = [gl.canvas.width, gl.canvas.height];
	}
	function loadMaterials() {
		Object.keys(materialMap).forEach(function(key) {
			materials[key] = twgl.createProgramInfo(gl,
				[shaders[materialMap[key][0]],shaders[materialMap[key][1]]]); });
	}
	function setupMotionBlur() {
		uniforms.motionFrames = motionFrames;
		for (var index = 0; index < motionFrames; ++index) {
			frames.push(twgl.createFramebufferInfo(gl));
			uniforms['frame'+index] = frames[index].attachments[0]; }
			shaders['motion.frag'] = 'precision mediump float;\nvarying vec2 texcoord;\nuniform float motionFrames;\nuniform sampler2D '
			for (var index = 0; index < motionFrames; ++index) 
				shaders['motion.frag'] += 'frame'+index+',';
			shaders['motion.frag'] = shaders['motion.frag'].replace(/.$/,";");
			shaders['motion.frag'] += '\nvoid main() {\ngl_FragColor = vec4(0);'
			for (var index = 0; index < motionFrames; ++index) 
				shaders['motion.frag'] += '\ngl_FragColor += texture2D(frame'+index+', texcoord)/motionFrames;'
			shaders['motion.frag'] += '\n}';
		}
		function getAnimation(name, elapsed) {
			return animations[name].paths['location'].evaluate(elapsed)[0];
		}
		function lerp(v0, v1, t) {
			return v0*(1-t)+v1*t;
		}

	// shader hot-reload
	socket = io('http://localhost:5776');
	socket.on('change', function(data) { 
		if (data.path.includes("demo/shader/")) {
			const url = data.path.substr("demo/shader/".length);
			loadFiles("shader/",[url], function(shade) {
				shaders[url] = shade[url];
				loadMaterials();
			});
		}
	});

	// animation hot-reload
	socket = io('http://localhost:5776');
	socket.on('change', function(data) { 
		if (data.path.includes("demo/animation/")) {
			const url = data.path.substr("demo/animation/".length);
			if (url.substr(url.lastIndexOf('.') + 1) == 'json') {
				setTimeout(function(){
					loadFiles("animation/",[url], function(anim) {
						animations = new blenderHTML5Animations.ActionLibrary(JSON.parse(anim[Object.keys(anim)[0]]));
					});
				}, 250);
			}
		}
	});

	onWindowResize();
	window.addEventListener('resize', onWindowResize, false);
	requestAnimationFrame(render);
	button.innerHTML = '';
/*
	button.innerHTML = 'play';
	button.style.cursor = 'pointer';
	button.style.textDecoration = 'underline';
	button.onclick = function() {
		music.play();
		requestAnimationFrame(render);
		button.style.display = 'none';
		document.getElementById('body').style.cursor = 'none';
	};
	music.onended = function() {
		button.innerHTML = '<a href="https://2019.cookie.paris/">2019.cookie.paris</a>';
		button.style.display = 'block';
		document.getElementById('body').style.cursor = 'default';
	}
	*/
});
});
});
}