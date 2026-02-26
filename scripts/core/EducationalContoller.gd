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
		"text" : "Explanation1"
	},

	"projection" : {
		"title" : "Projection perspective",
		"text" : "Explanation2"
	},

	"rotation_planes" : {
		"title" : "Rotation planes",
		"text" : "Explanation4"
	},

	"Cube4D" : {
		"title" : "Cube4D",
		"text" : "Cube4D"
	},
	
	"Cube3D" : {
		"title" : "Cube3D",
		"text" : "Cube3D"
	},

	"Cube5D" : {
		"title" : "Cube5D",
		"text" : "Cube5D"
	},

	"Pyramid3D" : {
		"title" : "Pyramid3D",
		"text" : "Pyramid3D"
	},
	
	"Pyramid4D" : {
		"title" : "Pyramid4D",
		"text" : "Pyramid4D"
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
