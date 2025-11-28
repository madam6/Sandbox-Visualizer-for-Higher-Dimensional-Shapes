extends RefCounted
class_name ShapeStrategy

var size : float

func _init() -> void:
	size = 5 # First default size

func create_shape() -> ShapeData:
	push_error("ShapeStrategy.create_shape() is not implemented.")
	return ShapeData.new()
	
func set_size(new_size : float) -> void:
	size = new_size
