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


var show_faces: bool = true
var show_edges: bool = true

func _init() -> void:
	_setup_vertices()
	_setup_lines()
	_setup_faces()
	set_display_mode(0)

func _setup_vertices():
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

func _setup_lines():
	lines_mesh_instance = MeshInstance3D.new()
	immediate_mesh = ImmediateMesh.new()
	lines_mesh_instance.mesh = immediate_mesh

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.WHITE
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	lines_mesh_instance.material_override = mat
	add_child(lines_mesh_instance)

func _setup_faces():
	faces_mesh_instance = MeshInstance3D.new()
	var mat = StandardMaterial3D.new()
	mat.albedo_color = _face_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	faces_mesh_instance.material_override = mat
	add_child(faces_mesh_instance)

func update_visuals(projected_vertices: Array, edges: Array[Vector2i], faces: Array[Array], selection_info: Dictionary = {}):
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

func _draw_vertices(points: Array, selection_info: Dictionary):
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

func _draw_edges(points: Array, edges: Array[Vector2i], selection_info: Dictionary):
	if edges.is_empty():
		return
	
	immediate_mesh.clear_surfaces()
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

func _draw_faces(points: Array, faces_indices: Array[Array]):
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


func set_display_mode(mode: int):
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

func set_vertex_color(new_color: Color):
	_vertex_color = new_color
	
	if vertex_multimesh and vertex_multimesh.multimesh and vertex_multimesh.multimesh.mesh:
		var mat = vertex_multimesh.multimesh.mesh.surface_get_material(0)
		if mat:
			mat.albedo_color = new_color

func set_edge_color(new_color: Color):
	_edge_color = new_color

	if lines_mesh_instance and lines_mesh_instance.material_override:
		lines_mesh_instance.material_override.albedo_color = new_color

func set_face_color(new_color: Color):
	_face_color = new_color
	
	if faces_mesh_instance and faces_mesh_instance.material_override:
		faces_mesh_instance.material_override.albedo_color = new_color
		
	
func set_selected_vertex_color(new_color: Color):
	_select_vertex_color = new_color
	
func set_selected_edge_color(new_color: Color):
	_select_edge_color = new_color	
		
func get_face_color() -> Color:
	return _face_color
	
func get_edge_color() -> Color:
	return _edge_color
	
func get_vertex_color() -> Color:
	return _vertex_color
