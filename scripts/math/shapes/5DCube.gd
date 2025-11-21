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

	# TODO: figure out how to calculate vertices for 5D cube
	# TODO: figure out how to calculate faces for 5D cube (might need to avoid it, could be too heavy)

	return data
