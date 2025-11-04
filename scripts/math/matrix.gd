extends Node

class_name MatrixHelper

static func print_matrix(mat: Array) -> void:
	var s := "[\n"
	
	if (typeof(mat[0]) == Variant.Type.TYPE_ARRAY):
		for i in range(mat.size()):
			s += "["
			for j in range(mat[i].size()):
				s += str(mat[i][j]).pad_decimals(2)
				if j < mat[i].size() - 1:
					s += ", "
			s += "]"
			if i < mat.size() - 1:
				s += ",\n"
	else:
		for i in range(mat.size()):
			s += str(mat[i]).pad_decimals(2) + ", "
	s += "\n]"
	print(s)


static func identity(n: int) -> Array:
	var m = []
	for i in range(n):
		m.append([])
		for j in range(n):
			if (i == j):
				m[i].append(1.0)
			else:
				m[i].append(0.0)		
	return m

static func multiply_matrix_vector(mat: Array, vec: Array) -> Array:
	var result = []
	for i in range(mat.size()):
		var sum = 0.0
		for j in range(vec.size()):
			sum += mat[i][j] * vec[j]
		result.append(sum)
	return result
	
static func multiply(A: Array, B: Array) -> Array:
	var rows = A.size()
	var cols = B[0].size()
	var inner = B.size()
	
	var result = []
	
	assert(A[0].size() == inner , "Incorrect matrices are given for multiplicaiton.")

	for i in range(rows):
		result.append([])
		for j in range(cols):
			var sum = 0.0
			for k in range(inner):
				sum += A[i][k] * B[k][j]
			result[i].append(sum)
			
	return result
