extends Pyramid3D

class_name Pyramid4D

func _init() -> void:
	# Looking at math we need heigh_proportion to be equal to 
	# sqrt(5) to make sure 4D edges are equal in length to 3D ones
	height_proportion = sqrt(5)

func create_shape() -> ShapeData:
	var data = ShapeData.new()
	var s := size
	var h := size * height_proportion
	var apex_w := -s + h

	data.vertices = [
		Vector4(0, 0, 0, apex_w),
		Vector4( s,  s,  s, -s),
		Vector4( s, -s, -s, -s),
		Vector4(-s,  s, -s, -s),
		Vector4(-s, -s,  s, -s)
	]

	for i in range(data.vertices.size()):
		for j in range(i + 1, data.vertices.size()):
			data.edges.append(Vector2i(i, j))


	for i in range(data.vertices.size()):
		for j in range(i + 1, data.vertices.size()):
			for k in range(j + 1, data.vertices.size()):
				data.faces.append([i, j, k])
				
	return data
