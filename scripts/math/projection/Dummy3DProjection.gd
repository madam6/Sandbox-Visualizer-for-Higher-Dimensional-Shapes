extends ProjectionStrategy

class_name Dummy3DProjection

func project(shape : Array) -> Array:
	assert(shape.size() > 0, "Empty shape passed to 3D projection.")
	#assert(typeof(shape[0]) == TYPE_VECTOR3, "Passed shape to a 3D projector does not consist of 4D Vectors")
	
	return shape
