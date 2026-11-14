extends Node

const CONFIG_PATH = "res://configs/shapes_config.json"

var shape_properties_map : Dictionary = {}

# Emitted after set_native_backend() swaps the GDScript and C++ strategy sets.
signal backend_changed(use_native : bool)

# The strategies in use right now. They come either from the GDScript set or from the
# C++ set (scripts/native/NativeBackend.gd); see _apply_set().
var default_rotator3D : BaseRotator
var default_rotator4D : BaseRotator
var default_rotator5D : BaseRotator

var default_projector3d : ProjectionStrategy
var default_projector4d : ProjectionStrategy
var default_projector5d  : ProjectionStrategy

var perspective_projector4d : ProjectionStrategy
var perspective_projector5d : ProjectionStrategy

var shape_map : Dictionary = {}

var use_native : bool = false
var _gdscript_set : Dictionary = {}
var _native_set : Dictionary = {}
# Strategy -> the object with the same role in the other set (both directions).
var _counterparts : Dictionary = {}

# State that has to follow a strategy when it is swapped for its counterpart.
const SWAPPED_STATE : Array[String] = ["size", "height_proportion", "w_distance", "v_distance", "fov_scale", "current_size"]

var planes_array_map = {
	Enums.PLANES.XY: [0, 1],
	Enums.PLANES.XZ: [0, 2],
	Enums.PLANES.YZ: [1, 2],
	Enums.PLANES.XW: [0, 3],
	Enums.PLANES.YW: [1, 3],
	Enums.PLANES.ZW: [2, 3],
	Enums.PLANES.XV: [0, 4],
	Enums.PLANES.YV: [1, 4],
	Enums.PLANES.ZV: [2, 4],
	Enums.PLANES.WV: [3, 4],
}

func _init() -> void:
	_gdscript_set = build_gdscript_set()
	_apply_set(_gdscript_set)
	load_config()

static func build_gdscript_set() -> Dictionary:
	return {
		"rotator3D": Rotator3D.new(),
		"rotator4D": Rotator4D.new(),
		"rotator5D": Rotator5D.new(),
		"projector3d": Dummy3DProjection.new(),
		"projector4d": Orthographic4DProjection.new(),
		"projector5d": Orthographic5DProjection.new(),
		"perspective4d": Perspective4DProjection.new(),
		"perspective5d": Perspective5DProjection.new(),
		"cube3D": Cube3D.new(),
		"cube4D": Cube4D.new(),
		"cube5D": Cube5D.new(),
		"pyramid3D": Pyramid3D.new(),
		"pyramid4D": Pyramid4D.new(),
	}

func _apply_set(strategies : Dictionary) -> void:
	default_rotator3D = strategies["rotator3D"]
	default_rotator4D = strategies["rotator4D"]
	default_rotator5D = strategies["rotator5D"]

	default_projector3d = strategies["projector3d"]
	default_projector4d = strategies["projector4d"]
	default_projector5d = strategies["projector5d"]

	perspective_projector4d = strategies["perspective4d"]
	perspective_projector5d = strategies["perspective5d"]

	shape_map = {
		"Cube" : {
			"3D" : [strategies["cube3D"], default_rotator3D, default_projector3d],
			"4D" : [strategies["cube4D"], default_rotator4D, default_projector4d],
			"5D" : [strategies["cube5D"], default_rotator5D, default_projector5d]
			},
		"Pyramid" : {
			"3D" : [strategies["pyramid3D"], default_rotator3D, default_projector3d],
			"4D" : [strategies["pyramid4D"], default_rotator4D, default_projector4d]
			}
	}

# Switches every strategy between the GDScript classes and the C++ GDExtension.
# Does nothing (apart from a warning) when the extension isn't loaded.
func set_native_backend(enabled : bool) -> void:
	if enabled == use_native:
		return
	if enabled and not NativeBackend.is_available():
		push_warning("The C++ extension (bin/native_math.gdextension) isn't loaded; staying on GDScript.")
		return

	if enabled and _native_set.is_empty():
		_native_set = NativeBackend.build_strategy_set()
		for key in _gdscript_set:
			# A strategy with no C++ version (e.g. a newly added shape) keeps using GDScript.
			if not _native_set.has(key):
				_native_set[key] = _gdscript_set[key]
				continue
			_counterparts[_gdscript_set[key]] = _native_set[key]
			_counterparts[_native_set[key]] = _gdscript_set[key]

	use_native = enabled
	_apply_set(_native_set if enabled else _gdscript_set)
	backend_changed.emit(enabled)

# Returns the strategy with the same role in the other backend, carrying over its size and
# projection distances. Anything ShapeMap doesn't know about is returned unchanged.
func counterpart_of(strategy : Object) -> Object:
	if strategy == null or not _counterparts.has(strategy):
		return strategy

	var other : Object = _counterparts[strategy]
	for property in SWAPPED_STATE:
		if property in strategy and property in other:
			other.set(property, strategy.get(property))
	return other

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

# Validates the external JSON configuration against the internal hardcoded logic map.
# 
# ==========!LEGACY!==========: Early in the development users were supposed to manually
# trigger and adjust V and W projection distances via sliders (and also were supposed to have different sizes/steps).
# The JSON schema was built to enforce strict [min, max, step] array rules for these sliders.
# This was eventually cut for simplicity. While the array validation is still
# present, the primary practical value of this function today is simply to ensure
# strict rules for adding new shape.

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
