extends ShapeStrategy

class_name Pyramid3D

var height_proportion : float

func _init():
	height_proportion = 2.0 # Default height proportion

func set_height_proportion(new_value : float) -> void:
	height_proportion = new_value

func create_shape() -> ShapeData:
	var data = ShapeData.new()
	var s := size
	var h := size * height_proportion
	var apex_y := -s + h

	data.vertices = [
		Vector3(0, apex_y, 0),
		Vector3(-s, -s, -s),
		Vector3(s, -s, -s),
		Vector3(s, -s, s),
		Vector3(-s, -s, s),
	]

	data.edges = [
		Vector2i(1, 2), Vector2i(2, 3), Vector2i(3, 4), Vector2i(4, 1),
		Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3), Vector2i(0, 4)
	]
	
	data.faces = [
		[1, 4, 3, 2], # Base (Quad)
		[0, 1, 2],    # Side Back
		[0, 2, 3],    # Side Right
		[0, 3, 4],    # Side Front
		[0, 4, 1]     # Side Left
	]
	
	return data
