extends Node

var current_shape_data: ShapeData

var master_vertices: Array = [] 

var current_vertices_copy: Array = [] 

var rotator: BaseRotator
var projector: ProjectionStrategy
var shape_strategy: ShapeStrategy

@export var rotation_speed: float = 1.0 # TODO: Needs to be clamped
@export var is_rotating: bool = false
@export var active_plane = ShapeMap.planes_array_map[Enums.PLANES.XY]
@export var shape_size = 1.0 # TODO: Needs to be clamped
@export var height_proportion = 1.5 # TODO: Based on UI configuration we need to figure out if we want to display this settingg

var active_slider_values : Dictionary = {}

func _ready():
	if not shape_strategy:
		shape_strategy = ShapeMap.shape_map["Cube"]["3D"][Enums.ShapeDataRetriever.ShapeStrategyIndex]
		rotator =  ShapeMap.shape_map["Cube"]["3D"][Enums.ShapeDataRetriever.RotatorIndex]
		projector = ShapeMap.shape_map["Cube"]["3D"][Enums.ShapeDataRetriever.ProjectorIndex]
		_generate_new_shape()

func _process(delta):
	if current_vertices_copy.is_empty(): return
	
	if shape_strategy.has_method("set_height_proportion"):
		shape_strategy.set_height_proportion(height_proportion)

	if is_rotating:
		rotator._rotate_shape(current_vertices_copy, delta * rotation_speed, active_plane)

	var projected_3d_points = projector.project(current_vertices_copy)

	Renderer.update_visuals(
		projected_3d_points, 
		current_shape_data.edges, 
		current_shape_data.faces
	)

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
	shape_strategy = new_strategy
	rotator = new_rotator
	projector = new_projector
	_generate_new_shape()
	
func set_shape_size(new_shape_size : float) -> void:
	shape_strategy.set_size(new_shape_size)
	if projector == ShapeMap.perspective_projector4d:
		projector.adjust_w_distance_to_new_size(new_shape_size)
	elif projector == ShapeMap.perspective_projector5d:
		projector.adjust_w_distance_to_new_size(new_shape_size)
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

func _generate_new_shape():
	current_shape_data = shape_strategy.create_shape()

	master_vertices = current_shape_data.vertices.duplicate(true)

	current_vertices_copy = master_vertices.duplicate(true)
	
	active_slider_values.clear()

func rotate_shape(angle: float, plane: Enums.PLANES) -> void:
	rotator._rotate_shape(current_vertices_copy, angle, ShapeMap.planes_array_map[plane])

# --- Sub-Objective 6: Save Screenshot Futureproofing ---
func save_visualization():
	var img = get_viewport().get_texture().get_image()
	var time = Time.get_datetime_string_from_system().replace(":", "-")
	img.save_png("user://shape_" + time + ".png")
