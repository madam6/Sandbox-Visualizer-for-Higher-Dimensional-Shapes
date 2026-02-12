extends Node3D
class_name ShapeRenderer

@export var vertex_radius: float = 0.1
@export var line_width: float = 0.05
@export var _vertex_color: Color = Color.WHITE
@export var _edge_color: Color = Color.CYAN
@export var _face_color: Color = Color(0.0, 0.5, 1.0, 0.3)
@export var _select_vertex_color: Color = Color.RED
@export var _select_edge_color: Color = Color.DEEP_PINK

var vertex_multimesh: MultiMeshInstance3D
var lines_mesh_instance: MeshInstance3D
var faces_mesh_instance: MeshInstance3D
var immediate_mesh: ImmediateMesh

var axes_mesh : ImmediateMesh
var axes_instance : MeshInstance3D
var axis_labels: Array[Label3D] = []
var axis_names = {
	1: "X",
	2: "Y",
	3: "Z",
	4: "W", 
	5: "V"
}
const label_pixel_size : float = 0.015

# TODO: Allow them to be set via color picker?
var axis_colors = {
	1: Color.RED,
	2: Color.GREEN,
	3: Color.BLUE,
	4: Color.YELLOW,
	5: Color.CYAN
}

var selected_plane_color : Color = Color(1,1,1,0.2)

var show_faces: bool = true
var show_edges: bool = true

func _init() -> void:
	_setup_vertices()
	_setup_lines()
	_setup_faces()
	_setup_axes()
	_setup_axis_labels()
	set_display_mode(0)

func _setup_axes() -> void:
	axes_instance = MeshInstance3D.new()
	axes_mesh = ImmediateMesh.new()
	axes_instance.mesh = axes_mesh

	var mat = StandardMaterial3D.new()
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	axes_instance.material_override = mat

	mat.no_depth_test = true
	mat.render_priority = label_pixel_size

	add_child(axes_instance)

func _setup_axis_labels() -> void:
	for i in range(1, 6):
		var lbl = Label3D.new()
		lbl.text = axis_names[i]
		lbl.pixel_size = 0.05
		lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		lbl.no_depth_test = true
		lbl.render_priority = 2
		lbl.modulate = axis_colors[i]
		lbl.visible = false

		add_child(lbl)
		axis_labels.append(lbl)

func _setup_vertices() -> void:
	vertex_multimesh = MultiMeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radius = vertex_radius
	mesh.height = vertex_radius * 2

	var mat = StandardMaterial3D.new()
	mat.albedo_color = _vertex_color
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mesh.surface_set_material(0, mat)
	
	vertex_multimesh.multimesh = MultiMesh.new()
	vertex_multimesh.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	vertex_multimesh.multimesh.mesh = mesh
	vertex_multimesh.multimesh.use_colors = true
	add_child(vertex_multimesh)

func _setup_lines() -> void:
	lines_mesh_instance = MeshInstance3D.new()
	immediate_mesh = ImmediateMesh.new()
	lines_mesh_instance.mesh = immediate_mesh

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.WHITE
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	lines_mesh_instance.material_override = mat
	add_child(lines_mesh_instance)

func _setup_faces() -> void:
	faces_mesh_instance = MeshInstance3D.new()
	var mat = StandardMaterial3D.new()
	mat.albedo_color = _face_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	faces_mesh_instance.material_override = mat
	add_child(faces_mesh_instance)

func update_visuals(projected_vertices: Array, edges: Array[Vector2i], faces: Array[Array], selection_info: Dictionary = {}) -> void:
	_draw_vertices(projected_vertices, selection_info.get(Controller.SELECTED_VERTICES, {}))
	
	if show_edges:
		if not lines_mesh_instance.visible: lines_mesh_instance.show()
		_draw_edges(projected_vertices, edges, selection_info.get(Controller.SELECTED_EDGES, {}))
	else:
		lines_mesh_instance.hide()
	
	if show_faces:
		if not faces_mesh_instance.visible: faces_mesh_instance.show()
		_draw_faces(projected_vertices, faces)
	else:
		faces_mesh_instance.hide()

