extends Node

var default_rotator3D : BaseRotator = Rotator3D.new()
var default_rotator4D : BaseRotator = Rotator4D.new()
var default_rotator5D : BaseRotator = Rotator5D.new()

var default_projector3d : ProjectionStrategy = Dummy3DProjection.new()
var default_projector4d : ProjectionStrategy = Perspective4DProjection.new()
var default_projector5d  : ProjectionStrategy = Perspective5DProjection.new()


var shape_map : Dictionary = {
	"Cube" : {"3D" : Cube3D.new(), "4D" : Cube4D.new(), "5D" : Cube5D.new()},
	"Pyramid" : {"3D" : Pyramid3D.new(), "4D" : Pyramid4D.new()}
}

var shape_dimension_map : Dictionary = {
	"Cube" : {"3D" : [default_rotator3D, default_projector3d], "4D" : [default_rotator4D, default_projector4d], "5D" : [default_rotator5D, default_projector5d]},
	"Pyramid" : {"3D" : [default_rotator3D, default_projector3d], "4D" : [default_rotator4D, default_projector4d]}
}

func _init() -> void:
	var map_shapes = shape_map.keys()
	var dim_map_shapes = shape_dimension_map.keys()

	if map_shapes.size() != dim_map_shapes.size() or map_shapes.any(func(k): return not dim_map_shapes.has(k)):
		push_error("Initialization Error: Top-level shape keys do not match between shape_map and shape_dimension_map.")
		return

	for shape in map_shapes:
		var map_dimensions = shape_map[shape].keys()
		var dim_map_dimensions = shape_dimension_map[shape].keys()
		
		if map_dimensions.size() != dim_map_dimensions.size() or map_dimensions.any(func(k): return not dim_map_dimensions.has(k)):
			push_error("Initialization Error: Second-level dimension keys for shape '%s' do not match." % shape)
			return
			
	print("Initialization Check Passed: Both shape_map and shape_dimension_map are consistent.")
