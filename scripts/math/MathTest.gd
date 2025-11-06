extends Node

func _ready():
	test_matrix_operations()
	test_vector_operations()
	test_3d_rotation()
	test_4d_rotation()
	
	
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
	print("=======Testing 3D Rotations =======")
	print("Test1 ================================ Test1")
	test_rotate_xy()
	print("Test2 ================================ Test2")
	test_rotate_xz()
	print("Test2 ================================ Test2")
	test_rotate_yz()
	print("=======Testing 3D Rotations Was Succesfull =======")
	
	
func test_4d_rotation():
	print("=======Testing 4D Rotations =======")
	print("Test1 ================================ Test1")
	test_rotate_xy_4d()
	print("Test2 ================================ Test2")
	test_rotate_xz_4d()
	print("Test2 ================================ Test2")
	test_rotate_yz_4d()
	print("Test3 ================================ Test3")
	test_rotate_xw_4d()
	print("Test4 ================================ Test4")
	test_rotate_yw_4d()
	print("Test5 ================================ Test5")
	test_rotate_zw_4d()
	print("=======Testing 4D Rotations Was Succesfull =======")
	
	
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
	
func test_rotate_xy():
	var point = Vector3(0, 1, 0)
	var angle = deg_to_rad(90)
	var result = Rotator3D.rotate_xy(point, angle)
	assert(result.is_equal_approx(Vector3(-1, 0, 0)))
	print("rotate_xy OK:", result)

func test_rotate_xz():
	var point = Vector3(0, 0, 1)
	var angle = deg_to_rad(90)
	var result = Rotator3D.rotate_xz(point, angle)
	assert(result.is_equal_approx(Vector3(1, 0, 0)))
	print("rotate_xz OK:", result)

func test_rotate_yz():
	var point = Vector3(0, 0, 1)
	var angle = deg_to_rad(90)
	var result = Rotator3D.rotate_yz(point, angle)
	assert(result.is_equal_approx(Vector3(0, -1, 0)))
	print("rotate_yz OK:", result)
	
func test_rotate_xy_4d():
	var point = Vector4(0, 1, 0, 0)
	var angle = deg_to_rad(90)
	var result = Rotator4D.rotate_xy(point, angle)
	assert(result.is_equal_approx(Vector4(-1, 0, 0, 0)))
	print("rotate_xy OK:", result)

func test_rotate_xz_4d():
	var point = Vector4(0, 0, 1, 0)
	var angle = deg_to_rad(90)
	var result = Rotator4D.rotate_xz(point, angle)
	assert(result.is_equal_approx(Vector4(-1, 0, 0, 0)))
	print("rotate_xz OK:", result)

func test_rotate_yz_4d():
	var point = Vector4(0, 0, 1, 0)
	var angle = deg_to_rad(90)
	var result = Rotator4D.rotate_yz(point, angle)
	assert(result.is_equal_approx(Vector4(0, -1, 0, 0)))
	print("rotate_yz OK:", result)
	
func test_rotate_xw_4d():
	var point = Vector4(0, 0, 0, 1)
	var angle = deg_to_rad(90)
	var result = Rotator4D.rotate_xw(point, angle)
	assert(result.is_equal_approx(Vector4(-1, 0, 0, 0)))
	print("rotate_xw OK:", result)


func test_rotate_yw_4d():
	var point = Vector4(0, 0, 0, 1)
	var angle = deg_to_rad(90)
	var result = Rotator4D.rotate_yw(point, angle)
	assert(result.is_equal_approx(Vector4(0, -1, 0, 0)))
	print("rotate_yw OK:", result)


func test_rotate_zw_4d():
	var point = Vector4(0, 0, 0, 1)
	var angle = deg_to_rad(90)
	var result = Rotator4D.rotate_zw(point, angle)
	assert(result.is_equal_approx(Vector4(0, 0, -1, 0)))
	print("rotate_zw OK:", result)
