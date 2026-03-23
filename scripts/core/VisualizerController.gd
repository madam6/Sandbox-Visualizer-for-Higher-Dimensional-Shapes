extends Node

var current_shape_data : ShapeData
var master_vertices : Array = [] 
var current_vertices_copy : Array = [] 

var axes_master : Array = []
var axes_copy : Array = []
var show_axes : bool = false

var rotator : BaseRotator
var projector : ProjectionStrategy
var shape_strategy : ShapeStrategy

@export var rotation_speed : float = 1.0
@export var is_rotating : bool = false
@export var active_plane = ShapeMap.planes_array_map[Enums.PLANES.XY]
@export var shape_size = 5.0
@export var height_proportion = 1.5
@export var selection_radius = 30 # In pixels
@export var camera : Camera3D

var active_slider_values : Dictionary = {}
var continuous_rotation : bool = false

var _selected_vertex_indices : Dictionary
var _highlited_edge_indices : Dictionary
var _selection_info : Dictionary

var SELECTED_VERTICES : String = "vertex_indices"
var SELECTED_EDGES : String = "edge_indices"

var is_override_active : bool = false


var processing_mutex : bool = false


var axes_size : float = 20
const axes_size_factor : float = 3
# The ones actively rotating
var active_planes : Dictionary = {
	Enums.PLANES.XY: 0,
	Enums.PLANES.XZ: 0,
	Enums.PLANES.YZ: 0
}

func _ready():
	if not shape_strategy:
		set_initial_state()

# Main engine loop
# Executes rotation, projection and rendering dispatch
# This bypasses Godot'standard physics and tranform systems
func _process(delta):
	if not processing_mutex: return
	if current_vertices_copy.is_empty(): return
	
	if shape_strategy.has_method("set_height_proportion"):
		shape_strategy.set_height_proportion(height_proportion)

	# Part 1: Rotation

	# Apply continuous automatic rotation (speed based)
	if is_rotating:
		var step = delta * rotation_speed
		rotator._rotate_shape(current_vertices_copy, step, active_plane)

		if show_axes and not axes_copy.is_empty():
			rotator._rotate_shape(axes_copy, step, active_plane)
	
	# Apply manual slider rotations (angle based)
	for plane in active_planes:
		var speed = active_planes[plane]
		rotate_shape(speed, plane)


	# Part 2: Projection

	# Projection/render call of coordinate axes shape
	if show_axes and not axes_copy.is_empty():
		update_axes_size()

		var dim = get_current_dimension()
		var axes_projector : ProjectionStrategy
		match dim:
			3: axes_projector = ShapeMap.default_projector3d
			4: axes_projector = ShapeMap.default_projector4d
			5: axes_projector = ShapeMap.default_projector5d

		var projected_axes = axes_projector.project(axes_copy)

		var rotating_planes = []

		if is_rotating:
			for key in ShapeMap.planes_array_map:
				if ShapeMap.planes_array_map[key] == active_plane:
					rotating_planes.append(key)
					break

		for p in active_slider_values:
			if not is_zero_approx(active_slider_values[p]):
				rotating_planes.append(p)

		for p in active_planes:
			if not is_zero_approx(active_planes[p]):
				if not p in rotating_planes:
					rotating_planes.append(p)

		Renderer.draw_axes(projected_axes, rotating_planes)

	# Flatten the N-dimensional shape coordinates into renderable 3D space
	var projected_3d_points = projector.project(current_vertices_copy)
	
	_selection_info[SELECTED_VERTICES] = _selected_vertex_indices
	_selection_info[SELECTED_EDGES] = _highlited_edge_indices
	
	# Part 3: Render dispath
	# Passing the flattened 3D coordinates over to ShapeRenderer
	Renderer.update_visuals(
		projected_3d_points, 
		current_shape_data.edges, 
		current_shape_data.faces,
		_selection_info
	)


func update_axes_size() -> void:
	axes_size = shape_size * axes_size_factor

func update_animated_vertices(new_verticies : Array) -> void:
	master_vertices = new_verticies.duplicate(true)
	current_vertices_copy = master_vertices.duplicate(true)

func set_initial_state() -> void:
	shape_strategy = ShapeMap.shape_map["Cube"]["3D"][Enums.ShapeDataRetriever.ShapeStrategyIndex]
	rotator =  ShapeMap.shape_map["Cube"]["3D"][Enums.ShapeDataRetriever.RotatorIndex]
	projector = ShapeMap.shape_map["Cube"]["3D"][Enums.ShapeDataRetriever.ProjectorIndex]
	sync_active_planes()
	_generate_new_shape()

