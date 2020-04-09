
function particles (attributes, subdivisions) {
	subdivisions = subdivisions || [1,1];
	var count = attributes.position.length / 3;
	var geometries = [];
	var verticesMax = Math.pow(2, 16);
	var geometryCount = 1 + Math.floor(count / verticesMax);
	var faces = [subdivisions[0]+1, subdivisions[1]+1];
	var quadCount = subdivisions[0] * subdivisions[1];
	var numberIndex = 0;
	for (var m = 0; m < geometryCount; ++m) {

		var vertexCount = count;
		if (geometryCount > 1) {
			if (m == geometryCount - 1) count = count % verticesMax;
			else vertexCount = verticesMax;
		}

		var arrays = {
			anchor: [],
			quantity: [],
			indices: [],
		};
		var vIndex = 0;

		var attributeNames = Object.keys(attributes);
		attributeNames.forEach(name => { arrays[name] = []; });

		for (var index = 0; index < vertexCount; ++index) {
			for (var y = 0; y < faces[1]; ++y) {
				for (var x = 0; x < faces[0]; ++x) {
					attributeNames.forEach(name => {
						var array = attributes[name];
						for (var i = 0; i < 3; i++) {
							arrays[name].push(array[index*3+i]);
						}
					});
					var anchorX = x / subdivisions[0];
					var anchorY = y / subdivisions[1];
					arrays.anchor.push(anchorX*2.-1., anchorY*2.-1., 0);
					arrays.quantity.push(numberIndex / (count-1), numberIndex, 0);
				}
			}
			for (var y = 0; y < subdivisions[1]; ++y) {
				for (var x = 0; x < subdivisions[0]; ++x) {
					arrays.indices.push(vIndex, vIndex+1, vIndex+1+subdivisions[0]);
					arrays.indices.push(vIndex+1+subdivisions[0], vIndex+1, vIndex+2+subdivisions[0]);
					vIndex += 1;
				}
				vIndex += 1;
			}
			vIndex += faces[0];
			numberIndex++;
		}
		arrays.indices = { data: arrays.indices, numComponents: 3 };
		geometries.push(arrays);
	}
	return geometries;
}