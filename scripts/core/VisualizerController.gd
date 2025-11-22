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

@onready var renderer: ShapeRenderer = $Renderer

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
	# TODO: We would need to have this controlled by UI
	# Probably add them to a map and get based on passed parameters
	shape_strategy = Cube3D.new()
	projector = Dummy3DProjection.new()
	rotator = Rotator3D.new()

	_generate_new_shape()

func _process(delta):
	if current_vertices_copy.is_empty(): return
	
	if shape_strategy.has_method("set_height_proportion"):
		shape_strategy.set_height_proportion(height_proportion)

	if is_rotating:
		rotator._rotate_shape(current_vertices_copy, delta * rotation_speed, active_plane)

	var projected_3d_points = projector.project(current_vertices_copy)

	renderer.update_visuals(
		projected_3d_points, 
		current_shape_data.edges, 
		current_shape_data.faces
	)

func _generate_new_shape():
	current_shape_data = shape_strategy.create_shape()
	current_vertices_copy = current_shape_data.vertices.duplicate(true)


# --- Sub-Objective 6: Save Screenshot Futureproofing ---
func save_visualization():
	var img = get_viewport().get_texture().get_image()
	var time = Time.get_datetime_string_from_system().replace(":", "-")
	
	img.save_png("user://shape_" + time + ".png")