func set_init_lab_state() -> void:
	shape_strategy = ShapeMap.shape_map["Cube"]["4D"][Enums.ShapeDataRetriever.ShapeStrategyIndex]
	rotator =  ShapeMap.shape_map["Cube"]["4D"][Enums.ShapeDataRetriever.RotatorIndex]
	projector = ShapeMap.perspective_projector4d
	_generate_new_shape()

func set_lesson_tesseract() -> void:
	shape_strategy = ShapeMap.shape_map["Cube"]["4D"][Enums.ShapeDataRetriever.ShapeStrategyIndex]
	rotator =  ShapeMap.shape_map["Cube"]["4D"][Enums.ShapeDataRetriever.RotatorIndex]
	projector = ShapeMap.perspective_projector4d
	_generate_new_shape()

func sync_active_planes() -> void:
	var target_planes = rotator.supported_planes.keys()
	
	for key in active_planes.keys():
		if not key in target_planes:
			active_planes.erase(key)
			
	for key in target_planes:
		if not active_planes.has(key):
			active_planes[key] = 0

func reset_rotation() -> void:
	for plane in active_planes:
		rotate_shape_absolute(0, plane)

func reset_selection_info() -> void:
	_selected_vertex_indices.clear()
	_highlited_edge_indices.clear()
	_selection_info.clear()
	
func reset_controller() -> void:
	sync_active_planes()
	reset_rotation()
	reset_speeds()
	reset_selection_info()

func set_3d_mode() -> void:
	rotator =  ShapeMap.shape_map["Cube"]["3D"][Enums.ShapeDataRetriever.RotatorIndex]
	projector = ShapeMap.shape_map["Cube"]["3D"][Enums.ShapeDataRetriever.ProjectorIndex]

func set_override_shape(new_data : ShapeData) -> void:
	is_override_active = true
	current_shape_data = new_data
	master_vertices = current_shape_data.vertices.duplicate(true)
	current_vertices_copy = master_vertices.duplicate(true)
	active_slider_values.clear()
	reset_rotation()
	
func clear_override_mode() -> void:
	is_override_active = false
	_generate_new_shape()

func rotate_shape_absolute(angle: float, plane: int):
	active_slider_values[plane] = angle

	current_vertices_copy = master_vertices.duplicate(true)
	axes_copy = axes_master.duplicate(true)

	var sorted_planes = active_slider_values.keys()
	sorted_planes.sort() 

	for p in sorted_planes:
		var val = active_slider_values[p]
		if not is_zero_approx(val):
			rotator.rotate(current_vertices_copy, val, p)
			if show_axes:
				rotator.rotate(axes_copy, val, p)        

func update_shape_settings(new_strategy: ShapeStrategy, new_rotator: BaseRotator, new_projector: ProjectionStrategy) -> void:
	if is_override_active:
		return
	
	shape_strategy = new_strategy
	rotator = new_rotator
	projector = new_projector
	
	set_shape_size(shape_size)

	sync_active_planes()
	_generate_new_shape()
	

func set_shape_size(new_shape_size : float) -> void:
	shape_size = new_shape_size
	shape_strategy.set_size(new_shape_size)
	update_axes_size()

	if projector.has_method("adjust_w_distance_to_new_size"):
		projector.adjust_w_distance_to_new_size(new_shape_size)
		
	if projector.has_method("adjust_v_distance_to_new_size"):
		projector.adjust_v_distance_to_new_size(new_shape_size)
		
	_generate_new_shape()

func set_rotation_speed(new_rotation_speed: float) -> void:
	rotation_speed = new_rotation_speed

func get_current_projector() -> ProjectionStrategy:
	return projector

func get_current_rotator() -> BaseRotator:
	return rotator
	
func set_new_projector(new_projector : ProjectionStrategy) -> void:
	projector = new_projector

func set_new_rotator(new_rotator : BaseRotator) -> void:
	rotator = new_rotator

func _generate_new_shape() -> void:
	current_shape_data = shape_strategy.create_shape()
	
	master_vertices = current_shape_data.vertices.duplicate(true)
	
	current_vertices_copy = master_vertices.duplicate(true)
	
	active_slider_values.clear()
	_generate_axes()

func _generate_axes() -> void:
	if not shape_strategy: return

	var dim = get_current_dimension()

	var axes_data = BasisAxes.create(dim, axes_size)
	axes_master = axes_data.vertices
	axes_copy = axes_master.duplicate(true)
	_apply_static_rotations_to_axes()

