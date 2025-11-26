extends Node

var default_rotator3D : BaseRotator = Rotator3D.new()
var default_rotator4D : BaseRotator = Rotator4D.new()
var default_rotator5D : BaseRotator = Rotator5D.new()

var default_projector3d : ProjectionStrategy = Dummy3DProjection.new()
var default_projector4d : ProjectionStrategy = Perspective4DProjection.new()
var default_projector5d  : ProjectionStrategy = Perspective5DProjection.new()

var perspective_projector4d : ProjectionStrategy = Perspective4DProjection.new()
var perspective_projector5d : ProjectionStrategy = Perspective5DProjection.new()


var shape_map : Dictionary = {
	"Cube" : {
		"3D" : [Cube3D.new(), default_rotator3D, default_projector3d], 
		"4D" : [Cube4D.new(), default_rotator4D, default_projector4d], 
		"5D" : [Cube5D.new(), default_rotator5D, default_projector5d]
		},
	"Pyramid" : {
		"3D" : [Pyramid3D.new(), default_rotator3D, default_projector3d],
		"4D" : [Pyramid4D.new(), default_rotator4D, default_projector4d]
		}
}
