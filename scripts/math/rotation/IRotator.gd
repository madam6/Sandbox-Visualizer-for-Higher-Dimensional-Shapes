extends Node

class_name IRotator

static func verify_instance(rotator : IRotator) -> void:
	if not ("supported_planes" in rotator):
		push_error(str(rotator) + " must define supported_planes")

@warning_ignore("unused_parameter")
static func _perform_rotation(point, matrix):
	assert(false, "_perform_rotation must be implemented")
	

# Internal function
@warning_ignore("unused_parameter")
static func _rotate_shape(shape: Array, angle: float, plane: Array):
	assert(false, "rotate_shape must be implemented")

# To be used by actual rotator
@warning_ignore("unused_parameter")
static func rotate(shape: Array, angle: float, plane: Enums.PLANES):
	assert(false, "rotate must be implemented")
