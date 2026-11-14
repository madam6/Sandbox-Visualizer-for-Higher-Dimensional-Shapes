extends Control

# Compares the GDScript maths (scripts/math) with the C++ GDExtension (extension/src).
#
# Open scenes/tests/benchmark.tscn and press F6, or run it without a window:
#   godot --headless --path . res://scenes/tests/benchmark.tscn
#
# For every shape it first checks that both versions produce the same vertices, edges,
# faces, rotations and projections, then times them. Results go to the Output panel
# and onto the screen.

const FRAME_ITERATIONS : int = 300   # one "frame" = rotate in every plane, then project
const BUILD_ITERATIONS : int = 200   # create_shape() calls
const CLOUD_POINTS : int = 5000      # random points for the large-input test
const TOLERANCE : float = 1e-4

# [label, shape key, rotator key, projector key]
# Keys are the ones used by ShapeMap.build_gdscript_set() and NativeBackend.build_strategy_set().
const CASES : Array = [
	["Cube 3D", "cube3D", "rotator3D", "projector3d"],
	["Pyramid 3D", "pyramid3D", "rotator3D", "projector3d"],
	["Cube 4D", "cube4D", "rotator4D", "perspective4d"],
	["Pyramid 4D", "pyramid4D", "rotator4D", "perspective4d"],
	["Cube 5D", "cube5D", "rotator5D", "perspective5d"],
]

var _gd : Dictionary
var _cpp : Dictionary
var _output : Label
var _all_match : bool = true

func _ready() -> void:
	_build_output_label()

	if not NativeBackend.is_available():
		_log("The C++ extension isn't loaded, so there is nothing to compare.")
		_log("Build it first: cd extension && scons platform=windows target=template_debug")
		_finish()
		return

	_gd = ShapeMap.build_gdscript_set()
	_cpp = NativeBackend.build_strategy_set()

	_log("GDScript vs C++ (GDExtension). Times are averages per call, in microseconds.")
	_log("Engine %s, %s build\n" % [Engine.get_version_info()["string"], "debug" if OS.is_debug_build() else "release"])
	_log("%-12s %-18s %-6s %10s %10s %9s" % ["shape", "operation", "same?", "GDScript", "C++", "speed-up"])

	for case in CASES:
		_run_case(case[0], case[1], case[2], case[3])
	_run_point_cloud()

	_log("\n%s" % ("Both versions gave the same results in every test." if _all_match else "MISMATCH: see the rows marked NO."))
	_finish()

func _run_case(label : String, shape_key : String, rotator_key : String, projector_key : String) -> void:
	var gd_shape : ShapeStrategy = _gd[shape_key]
	var cpp_shape : ShapeStrategy = _cpp[shape_key]
	var gd_rotator : BaseRotator = _gd[rotator_key]
	var cpp_rotator : BaseRotator = _cpp[rotator_key]
	var gd_projector : ProjectionStrategy = _gd[projector_key]
	var cpp_projector : ProjectionStrategy = _cpp[projector_key]

	# Building the shape
	var gd_data := gd_shape.create_shape()
	var cpp_data := cpp_shape.create_shape()
	var same_shape := _points_match(gd_data.vertices, cpp_data.vertices) \
		and gd_data.edges == cpp_data.edges and gd_data.faces == cpp_data.faces
	_report(label, "create_shape", same_shape,
		_time_usec(BUILD_ITERATIONS, func(): gd_shape.create_shape()),
		_time_usec(BUILD_ITERATIONS, func(): cpp_shape.create_shape()))

	# One frame as VisualizerController does it: rotate in every plane, then project.
	var planes : Array = gd_rotator.supported_planes.keys()
	var gd_points : Array = gd_data.vertices.duplicate(true)
	var cpp_points : Array = gd_data.vertices.duplicate(true)
	for plane in planes:
		gd_rotator.rotate(gd_points, 10.0 + plane * 7.0, plane)
		cpp_rotator.rotate(cpp_points, 10.0 + plane * 7.0, plane)
	var same_frame := _points_match(gd_points, cpp_points) \
		and _points_match(gd_projector.project(gd_points), cpp_projector.project(cpp_points))

	var gd_frame := func():
		for plane in planes:
			gd_rotator.rotate(gd_points, 0.5, plane)
		gd_projector.project(gd_points)
	var cpp_frame := func():
		for plane in planes:
			cpp_rotator.rotate(cpp_points, 0.5, plane)
		cpp_projector.project(cpp_points)
	_report(label, "frame (%d planes)" % planes.size(), same_frame,
		_time_usec(FRAME_ITERATIONS, gd_frame),
		_time_usec(FRAME_ITERATIONS, cpp_frame))

