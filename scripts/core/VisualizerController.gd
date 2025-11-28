extends Node

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

var current_shape_data: ShapeData
var current_vertices_copy: Array = [] # Copy to rotate without destroying original

var rotator: BaseRotator
var projector: ProjectionStrategy
var shape_strategy: ShapeStrategy

@export var rotation_speed: float = 1.0 # TODO: Needs to be clamped
@export var is_rotating: bool = true
@export var active_plane = planes_array_map[Enums.PLANES.XZ]
@export var shape_size = 1.0 # TODO: Needs to be clamped
@export var height_proportion = 1.5 # TODO: Based on UI configuration we need to figure out if we want to display this settingg

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


func update_shape_settings(new_strategy: ShapeStrategy, new_rotator: BaseRotator, new_projector: ProjectionStrategy) -> void:
	is_rotating = false

	shape_strategy = new_strategy
	rotator = new_rotator
	projector = new_projector

	_generate_new_shape()
	is_rotating = true
	
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
	
func set_new_projector(new_projector : ProjectionStrategy) -> void:
	projector = new_projector

func _generate_new_shape():
	current_shape_data = shape_strategy.create_shape()
	current_vertices_copy = current_shape_data.vertices.duplicate(true)


# --- Sub-Objective 6: Save Screenshot Futureproofing ---
func save_visualization():
	var img = get_viewport().get_texture().get_image()
	var time = Time.get_datetime_string_from_system().replace(":", "-")
	
	img.save_png("user://shape_" + time + ".png")
