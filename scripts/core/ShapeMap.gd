extends Node

const CONFIG_PATH = "res://configs/shapes_config.json"

# This is a configuration map that UI system will query by looking up current active config
# shape_properties_map["Cube"]["4D"]["Perspective"] will return a map like this
# "size": [3, 25, 1],
# "w_dist": [1, 100, 1]
# where each key is the slider and values we want to show
# minvalue - maxvalue - step
var shape_properties_map : Dictionary = {}


var default_rotator3D : BaseRotator = Rotator3D.new()
var default_rotator4D : BaseRotator = Rotator4D.new()
var default_rotator5D : BaseRotator = Rotator5D.new()

var default_projector3d : ProjectionStrategy = Dummy3DProjection.new()
var default_projector4d : ProjectionStrategy = Orthographic4DProjection.new()
var default_projector5d  : ProjectionStrategy = Orthographic5DProjection.new()

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

func _init() -> void:
	load_config()

func load_config():
	if not FileAccess.file_exists(CONFIG_PATH):
		push_error("Config file missing: " + CONFIG_PATH)
		return

	var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	
	if error == OK:
		shape_properties_map = json.data
		if validate_schema(shape_map, shape_properties_map):
			print("Config loaded and validated.")
	else:
		push_error("JSON error: line " + str(json.get_error_line()))


func validate_schema(logic_map: Dictionary, ui_map: Dictionary) -> bool:
	var is_valid = true
	
	if not _compare_keys(logic_map, ui_map, "Root"): return false

	for shape_key in ui_map:
		var ui_dims = ui_map[shape_key]
		var logic_dims = logic_map[shape_key]

		if not _compare_keys(logic_dims, ui_dims, shape_key): 
			is_valid = false
			continue

		for dim_key in ui_dims:
			var config_types = ui_dims[dim_key]
			
			for config_name in config_types:
				var properties = config_types[config_name]
				
				if typeof(properties) != TYPE_DICTIONARY:
					push_error("Error: '%s/%s/%s' should be a dictionary." % [shape_key, dim_key, config_name])
					is_valid = false
					continue

				for param_key in properties:
					var range_arr = properties[param_key]

					if typeof(range_arr) != TYPE_ARRAY:
						push_error("Error: parameter '%s' in '%s' is not an array." % [param_key, config_name])
						is_valid = false
						continue

					if range_arr.size() != 3:
						push_error("Error: parameter '%s' must have 3 values [min, max, step]. Found: %s" % [param_key, str(range_arr)])
						is_valid = false

	return is_valid

func _compare_keys(dict_a, dict_b, context) -> bool:
	var k_a = dict_a.keys()
	var k_b = dict_b.keys()
	k_a.sort()
	k_b.sort()
	if k_a != k_b:
		push_error("Mismatch in %s: %s vs %s" % [context, str(k_a), str(k_b)])
		return false
	return true
