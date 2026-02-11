extends Node

signal lesson_started
signal lesson_step_changed(title: String, description: String, button_text : String)
signal labarotry_mode_toggled(is_active : bool)
signal lesson_ended
signal request_reset_ui

const tesseract_lesson_index : int = 4
const shape_size : int = 5
const inner_cube_size : int = shape_size - 2

var _steps : Array[LessonStep] = []
var _current_step_index : int = -1
var _tween : Tween
var interpolation_time : float = 1.5
var is_labarotory_active : bool = false
var _has_completed_lesson : bool = false

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

func turn_on_lab_overlays() -> void:
	Controller.toggle_axes(true)

func _build_schedule() -> void:
	var step0 = LessonStep.new()
	step0.title = "PLACEHOLDER Point"
	step0.text = "PLACEHOLDER Desciption."
	step0.btn_text = "Extrude to 1D."
	step0.start_shape_data = _create_compressed_line()
	step0.end_shape_data = _create_compressed_line()
	_steps.append(step0)

	var step1 = LessonStep.new()
	step1.title = "PLACEHOLDER Line"
	step1.text = "PLACEHOLDER Desciption."
	step1.btn_text = "Extrude to 2D."
	step1.start_shape_data = _create_compressed_line()
	step1.end_shape_data = _create_line()
	_steps.append(step1)
	
	var step2 = LessonStep.new()
	step2.title = "PLACEHOLDER Square"
	step2.text = "PLACEHOLDER Desciption."
	step2.btn_text = "Extrude to 3D."
	step2.start_shape_data = _create_compressed_square()
	step2.end_shape_data = _create_square()
	_steps.append(step2)
	
	var step3 = LessonStep.new()
	step3.title = "PLACEHOLDER Cube"
	step3.text = "PLACEHOLDER Desciption."
	step3.btn_text = "Extrude to 4D."
	step3.start_shape_data = _create_compressed_cube()
	step3.end_shape_data = _create_cube()
	_steps.append(step3)
	
	var step4 = LessonStep.new()
	step4.title = "PLACEHOLDER Tesseract"
	step4.text = "PLACEHOLDER Desciption."
	step4.btn_text = "N/A"
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
