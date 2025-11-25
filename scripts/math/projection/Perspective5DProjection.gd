extends ProjectionStrategy

class_name Perspective5DProjection

# Distance of 4D camera to XYZ world along the w axis.
@export var w_distance := 12.0 
# Distance of 5D camera to XYZW world along the V axis.
@export var v_distance := 12.0
@export var fov_scale := 600.0

func project(shape: Array) -> Array:
	assert(shape.size() > 0, "Empty shape passed to 5D projection.")
	
	var projected_4d_shape = []
	var projected = []
	
	for point in shape:
		var div = v_distance - point[4]
		if div <= 0.001: div = 0.001

		var v_factor = 1.0 / div 
		
		projected_4d_shape.append(Vector4(
			point[0] * v_factor, 
			point[1] * v_factor, 
			point[2] * v_factor, 
			point[3] * v_factor
		))

	for point in projected_4d_shape:
		var div = w_distance - point.w
		if div <= 0.001: div = 0.001
	   
		var w_factor = fov_scale / div 
		
		projected.append(Vector3(
			point.x * w_factor, 
			point.y * w_factor, 
			point.z * w_factor
		))
		
	return projected


func adjust_w_distance_to_new_size(new_size: int):
	w_distance = new_size * sqrt(2)
	
func adjust_v_distance_to_new_size(new_size: int):
	v_distance = new_size * sqrt(2)
