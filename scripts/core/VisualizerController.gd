extends Node

var current_shape_data: ShapeData

var master_vertices: Array = [] 

var current_vertices_copy: Array = [] 

var rotator: BaseRotator
var projector: ProjectionStrategy
var shape_strategy: ShapeStrategy

@export var rotation_speed: float = 1.0
@export var is_rotating: bool = false
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

# The ones actively rotating
var active_planes : Dictionary = {
	Enums.PLANES.XY: 0,
	Enums.PLANES.XZ: 0,
	Enums.PLANES.YZ: 0
}

func _ready():
	if not shape_strategy:
		set_initial_state()

func _process(delta):
	if current_vertices_copy.is_empty(): return
	
	if shape_strategy.has_method("set_height_proportion"):
		shape_strategy.set_height_proportion(height_proportion)

	if is_rotating:
		rotator._rotate_shape(current_vertices_copy, delta * rotation_speed, active_plane)

	var projected_3d_points = projector.project(current_vertices_copy)
	
	_selection_info[SELECTED_VERTICES] = _selected_vertex_indices
	_selection_info[SELECTED_EDGES] = _highlited_edge_indices
	
	Renderer.update_visuals(
		projected_3d_points, 
		current_shape_data.edges, 
		current_shape_data.faces,
		_selection_info
	)
	
	for plane in active_planes:
		var speed = active_planes[plane]
		rotate_shape(speed, plane)
	

func set_initial_state() -> void:
	shape_strategy = ShapeMap.shape_map["Cube"]["3D"][Enums.ShapeDataRetriever.ShapeStrategyIndex]
	rotator =  ShapeMap.shape_map["Cube"]["3D"][Enums.ShapeDataRetriever.RotatorIndex]
	projector = ShapeMap.shape_map["Cube"]["3D"][Enums.ShapeDataRetriever.ProjectorIndex]
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
	
	var sorted_planes = active_slider_values.keys()
	sorted_planes.sort() 

	for p in sorted_planes:
		var val = active_slider_values[p]
		if not is_zero_approx(val):
			rotator.rotate(current_vertices_copy, val, p)          

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

func _generate_new_shape():
	current_shape_data = shape_strategy.create_shape()
	
	master_vertices = current_shape_data.vertices.duplicate(true)
	
	current_vertices_copy = master_vertices.duplicate(true)
	
	active_slider_values.clear()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var viewport_mouse_pos = get_viewport().get_mouse_position()
			_handle_select(viewport_mouse_pos)
		
func _handle_select(mouse_pos : Vector2) -> void:
	var current_points = projector.project(current_vertices_copy)
	
	for i in range(current_points.size()):
		var point_3d = current_points[i]

		if camera.is_position_behind(point_3d): 
			continue
			
		var point_2d = camera.unproject_position(point_3d)
		var distance_to_mouse = mouse_pos.distance_to(point_2d)

		if distance_to_mouse <= selection_radius:
			if _selected_vertex_indices.has(i):
				_selected_vertex_indices.erase(i)
			else:
				_selected_vertex_indices[i] = true
	_update_edges()


func _update_edges():
	_highlited_edge_indices.clear()
	
	for edge in current_shape_data.edges:
		if _selected_vertex_indices.has(edge.x) or _selected_vertex_indices.has(edge.y):
			_highlited_edge_indices[edge] = true

func rotate_shape(angle: float, plane: Enums.PLANES) -> void:
	rotator._rotate_shape(current_vertices_copy, angle, ShapeMap.planes_array_map[plane])
	
	
func set_speed_in_plane(plane : Enums.PLANES, speed : float) -> void:
	active_planes[plane]=speed
	
func reset_speeds() -> void:
	for plane in active_planes:
		active_planes[plane] = 0
		

# --- Sub-Objective 6: Save Screenshot Futureproofing ---
func save_visualization():
	var img = get_viewport().get_texture().get_image()
	var time = Time.get_datetime_string_from_system().replace(":", "-")
	img.save_png("user://shape_" + time + ".png")
