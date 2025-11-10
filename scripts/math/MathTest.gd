extends Node

func _ready():
	test_matrix_operations()
	test_vector_operations()
	test_3d_rotation()
	test_4d_rotation()
	test_5d_rotation()
	
	
func test_matrix_operations():
	print("=======Testing Matrix Operations=======")
	print("Test1 ================================ Test1")
	test_identity()
	print("Test2 ================================ Test2")
	test_multiplication_by_vector()
	print("Test3 ================================ Test3")
	test_matrix_multiplication()
	print("=======Matrix Operations Testing Was Succesfull =======")
	
func test_vector_operations():
	print("=======Testing Vector Operations=======")
	print("Test1 ================================ Test1")
	test_vector_magnitude()
	print("Test2 ================================ Test2")
	test_vector_normalization()
	print("=======Testing Vector Operations Was Succesfull =======")
	
func test_3d_rotation():
	run_rotation_tests([
		"test_rotate_xy_3d",
		"test_rotate_xz_3d",
		"test_rotate_yz_3d",
	], 3)

func test_4d_rotation():
	run_rotation_tests([
		"test_rotate_xy_4d",
		"test_rotate_xz_4d",
		"test_rotate_yz_4d",
		"test_rotate_xw_4d",
		"test_rotate_yw_4d",
		"test_rotate_zw_4d",
	], 4)

func test_5d_rotation():
	run_rotation_tests([
		"test_rotate_xy_5d",
		"test_rotate_xz_5d",
		"test_rotate_yz_5d",
		"test_rotate_xw_5d",
		"test_rotate_yw_5d",
		"test_rotate_zw_5d",
		"test_rotate_xv_5d",
		"test_rotate_yv_5d",
		"test_rotate_zv_5d",
		"test_rotate_wv_5d",
	], 5)

	
func run_rotation_tests(test_funcs: Array, dimension: int):
	print("======= Testing %dD Rotations =======" % dimension)
	
	for i in range(test_funcs.size()):
		var func_name = test_funcs[i]
		print("Test%d ================================ Test%d" % [i + 1, i + 1])
		
		if has_method(func_name):
			call(func_name)
		else:
			push_error("Missing test function: %s" % func_name)
	
	print("======= Testing %dD Rotations Was Successful =======" % dimension)

	
func test_identity():
	var matrix1 = [[1.00,2.00,3.00],[3.00,2.00,1.00]]
	var result = MatrixHelper.multiply(matrix1, MatrixHelper.identity(3))
	assert(matrix1 == result)
	MatrixHelper.print_matrix(result)
	
func test_multiplication_by_vector():
	var matrix = [[1.00, -1.00, 2.00], [0.00, -3.00, 1.00]]
	var vector3 = Vector3(2, 1, 0)
	var result = MatrixHelper.multiply_matrix_vector(matrix, VectorHelper.convert_vec3_to_array(vector3))
	assert([1.00, -3.00] == result)
	MatrixHelper.print_matrix(result)
	
func test_matrix_multiplication():
	var matrix1 = [[1,2,3],[4,5,6]]
	var matrix2 = [[7,8], [9,10], [11,12]]
	var result = MatrixHelper.multiply(matrix1, matrix2)
	assert([[58.00,64.00],[139.00,154.00]] == result)
	MatrixHelper.print_matrix(result)
	
func test_vector_magnitude():
	var vector = [3,4]
	var result = VectorHelper.magnitude(vector)
	assert(5.00 == result)
	print(result)
	
func test_vector_normalization():
	var vector = [3, 4]
	var result = VectorHelper.normalize(vector)
	assert([0.60, 0.80] == result)
	VectorHelper.print_vector(result)
	
func test_rotate_xy_3d():
	var shape = [Vector3(0, 1, 0)]
	var angle = deg_to_rad(90)
	Rotator3D.rotate(shape, angle, Enums.PLANES.XY)
	assert(shape[0].is_equal_approx(Vector3(-1, 0, 0)))
	print("Rotator3D XY rotation OK:", shape[0])


func test_rotate_xz_3d():
	var shape = [Vector3(0, 0, 1)]
	var angle = deg_to_rad(90)
	Rotator3D.rotate(shape, angle, Enums.PLANES.XZ)
	assert(shape[0].is_equal_approx(Vector3(1, 0, 0)))
	print("Rotator3D XZ rotation OK:", shape[0])


func test_rotate_yz_3d():
	var shape = [Vector3(0, 0, 1)]
	var angle = deg_to_rad(90)
	Rotator3D.rotate(shape, angle, Enums.PLANES.YZ)
	assert(shape[0].is_equal_approx(Vector3(0, -1, 0)))
	print("Rotator3D YZ rotation OK:", shape[0])


func test_rotate_xy_4d():
	var shape = [Vector4(0, 1, 0, 0)]
	var angle = deg_to_rad(90)
	Rotator4D.rotate(shape, angle, Enums.PLANES.XY)
	assert(shape[0].is_equal_approx(Vector4(-1, 0, 0, 0)))
	print("Rotator4D XY rotation OK:", shape[0])


func test_rotate_xz_4d():
	var shape = [Vector4(0, 0, 1, 0)]
	var angle = deg_to_rad(90)
	Rotator4D.rotate(shape, angle, Enums.PLANES.XZ)
	assert(shape[0].is_equal_approx(Vector4(1, 0, 0, 0)))
	print("Rotator4D XZ rotation OK:", shape[0])


