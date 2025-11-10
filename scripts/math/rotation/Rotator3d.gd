extends BaseRotator

class_name Rotator3D

static var supported_planes = {
	Enums.PLANES.XY: [0, 1],
	Enums.PLANES.XZ: [0, 2],
	Enums.PLANES.YZ: [1, 2]
}

static func rotate(shape: Array, angle: float, plane: Enums.PLANES):
	assert(plane in supported_planes)
	assert(typeof(shape[0]) == TYPE_VECTOR3, "Shape must consist of Vector3 points.")
	super._rotate_shape(shape, angle, supported_planes[plane])
