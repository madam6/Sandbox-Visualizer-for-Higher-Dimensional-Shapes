extends BaseRotator

class_name Rotator5D

static var supported_planes = {
	Enums.PLANES.XY: [0, 1],
	Enums.PLANES.XZ: [0, 2],
	Enums.PLANES.YZ: [1, 2],
	Enums.PLANES.XW: [0, 3],
	Enums.PLANES.YW: [1, 3],
	Enums.PLANES.ZW: [2, 3],
	Enums.PLANES.XV: [0, 4],
	Enums.PLANES.YV: [1, 4],
	Enums.PLANES.ZV: [2, 4],
	Enums.PLANES.WV: [3, 4],
}

static func rotate(shape: Array, angle: float, plane: Enums.PLANES):
	assert(shape[0].size() == 5, "Shape must consist of 5 dimensional arrays points.")
	assert(plane in supported_planes, "Unsupported plane for 5D rotation.")
	super._rotate_shape(shape, angle, supported_planes[plane])
