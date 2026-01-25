extends ProjectionStrategy

class_name Perspective4DProjection

var distance_multiplier: float = 4.0 

var size_ratio: float = 0.75

@export var w_distance := 20.0
@export var fov_scale := 15.0 

func project(shape: Array) -> Array:
	assert(shape.size() > 0, "Empty shape passed to 4D projection.")
	assert(typeof(shape[0]) == TYPE_VECTOR4, "Passed shape to a 4D projector does not consist of 4D Vectors")
	
	var projected = []
	for point in shape:
		var div = w_distance - point.w
		
		if div <= 0.001: 
			div = 0.001 
			
		var w_factor = fov_scale / div
		
		projected.append(Vector3(
			point.x * w_factor, 
			point.y * w_factor, 
			point.z * w_factor
		))
		
	return projected
	
	
func adjust_w_distance_to_new_size(new_size: float):
	w_distance = new_size * distance_multiplier
	fov_scale = w_distance * size_ratio
