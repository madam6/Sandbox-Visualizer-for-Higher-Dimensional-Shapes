extends Node3D
class_name ShapeRenderer

@export var vertex_radius: float = 0.1
@export var line_width: float = 0.05
@export var vertex_color: Color = Color.WHITE
@export var edge_color: Color = Color.CYAN
@export var face_color: Color = Color(0.0, 0.5, 1.0, 0.3)

var vertex_multimesh: MultiMeshInstance3D
var lines_mesh_instance: MeshInstance3D
var faces_mesh_instance: MeshInstance3D
var immediate_mesh: ImmediateMesh

var show_faces: bool = true
var show_edges: bool = true

func _ready():
	_setup_vertices()
	_setup_lines()
	_setup_faces()
	set_display_mode(2)

func _setup_vertices():
	vertex_multimesh = MultiMeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radius = vertex_radius
	mesh.height = vertex_radius * 2

	var mat = StandardMaterial3D.new()
	mat.albedo_color = vertex_color
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	mesh.surface_set_material(0, mat)
	
	vertex_multimesh.multimesh = MultiMesh.new()
	vertex_multimesh.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	vertex_multimesh.multimesh.mesh = mesh
	add_child(vertex_multimesh)

func _setup_lines():
	lines_mesh_instance = MeshInstance3D.new()
	immediate_mesh = ImmediateMesh.new()
	lines_mesh_instance.mesh = immediate_mesh

	var mat = StandardMaterial3D.new()
	mat.albedo_color = edge_color
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	lines_mesh_instance.material_override = mat
	add_child(lines_mesh_instance)

func _setup_faces():
	faces_mesh_instance = MeshInstance3D.new()
	var mat = StandardMaterial3D.new()
	mat.albedo_color = face_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	faces_mesh_instance.material_override = mat
	add_child(faces_mesh_instance)



func update_visuals(projected_vertices: Array, edges: Array[Vector2i], faces: Array[Array]):
	_draw_vertices(projected_vertices)
	
	if show_edges:
		if not lines_mesh_instance.visible: lines_mesh_instance.show()
		_draw_edges(projected_vertices, edges)
	else:
		lines_mesh_instance.hide()
	
	if show_faces:
		if not faces_mesh_instance.visible: faces_mesh_instance.show()
		_draw_faces(projected_vertices, faces)
	else:
		faces_mesh_instance.hide()

func _draw_vertices(points: Array):
	if vertex_multimesh.multimesh.instance_count != points.size():
		vertex_multimesh.multimesh.instance_count = points.size()
	
	for i in range(points.size()):
		var t = Transform3D()
		t.origin = points[i]
		vertex_multimesh.multimesh.set_instance_transform(i, t)

func _draw_edges(points: Array, edges: Array[Vector2i]):
	immediate_mesh.clear_surfaces()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	for edge in edges:
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
	# 0 = Opaque, 1 = Transparent, 2 = Wireframe
	match mode:
		0: 
			show_faces = true
			faces_mesh_instance.material_override.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		1:
			show_faces = true
			faces_mesh_instance.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		2:
			show_faces = false
