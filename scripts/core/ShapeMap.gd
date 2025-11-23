extends Node

var shape_map : Dictionary = {
	"Cube" : {"3D" : Cube3D.new(), "4D" : Cube4D.new(), "5D" : Cube5D.new()},
	"Pyramid" : {"3D" : Pyramid3D.new(), "4D" : Pyramid4D.new()}
}
