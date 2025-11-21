extends ShapeStrategy

class_name Cube4D

func create_shape() -> ShapeData:
	var data = ShapeData.new()

	data.vertices = [
		# Inner Cube (W = -size)
		Vector4(-size, -size, -size, -size),
		Vector4( size, -size, -size, -size),
		Vector4( size,  size, -size, -size),
		Vector4(-size,  size, -size, -size),
		Vector4(-size, -size,  size, -size),
		Vector4( size, -size,  size, -size),
		Vector4( size,  size,  size, -size),
		Vector4(-size,  size,  size, -size),
		
		# Outer Cube (W = +size)
		Vector4(-size, -size, -size,  size),
		Vector4( size, -size, -size,  size),
		Vector4( size,  size, -size,  size),
		Vector4(-size,  size, -size,  size),
		Vector4(-size, -size,  size,  size),
		Vector4( size, -size,  size,  size),
		Vector4( size,  size,  size,  size),
		Vector4(-size,  size,  size,  size),
	]

	var add_cube_edges = func(offset: int):
		var local_edges = [
			Vector2i(0,1), Vector2i(1,2), Vector2i(2,3), Vector2i(3,0),
			Vector2i(4,5), Vector2i(5,6), Vector2i(6,7), Vector2i(7,4),
			Vector2i(0,4), Vector2i(1,5), Vector2i(2,6), Vector2i(3,7)
		]
		for e in local_edges:
			data.edges.append(Vector2i(e.x + offset, e.y + offset))

	add_cube_edges.call(0)
	add_cube_edges.call(8)

	# Connecting inner cube to outer
	for i in range(8):
		data.edges.append(Vector2i(i, i + 8))

	# We define the 6 faces of the inner cube, 6 of outer, and 12 connecting faces
	var add_cube_faces = func(offset: int):
		var local_faces = [
			[0, 3, 2, 1], [4, 5, 6, 7], # Back, Front
			[0, 4, 7, 3], [1, 2, 6, 5], # Left, Right
			[3, 7, 6, 2], [0, 1, 5, 4]  # Top, Bottom
		]
		for f in local_faces:
			var new_face = []
			for idx in f: new_face.append(idx + offset)
			data.faces.append(new_face)

	add_cube_faces.call(0)
	add_cube_faces.call(8)

	var connectors = [
		[0,1,9,8], [1,2,10,9], [2,3,11,10], [3,0,8,11],
		[4,5,13,12], [5,6,14,13], [6,7,15,14], [7,4,12,15],
		[0,4,12,8], [1,5,13,9], [2,6,14,10], [3,7,15,11]
	]
	data.faces.append_array(connectors)

	return data