# The real shapes have at most 32 vertices. This shows what happens with far more points.
func _run_point_cloud() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 4
	var cloud : Array = []
	for i in CLOUD_POINTS:
		cloud.append(Vector4(rng.randf_range(-5, 5), rng.randf_range(-5, 5), rng.randf_range(-5, 5), rng.randf_range(-5, 5)))

	var gd_rotator : BaseRotator = _gd["rotator4D"]
	var cpp_rotator : BaseRotator = _cpp["rotator4D"]
	var gd_projector : ProjectionStrategy = _gd["perspective4d"]
	var cpp_projector : ProjectionStrategy = _cpp["perspective4d"]

	var gd_points := cloud.duplicate()
	var cpp_points := cloud.duplicate()
	gd_rotator.rotate(gd_points, 30.0, Enums.PLANES.XW)
	cpp_rotator.rotate(cpp_points, 30.0, Enums.PLANES.XW)
	var same := _points_match(gd_points, cpp_points) \
		and _points_match(gd_projector.project(gd_points), cpp_projector.project(cpp_points))

	var gd_step := func():
		gd_rotator.rotate(gd_points, 0.5, Enums.PLANES.XW)
		gd_projector.project(gd_points)
	var cpp_step := func():
		cpp_rotator.rotate(cpp_points, 0.5, Enums.PLANES.XW)
		cpp_projector.project(cpp_points)
	_report("%d pts 4D" % CLOUD_POINTS, "rotate+project", same, _time_usec(5, gd_step), _time_usec(5, cpp_step))

func _time_usec(iterations : int, body : Callable) -> float:
	var start := Time.get_ticks_usec()
	for i in iterations:
		body.call()
	return float(Time.get_ticks_usec() - start) / iterations

# Points can be Vector3, Vector4 or 5-element Arrays, depending on the dimension.
func _points_match(a : Array, b : Array) -> bool:
	if a.size() != b.size():
		return false
	for i in a.size():
		var p = a[i]
		var q = b[i]
		if typeof(p) != typeof(q):
			return false
		if typeof(p) == TYPE_ARRAY:
			if p.size() != q.size():
				return false
			for k in p.size():
				if absf(p[k] - q[k]) > TOLERANCE:
					return false
		elif (p - q).length() > TOLERANCE:
			return false
	return true

func _report(label : String, operation : String, same : bool, gd_usec : float, cpp_usec : float) -> void:
	_all_match = _all_match and same
	var speed_up := gd_usec / maxf(cpp_usec, 0.001)
	_log("%-12s %-18s %-6s %10.1f %10.1f %8.1fx" % [label, operation, "yes" if same else "NO", gd_usec, cpp_usec, speed_up])

func _log(line : String) -> void:
	print(line)
	_output.text += line + "\n"

func _build_output_label() -> void:
	var background := ColorRect.new()
	background.color = Color(0.13, 0.15, 0.17)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var mono := SystemFont.new()
	mono.font_names = PackedStringArray(["Consolas", "DejaVu Sans Mono", "Courier New", "monospace"])

	_output = Label.new()
	_output.position = Vector2(40, 40)
	_output.add_theme_font_override("font", mono)
	_output.add_theme_font_size_override("font_size", 18)
	add_child(_output)

func _finish() -> void:
	if DisplayServer.get_name() == "headless":
		get_tree().quit()
