extends ShapeStrategy

class_name Cube5D

func create_shape() -> ShapeData:
	var data = ShapeData.new()

	for x in [-size, size]:
		for y in [-size, size]:
			for z in [-size, size]:
				for v in [-size, size]:
					for w in [-size, size]:
						data.vertices.append([x, y, z, v, w])

	# If 2 points differ in exactly 1 coordinate they form an edge
	for i in range(data.vertices.size()):
		for j in range(i + 1, data.vertices.size()):
			var differences = 0
			for dim in range(5):
				if not is_equal_approx(data.vertices[i][dim], data.vertices[j][dim]):
					differences += 1
			
			if differences == 1:
				data.edges.append(Vector2i(i, j))

	# Defining faces is quite problematic, hence help of Large Language Model
	# Code produced by GPT4.5
	# Start of the section produced by LLM
	var index_map := {}
	for i in range(data.vertices.size()):
		index_map[data.vertices[i]] = i

	for a in range(5):
		for b in range(a + 1, 5):
			var other_dims := []
			for d in range(5):
				if d != a and d != b:
					other_dims.append(d)
			for mask in range(1 << 3):
				var base := [0, 0, 0, 0, 0]
				for k in range(3):
					var dim = other_dims[k]
					base[dim] = size if (mask & (1 << k)) != 0 else -size
				var face := []
				for sa in [-size, size]:
					for sb in [-size, size]:
						var v := base.duplicate()
						v[a] = sa
						v[b] = sb
						face.append(index_map[v])
				data.faces.append([face[0], face[2], face[3], face[1]])
	# End of the section produced by LLM
	# For Full Reference Refer to the Project Report

	return data
