
var geometryTree, geometryLeaf, geometrySkybox, geometryLines, geometryMesh;

function generateBuffers (gl, meshes) {

var attributesTree = { position: [] };
	for (var i = 0; i < 200; ++i) 
		attributesTree.position.push(Math.random(), Math.random(), Math.random());

	var attributesLeaf = { position: [] };
	for (var i = 0; i < 2000; ++i) 
		attributesLeaf.position.push(Math.random(), Math.random(), Math.random());

	var attributesLines = { position: [] };
	for (var i = 0; i < 100; ++i) 
		attributesLines.position.push(Math.random(), Math.random(), Math.random());

	geometryTree = twgl.createBufferInfoFromArrays(gl, particles(attributesTree, [1,40])[0]);
	geometryLeaf = twgl.createBufferInfoFromArrays(gl, particles(attributesLeaf, [1,8])[0]);
	geometryLines = twgl.createBufferInfoFromArrays(gl, particles(attributesLines, [1,40])[0]);
	geometrySkybox = twgl.primitives.createSphereBufferInfo(gl, 100, 8, 8);

	geometryMesh = {};
	Object.keys(meshes).forEach(function(item) {
		var lines = meshes[item].split('\n');
		var attributes = { position: [], indices: { numComponents: 3, data: [] } };
		for (var i = 4; i < lines.length; ++i) {
			if (lines[i][0] == 'v') {
				var columns = lines[i].split(' ');
				attributes.position.push(columns[1], columns[2], columns[3]);
			} else if (lines[i][0] == 'f') {
				var columns = lines[i].split(' ');
				attributes.indices.data.push(
					columns[1].substring(0, columns[1].length-3)-1,
					columns[2].substring(0, columns[2].length-3)-1,
					columns[3].substring(0, columns[3].length-3)-1);
			}
		}
		geometryMesh[item] = twgl.createBufferInfoFromArrays(gl, attributes);
	})
}