func _apply_static_rotations_to_axes() -> void:
	if axes_master.is_empty() : return

	axes_copy = axes_master.duplicate(true)
	var sorted_planes = active_slider_values.keys()
	sorted_planes.sort()

	for p in sorted_planes:
		var val = active_slider_values[p]
		if not is_zero_approx(val):
			rotator.rotate(axes_copy, val, p)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var viewport_mouse_pos = get_viewport().get_mouse_position()
			_handle_select(viewport_mouse_pos)

# Detects which projected vertex the user clicked on in the 2D viewport.
# Bypasses standard PhysicsServer raycasting because the our vertices 
# do not possess physical collision shapes.	
func _handle_select(mouse_pos : Vector2) -> void:
	var current_points = projector.project(current_vertices_copy)
	
	for i in range(current_points.size()):
		var point_3d = current_points[i]

		# Ignore points currently folded behind the camera lens
		if camera.is_position_behind(point_3d): 
			continue
		
		# Godot's "unproject_position" magically allows us to get 2D position on our viewport out of in world transofrm!
		var point_2d = camera.unproject_position(point_3d)
		var distance_to_mouse = mouse_pos.distance_to(point_2d)

		if distance_to_mouse <= selection_radius:
			if _selected_vertex_indices.has(i):
				_selected_vertex_indices.erase(i)
			else:
				_selected_vertex_indices[i] = true
	_update_edges()

# Maps and highlights all edges physically connected to currently selected vertices.
# The 'edges' array contains Vector2i objects where X and Y represent the indices
# of the two connected vertices. If either index exists in our selected vertex list,
# the entire edge is marked for highlighting.
func _update_edges():
	_highlited_edge_indices.clear()
	
	for edge in current_shape_data.edges:
		if _selected_vertex_indices.has(edge.x) or _selected_vertex_indices.has(edge.y):
			_highlited_edge_indices[edge] = true

func rotate_shape(angle: float, plane: Enums.PLANES) -> void:
	rotator._rotate_shape(current_vertices_copy, angle, ShapeMap.planes_array_map[plane])
	if show_axes:
		rotator._rotate_shape(axes_copy, angle, ShapeMap.planes_array_map[plane])
	
	
func set_speed_in_plane(plane : Enums.PLANES, speed : float) -> void:
	if rotator.supported_planes.has(plane):
		active_planes[plane]=speed
	
func reset_speeds() -> void:
	for plane in active_planes:
		active_planes[plane] = 0

func get_current_dimension() -> int:
	var current_rotator = get_current_rotator()
	match current_rotator.supported_planes.size():
		3 : return 3
		6 : return 4
		10 : return 5
	return -1


func toggle_axes(visible : bool) -> void:
	show_axes = visible
	if visible:
		_generate_axes()
	else:
		Renderer.draw_axes([], [])
		Renderer.hide_labels()
		

func save_visualization():
	var img = get_viewport().get_texture().get_image()
	var time = Time.get_datetime_string_from_system().replace(":", "-")
	
	var file_name = EduController.get_current_shape_name_display()+ "_" + time + ".png"

	if OS.has_feature("web"):
		var buffer = img.save_png_to_buffer()
		JavaScriptBridge.download_buffer(buffer, file_name, "image/png")
	else:
		var path = "user://" + file_name
		img.save_png(path)
		print("Screenshot saved to: ", ProjectSettings.globalize_path(path))

# Procedurally generates an n dimensional rotation matrix for a specific 2D plane.
# Instead of hardcoding matrices, this constructs a perfect identity
# and injects the sine/cosine trigonometric values specifically into the rows/columns representing the active rotating axes.
# dim: The mathematical dimension (e.g., 4 for a Tesseract).
# i: The first axis index of the plane (e.g., 0 for X).
# j: The second axis index of the plane (e.g., 3 for W).
func get_rotation_matrix_for_plane(plane_enum : int, angle_degrees : float) -> Array:
	if not rotator: return []

	var dim = get_current_dimension()

	var axes = ShapeMap.planes_array_map.get(plane_enum)
	if not axes: return []

	var angle_rad = deg_to_rad(angle_degrees)
	return rotator.get_rotation_matrix(dim, axes[0], axes[1], angle_rad)

func turn_processing_on() -> void:
	processing_mutex = true

func turn_processing_off() -> void:
	processing_mutex = false