extends Node

signal lesson_started
signal lesson_step_changed(title: String, description: String, button_text : String)
signal lesson_ended


class LessonStep:
	var title: String
	var text: String
	var btn_text: String
	var shape_data: ShapeData
	
	
var _steps : Array[LessonStep] = []
var _current_step_index : int = -1

func _ready() -> void:
	_build_schedule()
	
	
func start_lesson():
	_current_step_index = 0
	Controller.reset_selection_info()
	Controller.reset_rotation()
	_load_step(_current_step_index)
	lesson_started.emit()
	
func next_step():
	_current_step_index += 1
	if _current_step_index >= _steps.size():
		end_lesson()
	else:
		_load_step(_current_step_index)
		
		
func end_lesson():
	pass

func _load_step(step_index : int):
	pass	

func _build_schedule():
	pass
