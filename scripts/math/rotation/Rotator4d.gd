extends BaseRotator

class_name Rotator4D

static var supported_planes = {
	Enums.PLANES.XY: [0, 1],
	Enums.PLANES.XZ: [0, 2],
	Enums.PLANES.YZ: [1, 2],
	Enums.PLANES.XW: [0, 3],
	Enums.PLANES.YW: [1, 3],
	Enums.PLANES.ZW: [2, 3],
}

static func rotate(shape: Array, angle: float, plane: Enums.PLANES):
	assert(plane in supported_planes)
	assert(typeof(shape[0]) == TYPE_VECTOR4, "Shape must consist of Vector4 points.")
	super._rotate_shape(shape, angle, supported_planes[plane])