func test_rotate_yz_4d():
	var shape = [Vector4(0, 0, 1, 0)]
	var angle = deg_to_rad(90)
	Rotator4D.rotate(shape, angle, Enums.PLANES.YZ)
	assert(shape[0].is_equal_approx(Vector4(0, -1, 0, 0)))
	print("Rotator4D YZ rotation OK:", shape[0])


func test_rotate_xw_4d():
	var shape = [Vector4(0, 0, 0, 1)]
	var angle = deg_to_rad(90)
	Rotator4D.rotate(shape, angle, Enums.PLANES.XW)
	assert(shape[0].is_equal_approx(Vector4(-1, 0, 0, 0)))
	print("Rotator4D XW rotation OK:", shape[0])


func test_rotate_yw_4d():
	var shape = [Vector4(0, 0, 0, 1)]
	var angle = deg_to_rad(90)
	Rotator4D.rotate(shape, angle, Enums.PLANES.YW)
	assert(shape[0].is_equal_approx(Vector4(0, -1, 0, 0)))
	print("Rotator4D YW rotation OK:", shape[0])


func test_rotate_zw_4d():
	var shape = [Vector4(0, 0, 0, 1)]
	var angle = deg_to_rad(90)
	Rotator4D.rotate(shape, angle, Enums.PLANES.ZW)
	assert(shape[0].is_equal_approx(Vector4(0, 0, -1, 0)))
	print("Rotator4D ZW rotation OK:", shape[0])


func test_rotate_xy_5d():
	var shape = [[0, 1, 0, 0, 0]]
	var angle = deg_to_rad(90)
	Rotator5D.rotate(shape, angle, Enums.PLANES.XY)
	assert(arrays_equal_approx(shape[0], [-1.0, 0.0, 0.0, 0.0, 0.0]))
	print("Rotator5D XY rotation OK:", shape[0])


func test_rotate_xz_5d():
	var shape = [[0, 0, 1, 0, 0]]
	var angle = deg_to_rad(90)
	Rotator5D.rotate(shape, angle, Enums.PLANES.XZ)
	assert(arrays_equal_approx(shape[0], [1, 0, 0, 0, 0]))
	print("Rotator5D XZ rotation OK:", shape[0])


func test_rotate_yz_5d():
	var shape = [[0, 0, 1, 0, 0]]
	var angle = deg_to_rad(90)
	Rotator5D.rotate(shape, angle, Enums.PLANES.YZ)
	assert(arrays_equal_approx(shape[0], [0, -1, 0, 0, 0]))
	print("Rotator5D YZ rotation OK:", shape[0])


func test_rotate_xw_5d():
	var shape = [[0, 0, 0, 1, 0]]
	var angle = deg_to_rad(90)
	Rotator5D.rotate(shape, angle, Enums.PLANES.XW)
	assert(arrays_equal_approx(shape[0], [-1, 0, 0, 0, 0]))
	print("Rotator5D XW rotation OK:", shape[0])


func test_rotate_yw_5d():
	var shape = [[0, 0, 0, 1, 0]]
	var angle = deg_to_rad(90)
	Rotator5D.rotate(shape, angle, Enums.PLANES.YW)
	assert(arrays_equal_approx(shape[0], [0, -1, 0, 0, 0]))
	print("Rotator5D YW rotation OK:", shape[0])


func test_rotate_zw_5d():
	var shape = [[0, 0, 0, 1, 0]]
	var angle = deg_to_rad(90)
	Rotator5D.rotate(shape, angle, Enums.PLANES.ZW)
	assert(arrays_equal_approx(shape[0], [0, 0, -1, 0, 0]))
	print("Rotator5D ZW rotation OK:", shape[0])


func test_rotate_xv_5d():
	var shape = [[0, 0, 0, 0, 1]]
	var angle = deg_to_rad(90)
	Rotator5D.rotate(shape, angle, Enums.PLANES.XV)
	assert(arrays_equal_approx(shape[0], [-1, 0, 0, 0, 0]))
	print("Rotator5D XV rotation OK:", shape[0])


func test_rotate_yv_5d():
	var shape = [[0, 0, 0, 0, 1]]
	var angle = deg_to_rad(90)
	Rotator5D.rotate(shape, angle, Enums.PLANES.YV)
	assert(arrays_equal_approx(shape[0], [0, -1, 0, 0, 0]))
	print("Rotator5D YV rotation OK:", shape[0])


func test_rotate_zv_5d():
	var shape = [[0, 0, 0, 0, 1]]
	var angle = deg_to_rad(90)
	Rotator5D.rotate(shape, angle, Enums.PLANES.ZV)
	assert(arrays_equal_approx(shape[0], [0, 0, -1, 0, 0]))
	print("Rotator5D ZV rotation OK:", shape[0])


func test_rotate_wv_5d():
	var shape = [[0, 0, 0, 0, 1]]
	var angle = deg_to_rad(90)
	Rotator5D.rotate(shape, angle, Enums.PLANES.WV)
	assert(arrays_equal_approx(shape[0], [0, 0, 0, -1, 0]))
	print("Rotator5D WV rotation OK:", shape[0])
	
	
func arrays_equal_approx(a: Array, b: Array, epsilon: float = 0.00001) -> bool:
	for i in range(a.size()):
		if abs(a[i] - b[i]) > epsilon:
			return false
	return true
