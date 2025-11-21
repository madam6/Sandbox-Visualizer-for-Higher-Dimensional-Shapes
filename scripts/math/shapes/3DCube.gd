extends ShapeStrategy

class_name Cube3D

func create_shape() -> ShapeData:
	var data = ShapeData.new()

	data.vertices = [
		Vector3(-size, -size, -size),
		Vector3( size, -size, -size),
		Vector3( size,  size, -size),
		Vector3(-size,  size, -size),
		Vector3(-size, -size,  size),
		Vector3( size, -size,  size),
		Vector3( size,  size,  size),
		Vector3(-size,  size,  size) 
	]
	
	data.edges = [
		Vector2i(0, 1), Vector2i(1, 2), Vector2i(2, 3), Vector2i(3, 0),
		Vector2i(4, 5), Vector2i(5, 6), Vector2i(6, 7), Vector2i(7, 4),
		Vector2i(0, 4), Vector2i(1, 5), Vector2i(2, 6), Vector2i(3, 7)
	]
	
	
	data.faces = [
		[0, 3, 2, 1], # Back
		[4, 5, 6, 7], # Front
		[0, 4, 7, 3], # Left
		[1, 2, 6, 5], # Right
		[3, 7, 6, 2], # Top
		[0, 1, 5, 4]  # Bottom
	]
	
	return data
