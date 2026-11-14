extends RefCounted

class_name NativeBackend

# Glue between the GDScript maths and the C++ GDExtension in extension/.
#
# Each inner class below extends one of the existing GDScript classes and overrides only the
# maths, handing it to C++. Everything else (size, w_distance, supported_planes, the
# adjust_*_to_new_size helpers) is inherited, so these objects can go anywhere the GDScript
# versions are used, and ShapeMap can swap one set for the other at runtime.
#
# The C++ classes (NativeRotator, NativeProjector, NativeShapes) are created by name through
# ClassDB. Naming them directly would stop this file from parsing whenever the extension
# isn't loaded, e.g. in the web build, and the app needs to run there on GDScript alone.

const CPP_CLASSES : Array[String] = ["NativeRotator", "NativeProjector", "NativeShapes"]

static func is_available() -> bool:
	for cls in CPP_CLASSES:
		if not ClassDB.class_exists(cls):
			return false
	return true

# Same keys as ShapeMap.build_gdscript_set(), so the two sets can be matched entry by entry.
static func build_strategy_set() -> Dictionary:
	return {
		"rotator3D": CppRotator3D.new(),
		"rotator4D": CppRotator4D.new(),
		"rotator5D": CppRotator5D.new(),
		"projector3d": CppDummy3DProjection.new(),
		"projector4d": CppOrthographic4DProjection.new(),
		"projector5d": CppOrthographic5DProjection.new(),
		"perspective4d": CppPerspective4DProjection.new(),
		"perspective5d": CppPerspective5DProjection.new(),
		"cube3D": CppCube3D.new(),
		"cube4D": CppCube4D.new(),
		"cube5D": CppCube5D.new(),
		"pyramid3D": CppPyramid3D.new(),
		"pyramid4D": CppPyramid4D.new(),
	}

# NativeShapes returns a Dictionary; the rest of the app expects ShapeData with typed arrays.
static func to_shape_data(raw : Dictionary) -> ShapeData:
	var data := ShapeData.new()
	data.vertices = raw["vertices"]
	data.edges.assign(raw["edges"])
	data.faces.assign(raw["faces"])
	return data


# Rotators. rotate() has to be overridden too: the GDScript versions call
# super._rotate_shape(), which would skip the override below.

class CppRotator3D extends Rotator3D:
	var _cpp = ClassDB.instantiate("NativeRotator")

	func rotate(shape: Array, angle: float, plane: Enums.PLANES):
		_rotate_shape(shape, angle, supported_planes[plane])

	func _rotate_shape(shape: Array, angle: float, plane: Array):
		_cpp.rotate_shape(shape, angle, plane[0], plane[1])

	func get_rotation_matrix(dim: int, i: int, j: int, angle: float) -> Array:
		return _cpp.get_rotation_matrix(dim, i, j, angle)

class CppRotator4D extends Rotator4D:
	var _cpp = ClassDB.instantiate("NativeRotator")

	func rotate(shape: Array, angle: float, plane: Enums.PLANES):
		_rotate_shape(shape, angle, supported_planes[plane])

	func _rotate_shape(shape: Array, angle: float, plane: Array):
		_cpp.rotate_shape(shape, angle, plane[0], plane[1])

	func get_rotation_matrix(dim: int, i: int, j: int, angle: float) -> Array:
		return _cpp.get_rotation_matrix(dim, i, j, angle)

class CppRotator5D extends Rotator5D:
	var _cpp = ClassDB.instantiate("NativeRotator")

	func rotate(shape: Array, angle: float, plane: Enums.PLANES):
		_rotate_shape(shape, angle, supported_planes[plane])

	func _rotate_shape(shape: Array, angle: float, plane: Array):
		_cpp.rotate_shape(shape, angle, plane[0], plane[1])

	func get_rotation_matrix(dim: int, i: int, j: int, angle: float) -> Array:
		return _cpp.get_rotation_matrix(dim, i, j, angle)


# Projections

class CppDummy3DProjection extends Dummy3DProjection:
	var _cpp = ClassDB.instantiate("NativeProjector")

	func project(shape : Array) -> Array:
		return _cpp.project_orthographic(shape)

class CppOrthographic4DProjection extends Orthographic4DProjection:
	var _cpp = ClassDB.instantiate("NativeProjector")

	func project(shape : Array) -> Array:
		return _cpp.project_orthographic(shape)

class CppOrthographic5DProjection extends Orthographic5DProjection:
	var _cpp = ClassDB.instantiate("NativeProjector")

	func project(shape : Array) -> Array:
		return _cpp.project_orthographic(shape)

class CppPerspective4DProjection extends Perspective4DProjection:
	var _cpp = ClassDB.instantiate("NativeProjector")

	func project(shape : Array) -> Array:
		return _cpp.project_perspective_4d(shape, w_distance, fov_scale)

class CppPerspective5DProjection extends Perspective5DProjection:
	var _cpp = ClassDB.instantiate("NativeProjector")

	func project(shape : Array) -> Array:
		return _cpp.project_perspective_5d(shape, v_distance, w_distance, fov_scale)


# Shapes

class CppCube3D extends Cube3D:
	var _cpp = ClassDB.instantiate("NativeShapes")

	func create_shape() -> ShapeData:
		return NativeBackend.to_shape_data(_cpp.cube(3, size))

class CppCube4D extends Cube4D:
	var _cpp = ClassDB.instantiate("NativeShapes")

	func create_shape() -> ShapeData:
		return NativeBackend.to_shape_data(_cpp.cube(4, size))

class CppCube5D extends Cube5D:
	var _cpp = ClassDB.instantiate("NativeShapes")

	func create_shape() -> ShapeData:
		return NativeBackend.to_shape_data(_cpp.cube(5, size))

class CppPyramid3D extends Pyramid3D:
	var _cpp = ClassDB.instantiate("NativeShapes")

	func create_shape() -> ShapeData:
		return NativeBackend.to_shape_data(_cpp.pyramid(3, size, height_proportion))

class CppPyramid4D extends Pyramid4D:
	var _cpp = ClassDB.instantiate("NativeShapes")

	func create_shape() -> ShapeData:
		return NativeBackend.to_shape_data(_cpp.pyramid(4, size, height_proportion))