func draw_axes(projected_points : Array, active_planes : Array) -> void:
	axes_mesh.clear_surfaces()
	if projected_points.is_empty(): return

	for lbl in axis_labels:
		lbl.visible = false

	axes_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	var origin = projected_points[0]

	for i in range(1, projected_points.size()):
		var tip = projected_points[i]
		var color = axis_colors.get(i, Color.WHITE)

		axes_mesh.surface_set_color(color)
		axes_mesh.surface_add_vertex(origin)
		axes_mesh.surface_add_vertex(tip)

		var label_idx = i - 1 
		if label_idx < axis_labels.size():
			var lbl = axis_labels[label_idx]
			lbl.position = tip + Vector3(0, 0.5, 0)
			if not tip.is_zero_approx():
				lbl.visible = true

			if i <= 3:
				lbl.pixel_size = label_pixel_size 
			else:
				lbl.pixel_size = label_pixel_size + 0.002

	axes_mesh.surface_end()

	if active_planes.size():
		axes_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
		for plane_enum in active_planes:
			var axis_indices = ShapeMap.planes_array_map.get(plane_enum)
			if axis_indices.size() == 2:
				var i_a = axis_indices[0] + 1
				var i_b = axis_indices[1] + 1

				if i_a < projected_points.size() and i_b < projected_points.size():
					var p_a = projected_points[i_a]
					var p_b = projected_points[i_b]

					axes_mesh.surface_set_color(selected_plane_color)
					axes_mesh.surface_add_vertex(origin)
					axes_mesh.surface_add_vertex(p_a)
					axes_mesh.surface_add_vertex(p_b)

					axes_mesh.surface_add_vertex(origin)
					axes_mesh.surface_add_vertex(p_a)
					axes_mesh.surface_add_vertex(p_b)
		axes_mesh.surface_end()
	



func _draw_vertices(points: Array, selection_info: Dictionary) -> void:
	if vertex_multimesh.multimesh.instance_count != points.size():
		vertex_multimesh.multimesh.instance_count = points.size()
	
	for i in range(points.size()):
		var t = Transform3D()
		var vertex_color = _vertex_color
		t.origin = points[i]
		vertex_multimesh.multimesh.set_instance_transform(i, t)
		if selection_info.has(i):
			vertex_color = _select_vertex_color
		vertex_multimesh.multimesh.set_instance_color(i, vertex_color)

func _draw_edges(points: Array, edges: Array[Vector2i], selection_info: Dictionary) -> void:	
	immediate_mesh.clear_surfaces()
	
	if edges.is_empty():
		return
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	for edge in edges:
		var edge_color = _edge_color
		if selection_info.has(edge):
			edge_color = _select_edge_color
		
		immediate_mesh.surface_set_color(edge_color)

		var p1 = points[edge.x]
		var p2 = points[edge.y]
		
		immediate_mesh.surface_add_vertex(p1)
		immediate_mesh.surface_add_vertex(p2)
		
	immediate_mesh.surface_end()

func _draw_faces(points: Array, faces_indices: Array[Array]) -> void:
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for face in faces_indices:
		if face.size() < 3: continue
		var p0 = points[face[0]]
		for i in range(1, face.size() - 1):
			surface_tool.add_vertex(p0)
			surface_tool.add_vertex(points[face[i]])
			surface_tool.add_vertex(points[face[i+1]])
			
	surface_tool.generate_normals()
	faces_mesh_instance.mesh = surface_tool.commit()


func set_display_mode(mode: int) -> void:
	# 0 = TransparentOpaque, 1 = Wireframe, 2 = Opaque
	match mode:
		0: 
			show_faces = true
			faces_mesh_instance.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		1:
			show_faces = false
		2:
			show_faces = true
			faces_mesh_instance.material_override.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED

func set_vertex_color(new_color: Color) -> void:
	_vertex_color = new_color
	
	if vertex_multimesh and vertex_multimesh.multimesh and vertex_multimesh.multimesh.mesh:
		var mat = vertex_multimesh.multimesh.mesh.surface_get_material(0)
		if mat:
			mat.albedo_color = new_color

func set_edge_color(new_color: Color) -> void:
	_edge_color = new_color

	if lines_mesh_instance and lines_mesh_instance.material_override:
		lines_mesh_instance.material_override.albedo_color = new_color

func set_face_color(new_color: Color) -> void:
	_face_color = new_color
	
	if faces_mesh_instance and faces_mesh_instance.material_override:
		faces_mesh_instance.material_override.albedo_color = new_color
		
	
func set_selected_vertex_color(new_color: Color) -> void:
	_select_vertex_color = new_color
	
func set_selected_edge_color(new_color: Color) -> void:
	_select_edge_color = new_color	
		
func get_face_color() -> Color:
	return _face_color
	
func get_edge_color() -> Color:
	return _edge_color
	
func get_vertex_color() -> Color:
	return _vertex_color
