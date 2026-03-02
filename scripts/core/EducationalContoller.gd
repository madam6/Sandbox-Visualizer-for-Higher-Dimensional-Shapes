extends Node

signal lesson_started
signal lesson_step_changed(title: String, description: String, button_text : String)
signal labarotry_mode_toggled(is_active : bool)
signal lesson_ended
signal request_reset_ui
signal switch_overlay_visibility(visible : bool)
signal explanation_requested(title : String, text : String)

const tesseract_lesson_index : int = 4
const shape_size : int = 5
const inner_cube_size : int = shape_size - 2

var _steps : Array[LessonStep] = []
var _current_step_index : int = -1
var _tween : Tween
var interpolation_time : float = 1.5
var is_labarotory_active : bool = false
var _has_completed_lesson : bool = false

var encyclopedia = {
	"matrix" : {
		"title" : "The Rotation Matrix",
		"text" : "
[fill]To perform a rotation in a certain plane, one must multiply the shape's vertices by the relevant rotation matrices.
A matrix is a mathematical structure consisting of rows and columns. Each vertex of our shape is a vector - for example, in the form (x, y, z) for a 3D shape. To multiply a vector by a matrix, you multiply each matrix row by the vector, point by point, and sum it up. Consider this example:

[center][code]
[2, 2]   * [2]   =   [2*2 + 2*1]   =   [6]
[1, 1]       [1]       [1*2 + 1*1]       [3]
[/code][/center]

An important concept is the [b][color=cyan]Identity Matrix[/color][/b]. This is a special matrix with 1s on the diagonal and 0s everywhere else:
[center][code]
[1, 0, 0]
[0, 1, 0]
[0, 0, 1]
[/code][/center]
When you multiply a vector by an identity matrix, the output does not change.

Rotation matrices are defined by the planes they rotate. The columns and rows corresponding to the actively rotating plane use the sine and cosine of the angle, while the rest of the matrix acts exactly like an identity matrix. Consider a rotation matrix for the XY plane of a 2D square:
[center][code]
[ cosθ, -sinθ]
[ sinθ,  cosθ]
[/code][/center]

Let's apply a 90-degree rotation to a point that lies on the Y-axis: (0, 1). Since cos(90°) = 0 and sin(90°) = 1, our matrix looks like this:
[center][code]
[0, -1]  * [0]  =  [0*0 + (-1)*1]  =  [-1]
[1,  0]     [1]     [1*0 +   0*1 ]     [ 0]
[/code][/center]
Our point is now (-1, 0) on the negative X-axis. We successfully turned it 90 degrees counter-clockwise!
The exact same logic applies to higher-dimensional shapes. When rotating in a certain plane, the rotation matrix is applied to each point of the shape (like a 4D cube) to calculate its new position in our world.
[b][color=yellow]In Laboratory Mode, you can see exactly what the live rotation matrix looks like for your active planes.[/color][/b][/fill]
"
	},

	"projection" : {
		"title" : "Projection perspective",
		"text" : "
[fill]To see a complex 3D shape on our 2-dimensional computer screen, we must transform it. We need a mathematical way to convert its 3-coordinate vertices (x, y, z) into 2-coordinate points (x, y) that can be drawn flat.[/fill]
This process is called [b][color=cyan]Projection[/color][/b].
[fill]The simplest method is [b]Orthogonal Projection[/b]. Here, you literally just drop the last coordinate. For example, the point (5, 5, 2) simply becomes (5, 5). The disadvantage of this method is that it creates \"tunnel vision\" without depth - no matter how far away an object is along the Z-axis, it appears the exact same size. 
The alternative is [b]Perspective Projection[/b], which mimics how human eyes work. Instead of straight parallel lines, the view is shaped like a pyramid (called a viewing frustum). Objects that are further away appear smaller. 
To achieve this mathematically, we need to know two things: the distance of the object along the Z-axis, and our Field of View (FOV). Using these, we calculate a \"scaling factor\". We then multiply our X and Y coordinates by this factor to visually shrink points that are further away into the distance. [/fill]
[center][b][color=yellow]The exact same logic applies to 4 Dimensions![/color][/b][/center]
[fill]You have a distance along the new 4th axis (W). To project a 4D coordinate (x, y, z, w) down into 3D space, you \"squish\" the first three coordinates using a perspective factor calculated from the 4th coordinate's depth. 
In 5 dimensions, this operation is simply performed twice: first flattening 5D into 4D, and then flattening 4D down into 3D!
[i]This visualizer allows you to toggle projection modes at any time to see how multidimensional shapes behave under both Perspective and Orthogonal rules.[/i][/fill]
		"
	},

	"rotation_planes" : {
		"title" : "Rotation planes",
		"text" : 
			"
[fill]Rotating an object always happens within a certain 2D plane. If you define a 3D coordinate system with X, Y, and Z axes, and you want to spin an object around the Z-axis, you are actually rotating it flatly along the XY plane. 
More complex rotations that we encounter in the real world are simply combinations of multiple rotations across different planes. In aviation, pilots refer to these standard rotations as [b]pitch[/b] (YZ plane), [b]yaw[/b] (XZ plane), and [b]roll[/b] (XY plane).
This visualizer allows you to apply a specific degree of rotation to every plane present in your current shape. [/fill]
[center][b][color=yellow]Rotating in Higher Dimensions[/color][/b][/center]
[fill]Here is a mind-bending mathematical fact: even in 4D and 5D, rotations [i]still[/i] happen in 2D planes! Instead of rotating around a 1D axis line like we do in 3D, a 4D shape rotates in a 2D plane (like the new XW or YW planes) while an entirely different 2D plane stays perfectly stationary.
This visualizer allows you to see exactly where the 4th and 5th axes project into our 3D world during these rotations. It also highlights the 2D planes that are currently actively rotating.[/fill]
[center][b][color=yellow]The Invisible Rotation[/color][/b][/center]
[fill]You might notice that in 5 dimensions, rotating strictly in the [b]WV plane[/b] (the plane combining the 4th and 5th axes) sometimes doesn't seem to change the shape's position on screen. This is because a WV rotation only alters the W and V coordinates. If you are using Orthogonal projection, those coordinates are dropped, leaving the 3D coordinates (X, Y, Z) completely untouched![/fill]"
	},

	"Cube4D" : {
		"title" : "Cube4D",
		"text" : "
[fill]The [b][color=lightblue]4D Cube[/color][/b], most famously known as the [b]Tesseract[/b] or [b]Hypercube[/b], is the 4-dimensional equivalent of a standard square box. [/fill]
• [b]Vertices:[/b] 16
• [b]Edges:[/b] 32
• [b]Faces:[/b] 24
• [b]Cells (3D Cubes):[/b] 8
[b][color=yellow]Inside out[/color][/b]
[fill]If you turn on Continuous Rotation for a 4D plane (like the XW, YW, or ZW planes), you will see something impossible in our universe. As the Tesseract rotates, the \"inner\" cube will stretch out and become the \"outer\" cube, while the outer cube shrinks and folds inward! Because our 3D brains cannot process a 4D object spinning, it looks to us like the shape is constantly turning itself inside-out.
Remember, that the \"inner\" in reality is the same size as the \"outer\" one. Shrinking is cause by perspective projection.[/fill]

[b][color=yellow]Unfolding Tesseract[/color][/b]
[fill]If you take a hollow cardboard 3D cube and cut its edges, you can unfold it flat onto a 2D table to make a shape that looks like a cross (made of 6 flat squares). 
If a 4-dimensional being were to take a hollow Tesseract and unfold it, it would drop down into our 3D world as a 3D cross made of 8 solid cubes stacked together!.[/fill]

[b][color=yellow]Euler's Rule in 4D[/color][/b]
[fill]Remember the 3D formula for vertices, edges, and faces? In 4D, the math expands to include the 3D Cells (Cubes). The formula becomes: V - E + F - C = 0. [/fill]
Let's test our Tesseract's numbers: 16 - 32 + 24 - 8 = 0.
		"
	},
	
	"Cube3D" : {
		"title" : "Cube3D",
		"text" : "
[fill]The [b][color=lightblue]3D Cube[/color][/b] (also known as a regular hexahedron) is one of the most familiar shapes in human geometry, but it has some facinsating secrets![/fill]
Core stats of a standard cube: 
• [b]Vertices:[/b] 8
• [b]Edges:[/b] 12
• [b]Faces:[/b] 6
[b][color=yellow]The Platonic Solid[/color][/b]
[fill]The cube is one of only five \"Platonic Solids\" in existence. This means it is a perfectly regular 3D shape where every single face is the exact same regular polygon (a square), and the exact same number of faces meet at every single vertex (three squares meet at every corner).[/fill]

[b][color=yellow]Hidden Hexagon[/color][/b]
[fill]You might think that if you slice a cube, you will only ever get squares or rectangles. However, if you take a solid 3D cube and slice it pefectly at a diagonal anlge, cutting through center, the flat exposed section inside is a perfect, regular hexagon.[/fill]

[b][color=yellow]Euler's Rule[/color][/b]
[fill]Cubes easily demonstarate a fundamental rule of 3D geomtery described by the mathematician Leonhard Euler. The rule states: For any convex 3D shape: [b]Vertices - Edges + Faces = 2[/b].[/fill]
Lets apply this formula to cube's stats:
[b](8 - 12 + 6) = 2[/b]

[b][color=yellow]The Bridge to Higher Dimensions[/color][/b]
[fill]In this visualizer, the 3D cube is the stepping stone between the flat 2D square and the 4D tesseract. Just as a 3D cube is bounded by 6 flat 2D squares, a 4D tesseract is bounded by 8 solid 3D cubes!
[/fill]
		"
	},

	"Cube5D" : {
		"title" : "Cube5D",
		"text" : "
[fill]The [b][color=lightblue]5D Cube[/color][/b] mathematically known as [b]Penteract[/b], is the 5 dimensional equivalent of a standard box. Rotation of such a shape is quite impossible to imagine in our heads, but maths allos us to do that.[/fill]
• [b]Vertices:[/b] 32
• [b]Edges:[/b] 80
• [b]Faces (squares):[/b] 80
• [b]Cells (3D Cubes):[/b] 40
• [b]4-Dimensional faces (Tesseracts):[/b] 10
[b][color=yellow]A shadow of a shadow[/color][/b]
[fill]You are looking at this 5D shape on a flat, 2D screen. To make this happen visualiser needed to perform complex change of projections. Firstly taking the \"shadow\" of the shape into 4 dimensions, and then taking the shadow of the resulting shapes into 3. Finally your computer flattens this 3D shadow into a 2 dimensional shape.[/fill]

[b][color=yellow]Bounded by tesseracts[/color][/b]
[fill]A 2D square is surrounded by 4 lines. A 3D cube is surrounded by 6 flat squares. A 4D tesseract is surrounded by 8 solid 3D cubes. 
Following this exact mathematical pattern, a 5D Penteract is completely enclosed by 10 solid 4D Tesseracts!.[/fill]

[b][color=yellow]Natural appearences[/color][/b]
[fill]Pyramids extremely often formed and appears under natural conditions, specifically in crystal formations, molecular geometry, and obviously nature. The reason for this is combination of structural stability due to wide base and energy efficiency (Some molecules (like ammonia, NH3) adopt a trigonal pyramidal shape because it reduces electron repulsion)[/fill]
	"
	},

	"Pyramid3D" : {
		"title" : "Pyramid3D",
		"text" : "
[fill]The [b][color=lightblue]3D Pyramid[/color][/b] (also known as a tetrahedron) is an extremely recognisible shape that consists of:[/fill]
• [b]Vertices:[/b] 4
• [b]Edges:[/b] 8
• [b]Faces (triangular):[/b] 4
[b][color=yellow]Types of pyramids[/color][/b]
[fill]There are multiple types of pyramids: Triangular pyramid (the one you see on the screen), square pyramid, pentagonal pyramid, hexagonal pyramid. Type of pyramid is define by its base shape, figure at the \"bottom.\" [/fill]

[b][color=yellow]The Platonic Solid[/color][/b]
[fill]The triangular pyramid is one of the 5 platonic solids, alongside regular 3 dimensional cube. Platonic solds are perfectly regular 3D shapes where every single face is the exact same regular polygon (a triangle in pyramid's case), and the exact same number of faces meet at every single vertex (three triangles meet at every corner).[/fill]

[b][color=yellow]Natural appearences[/color][/b]
[fill]Pyramids extremely often formed and appears under natural conditions, specifically in crystal formations, molecular geometry, and obviously nature. The reason for this is combination of structural stability due to wide base and energy efficiency (Some molecules (like ammonia, NH3) adopt a trigonal pyramidal shape because it reduces electron repulsion)[/fill]
"
	},
	
	"Pyramid4D" : {
		"title" : "Pyramid4D",
		"text" : "
[fill]The [b][color=lightblue]4D Pyramid[/color][/b] known formally as (Pentachoron or 5-Cell) and consists of:[/fill]
• [b]Vertices:[/b] 5
• [b]Edges:[/b] 10
• [b]Faces (triangular):[/b] 10
• [b]Cells (3D Pyramids):[/b] 5
[b][color=yellow]Simplest shape[/color][/b]
[fill]Triangle is simplest enclosed shape you can draw in 2D. Triangle based pyramid is a simplest shape one can build in 3D. Similarly Pentachoron is the simplest shape existing in 4 dimensions. Mathematicians call this family of shapes [b]simplexes[/b].[/fill]

[b][color=yellow]Everyone is connected[/color][/b]
[fill]Because it is a simplex, the 4D pyramid has an incredible structural secret: every single vertex is directly connected to every other vertex by an edge! If you look closely at the shape in the visualizer, there are no \"opposite\" corners - every point is a direct neighbor to all four of the other points.[/fill]

[b][color=yellow]Square root of 5[/color][/b]
[fill]To make a perfectly \"regular\" 4D pyramid where every single edge is the exact same length, you have to extrude the 4th-dimensional apex to a very specific, mathematically precise distance. In this visualizer, the height proportion of the 4D apex is mathematically locked to the square root of 5 to guarantee that the 4D edges perfectly match the length of the 3D base.[/fill]"
	},
}

var current_shape : String

@export var _matrix_display : MatrixDisplay

class LessonStep:
	var title: String
	var text: String
	var btn_text: String
	var start_shape_data: ShapeData
	var end_shape_data: ShapeData
	

func _ready() -> void:
	_build_schedule()
	

func enter_educational_flow() -> void:
	if _has_completed_lesson:
		enter_laboratory()
	else:
		start_lesson()

func complete_lesson_go_to_lab() -> void:
	_has_completed_lesson = true
	stop_current_lesson_logic()
	enter_laboratory()

func stop_current_lesson_logic() -> void:
	if _tween: _tween.kill()
	_current_step_index = -1
	Controller.clear_override_mode()
	lesson_ended.emit()

func get_current_step_index() -> int:
	return _current_step_index

func start_lesson():
	is_labarotory_active = false
	labarotry_mode_toggled.emit(false)

	_current_step_index = 0
	request_reset_ui.emit()
	_override_controller()
	_load_step(_current_step_index)
	lesson_started.emit()

func _override_controller() -> void:
	Controller.set_shape_size(shape_size)
	Controller.set_3d_mode()
	Controller.reset_rotation()
	Controller.sync_active_planes()

func next_step() -> void:
	_current_step_index += 1
	
	if _current_step_index >= _steps.size():
		complete_lesson_go_to_lab()
	else:
		_load_step(_current_step_index)
		
		
func previous_step() -> void:
	if _current_step_index > 0:
		_current_step_index -= 1
		_load_step(_current_step_index)		

func end_lesson() -> void:
	_current_step_index = -1
	Controller.clear_override_mode()
	Controller.set_initial_state()
	lesson_ended.emit()

func _load_step(step_index : int) -> void:
	var step = _steps[step_index]
	
	var display_data = ShapeData.new()
	display_data.edges = step.end_shape_data.edges
	display_data.faces = step.end_shape_data.faces
	display_data.vertices = step.start_shape_data.vertices.duplicate(true)

	Controller.set_override_shape(display_data)

	if step_index >= 1:
		if _tween: _tween.kill()
		_tween = create_tween()
		_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_tween.tween_method(
			_process_extrusion_frame.bind(step.start_shape_data.vertices, step.end_shape_data.vertices),
			0.0,
			1.0,
			interpolation_time
		)

	lesson_step_changed.emit(step.title, step.text, step.btn_text)

func _process_extrusion_frame(t : float, start_vertices : Array, end_vertices : Array) -> void:
	var current_vertices = []
	current_vertices.resize(start_vertices.size())

	for i in range(start_vertices.size()):
		current_vertices[i] = start_vertices[i].lerp(end_vertices[i], t)
	
	Controller.update_animated_vertices(current_vertices)


func enter_laboratory():
	is_labarotory_active = true
	_override_controller()
	Controller.set_init_lab_state()
	Controller.set_shape_size(shape_size)
	turn_on_lab_overlays()
	labarotry_mode_toggled.emit(true)

func exit_laboratory():
	is_labarotory_active = false
	Controller.clear_override_mode()
	Controller.set_initial_state()
	labarotry_mode_toggled.emit(false)
	turn_off_lab_overlays()
	lesson_ended.emit()

func turn_off_lab_overlays() -> void:
	Controller.toggle_axes(false)
	switch_overlay_visibility.emit(false)

func turn_on_lab_overlays() -> void:
	Controller.toggle_axes(true)
	switch_overlay_visibility.emit(true)

func _build_schedule() -> void:
	var step0 = LessonStep.new()
	step0.title = "Everything Starts with the Point"
	step0.text = "
[fill]Imagine a space where there are no coordinates. Such a space is completely empty. Our Universe was once around this same size. 
You can visualize such a space as a single dot. The only geometrical shape that can exist here is the space itself. To obtain any other form of geometry, you need to have at least 1 coordinate - a single axis. 
[b][color=yellow]Take a look at what happens when you extrude this space into 1 dimension.[/color][/b][/fill]
"
	step0.btn_text = "Extrude to 1D."
	step0.start_shape_data = _create_compressed_line()
	step0.end_shape_data = _create_compressed_line()
	_steps.append(step0)

	var step1 = LessonStep.new()
	step1.title = "The Line"
	step1.text = "
[fill]Yes, it is a line! If you remember from high school, we use a number line to mark sets of Natural or Real numbers. This is because a single axis perfectly represents 1-dimensional space. Each point needs only one coordinate - just its number, like [b][5][/b]. 
A shape in 1-dimensional space that has a length greater than zero is a line segment, which is defined by its two endpoints, like [b][5][/b] and [b][6][/b]. To move to a higher dimension, we must extrude this shape at a 'right' angle, meaning we drag it exactly 90 degrees away from its current axis. 
[b][color=yellow]But what happens when you extrude this line at a right angle into the second dimension?[/color][/b][/fill]
	"
	step1.btn_text = "Extrude to 2D."
	step1.start_shape_data = _create_compressed_line()
	step1.end_shape_data = _create_line()
	_steps.append(step1)
	
	var step2 = LessonStep.new()
	step2.title = "The Square"
	step2.text = "
[fill]We get a square! Now each point is defined by two coordinates (x, y), and the shape itself has 4 vertices. 
Notice that we can easily represent such a shape on our computer screens. Screens are flat, and so is a square, so to draw it on the screen we do not need to do any fancy mathematics - we simply display it. 
However, this is not the case for the next shape. [b][color=yellow]Let's follow the rule of building higher-dimensional shapes and extrude the square at a right angle.[/color][/b][/fill]
	"
	step2.btn_text = "Extrude to 3D."
	step2.start_shape_data = _create_compressed_square()
	step2.end_shape_data = _create_square()
	_steps.append(step2)
	
	var step3 = LessonStep.new()
	step3.title = "The Cube"
	step3.text = "
[fill]We arrive at the cube. This is a very simple and understandable shape for us humans, but notice how the number of vertices is now exactly 8? Every time we increase the dimension, the number of vertices is doubled because of the new axis we introduced. Each point now has 3 coordinates. Technically speaking, a cube is a collection of squares, whereas a square is a collection of lines, and a line is a collection of dots. [b][color=lightblue]Can you guess what a higher-dimensional cube represents?[/color][/b]
Notice how we encounter a certain issue with the cube. The shape itself is partially transparent, and the far end of it appears smaller. The problem is that we cannot directly visualize 3-dimensional shapes on our screens, which only have 2 dimensions. We need to find a mathematical way to get rid of the 3rd coordinate and transform (x, y, z) into (x, y). The same algorithm applies for higher dimensions. This mechanism is called [b][color=cyan]\"projection\"[/color][/b]. To learn more about methods of projection, interact with the projection mode toggle at the end of the lesson.
[b][color=yellow]Now, the moment of truth! Let's apply our algorithm to get our final 4D shape. Remember, we must extrude the whole shape at a right angle.[/color][/b][/fill]"
	step3.btn_text = "Extrude to 4D."
	step3.start_shape_data = _create_compressed_cube()
	step3.end_shape_data = _create_cube()
	_steps.append(step3)
	
	var step4 = LessonStep.new()
	step4.title = "The Tesseract"
	step4.text = "
	[fill]Finally, it is here. The almighty Tesseract! This is what a standard 4-dimensional cube looks like. But our rule said to \"extrude at a right angle\", and on the screen, it seems like the magnitude of the angle is 45 degrees. You would be right - well, almost.
Remember that we cannot really represent shapes that have more than 2 dimensions on our flat screens? The same applies to the tesseract. To see it, you need to find a way to flatten its 16 vertices from (x, y, z, w) into (x, y, z), and then into (x, y). 
The inner cube of the tesseract appears smaller for the exact same reason the back side of a 3D cube appears smaller. It lies further along the new 'w' axis than the other points, so the projection of such a shape into our world appears to have a smaller cube inside. In actual reality, a 4-dimensional cube has all of its sides perfectly equal!
Note that because we now have one more axis to work with, when rotating the shape, we have more planes to choose from; some are combined with this new 'w' axis.[/fill]
[b][color=lightblue]A Tesseract has:[/color][/b]
• 16 vertices
• 32 edges
• 24 faces
[b][color=yellow]To play with it, press \"Enter Laboratory\".[/color][/b]
	"
	step4.btn_text = "Enter Laboratory"
	step4.start_shape_data = _сreate_compressed_tesseract()
	step4.end_shape_data = _create_fake_tesseract()
	_steps.append(step4)
	
	
func _create_compressed_line() -> ShapeData:
	var point = ShapeData.new()
	point.vertices = [Vector3.ZERO, Vector3.ZERO]
	point.edges = [Vector2i(0, 1)] as Array[Vector2i]
	return point

func _create_line() -> ShapeData:
	var line = ShapeData.new()
	line.vertices = [Vector3(-shape_size, 0, 0), Vector3(shape_size, 0, 0)]
	line.edges = [Vector2i(0, 1)] as Array[Vector2i]
	return line
	
func _create_square() -> ShapeData:
	var square = ShapeData.new()
	square.vertices = [Vector3(-shape_size, -shape_size, 0),
		Vector3( shape_size, -shape_size, 0),
		Vector3( shape_size,  shape_size, 0),
		Vector3(-shape_size,  shape_size, 0)]
	square.edges = [Vector2i(0, 1), Vector2i(1, 2), Vector2i(2, 3), Vector2i(3, 0)] as Array[Vector2i]
	square.faces = [[0, 3, 2, 1]] as Array[Array]
	return square

func _create_compressed_square() -> ShapeData:
	var line = ShapeData.new()
	line.vertices = [
		Vector3( -shape_size, 0, 0),
		Vector3( shape_size,  0, 0),
		Vector3( shape_size, 0, 0),
		Vector3( -shape_size,  0, 0),
					]
	line.edges = [Vector2i(0, 1), Vector2i(1, 2), Vector2i(2, 3), Vector2i(3, 0)] as Array[Vector2i]
	line.faces = [[0, 3, 2, 1]] as Array[Array]
	return line
	
func _create_compressed_cube() -> ShapeData:
	var square = ShapeMap.shape_map["Cube"]["3D"][Enums.ShapeDataRetriever.ShapeStrategyIndex].create_shape()
	square.vertices = [Vector3(-shape_size, -shape_size, 0),
		Vector3( shape_size, -shape_size, 0),
		Vector3( shape_size,  shape_size, 0),
		Vector3(-shape_size,  shape_size, 0),
		
		Vector3(-shape_size, -shape_size, 0),
		Vector3( shape_size, -shape_size, 0),
		Vector3( shape_size,  shape_size, 0),
		Vector3(-shape_size,  shape_size, 0)]
	return square

func _сreate_compressed_tesseract() -> ShapeData:
	var tesseract = _create_tesseract()
	tesseract.vertices.clear()

	tesseract.vertices = [
		Vector3(-shape_size, -shape_size, -shape_size), Vector3( shape_size, -shape_size, -shape_size), Vector3( shape_size,  shape_size, -shape_size), Vector3(-shape_size,  shape_size, -shape_size),
		Vector3(-shape_size, -shape_size,  shape_size), Vector3( shape_size, -shape_size,  shape_size), Vector3( shape_size,  shape_size,  shape_size), Vector3(-shape_size,  shape_size,  shape_size),
		Vector3(-shape_size, -shape_size, -shape_size), Vector3( shape_size, -shape_size, -shape_size), Vector3( shape_size,  shape_size, -shape_size), Vector3(-shape_size,  shape_size, -shape_size),
		Vector3(-shape_size, -shape_size,  shape_size), Vector3( shape_size, -shape_size,  shape_size), Vector3( shape_size,  shape_size,  shape_size), Vector3(-shape_size,  shape_size,  shape_size)
	]
	return tesseract

func _create_cube() -> ShapeData:
	return ShapeMap.shape_map["Cube"]["3D"][Enums.ShapeDataRetriever.ShapeStrategyIndex].create_shape()
	
func _create_tesseract() -> ShapeData:
	return ShapeMap.shape_map["Cube"]["4D"][Enums.ShapeDataRetriever.ShapeStrategyIndex].create_shape()

func _create_fake_tesseract() -> ShapeData:
	var tesseract = _create_tesseract()
	tesseract.vertices.clear()
	
	tesseract.vertices = [
		Vector3(-inner_cube_size, -inner_cube_size, -inner_cube_size), Vector3( inner_cube_size, -inner_cube_size, -inner_cube_size), 
		Vector3( inner_cube_size,  inner_cube_size, -inner_cube_size), Vector3(-inner_cube_size,  inner_cube_size, -inner_cube_size),
		Vector3(-inner_cube_size, -inner_cube_size,  inner_cube_size), Vector3( inner_cube_size, -inner_cube_size,  inner_cube_size), 
		Vector3( inner_cube_size,  inner_cube_size,  inner_cube_size), Vector3(-inner_cube_size,  inner_cube_size,  inner_cube_size),
		
		Vector3(-shape_size, -shape_size, -shape_size), Vector3( shape_size, -shape_size, -shape_size), 
		Vector3( shape_size,  shape_size, -shape_size), Vector3(-shape_size,  shape_size, -shape_size),
		Vector3(-shape_size, -shape_size,  shape_size), Vector3( shape_size, -shape_size,  shape_size), 
		Vector3( shape_size,  shape_size,  shape_size), Vector3(-shape_size,  shape_size,  shape_size)
	]	
	return tesseract


func request_explanation(topic : String) -> void:
	if topic == "current_shape":
		_show_current_shape_fact()
	elif encyclopedia.has(topic):
		var data = encyclopedia[topic]
		explanation_requested.emit(data.title, data.text)

func get_current_shape_name_display() -> String:
	var current_dimenstion = Controller.get_current_dimension()
	
	return current_shape + str(current_dimenstion) + "D"

func _show_current_shape_fact() -> void:
	var shape = get_current_shape_name_display() 

	if encyclopedia.has(shape):
		explanation_requested.emit(encyclopedia[shape]["title"], encyclopedia[shape]["text"])

func set_current_shape(new_shape : String) -> void:
	current_shape = new_shape
