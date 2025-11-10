extends IRotator
class_name BaseRotator

static func _rotate_shape(shape: Array, angle: float, plane: Array):
	assert(shape.size() > 0)
	
	var point = shape[0]
	var dim := _get_dimension(point)
	assert(dim >= 3 and dim <= 5, "Passed shape is not in 3, 4, or 5 dimensions.")
	
	var to_array_func = _get_to_array_func(dim)
	var from_array_func = _get_from_array_func(dim)
	
	for i in range(shape.size()):
		var vec = to_array_func.call(shape[i])
		var mat = _get_rotation_matrix(dim, plane[0], plane[1], angle)
		var rotated = _perform_rotation(vec, mat)
		shape[i] = from_array_func.call(rotated)


static func _get_dimension(point) -> int:
	if typeof(point) == TYPE_VECTOR3:
		return 3
	elif typeof(point) == TYPE_VECTOR4:
		return 4
	elif typeof(point) == TYPE_ARRAY:
		return point.size()
	else:
		push_error("Unsupported vector type in BaseRotator.")
		return 0


static func _get_to_array_func(dim: int) -> Callable:
	var funcs = {
		3: func(v): return VectorHelper.convert_vec3_to_array(v),
		4: func(v): return VectorHelper.convert_vec4_to_array(v),
		5: func(v): return v,
	}
	return funcs.get(dim)


static func _get_from_array_func(dim: int) -> Callable:
	var funcs = {
		3: func(a): return VectorHelper.convert_array_to_vector3(a),
		4: func(a): return VectorHelper.convert_array_to_vector4(a),
		5: func(a): return a,
	}
	return funcs.get(dim)


static func _perform_rotation(point: Array, rotation_matrix: Array) -> Array:
	return MatrixHelper.multiply_matrix_vector(rotation_matrix, point)


static func _get_rotation_matrix(dim: int, i: int, j: int, angle: float) -> Array:
	var mat = MatrixHelper.identity(dim)
	mat[i][i] = cos(angle)
	mat[j][j] = cos(angle)
	if i == 0 && j == 2:
		mat[i][j] = sin(angle)
		mat[j][i] = -sin(angle)
	else:
		mat[i][j] = -sin(angle)
		mat[j][i] = sin(angle)
	
	return mat
