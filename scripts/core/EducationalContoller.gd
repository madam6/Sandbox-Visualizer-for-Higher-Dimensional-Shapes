extends Node

signal lesson_started
signal lesson_step_changed(title: String, description: String, button_text : String)
signal lesson_ended

const tesseract_lesson_index : int = 4
const shape_size : int = 5
class LessonStep:
	var title: String
	var text: String
	var btn_text: String
	var shape_data: ShapeData
	
	
var _steps : Array[LessonStep] = []
var _current_step_index : int = -1

func _ready() -> void:
	_build_schedule()
	

func get_current_step_index() -> int:
	return _current_step_index

func start_lesson():
	_current_step_index = 0
	Controller.reset_controller()
	Controller.set_3d_mode()
	_load_step(_current_step_index)
	lesson_started.emit()
	
func next_step():
	_current_step_index += 1
	
	if _current_step_index >= _steps.size():
		end_lesson()
	else:
		_load_step(_current_step_index)
		
		
func previous_step():
	if _current_step_index > 0:
		_current_step_index -= 1
		_load_step(_current_step_index)		

func end_lesson():
	_current_step_index = -1
	Controller.clear_override_mode()
	Controller.set_initial_state()
	lesson_ended.emit()

func _load_step(step_index : int):
	var step = _steps[step_index]
	
	if step_index == tesseract_lesson_index:
		Controller.set_lesson_tesseract()
		
		Controller.set_shape_size(5.0)
		
		step.shape_data = _create_tesseract()
	else:
		Controller.set_3d_mode()
		Controller.set_shape_size(shape_size)

	Controller.set_override_shape(step.shape_data)
	lesson_step_changed.emit(step.title, step.text, step.btn_text)

func _build_schedule():
	var step0 = LessonStep.new()
	step0.title = "PLACEHOLDER Point"
	step0.text = "PLACEHOLDER Desciption."
	step0.btn_text = "Extrude to 1D."
	step0.shape_data = _create_point()
	_steps.append(step0)
	
	var step1 = LessonStep.new()
	step1.title = "PLACEHOLDER Line"
	step1.text = "PLACEHOLDER Desciption."
	step1.btn_text = "Extrude to 2D."
	step1.shape_data = _create_line()
	_steps.append(step1)
	
	var step2 = LessonStep.new()
	step2.title = "PLACEHOLDER Square"
	step2.text = "PLACEHOLDER Desciption."
	step2.btn_text = "Extrude to 3D."
	step2.shape_data = _create_square()
	_steps.append(step2)
	
	var step3 = LessonStep.new()
	step3.title = "PLACEHOLDER Cube"
	step3.text = "PLACEHOLDER Desciption."
	step3.btn_text = "Extrude to 4D."
	step3.shape_data = _create_cube()
	_steps.append(step3)
	
	var step4 = LessonStep.new()
	step4.title = "PLACEHOLDER Tesseract"
	step4.text = "PLACEHOLDER Desciption."
	step4.btn_text = "N/A"
	step4.shape_data = _create_tesseract()
	_steps.append(step4)
	
	
func _create_point():
	var point = ShapeData.new()
	point.vertices = [Vector3.ZERO]
	point.edges = [] as Array[Vector2i]
	return point
	
	
func _create_line():
	var line = ShapeData.new()
	line.vertices = [Vector3(-shape_size, 0, 0), Vector3(shape_size, 0, 0)]
	line.edges = [Vector2i(0, 1)] as Array[Vector2i]
	return line
	
func _create_square():
	var square = ShapeData.new()
	square.vertices = [Vector3(-shape_size, -shape_size, 0),
		Vector3( shape_size, -shape_size, 0),
		Vector3( shape_size,  shape_size, 0),
		Vector3(-shape_size,  shape_size, 0)]
	square.edges = [Vector2i(0, 1), Vector2i(1, 2), Vector2i(2, 3), Vector2i(3, 0)] as Array[Vector2i]
	square.faces = [[0, 3, 2, 1]] as Array[Array]
	return square
	
func _create_cube():
	return ShapeMap.shape_map["Cube"]["3D"][Enums.ShapeDataRetriever.ShapeStrategyIndex].create_shape()
	
func _create_tesseract():
	return ShapeMap.shape_map["Cube"]["4D"][Enums.ShapeDataRetriever.ShapeStrategyIndex].create_shape()
