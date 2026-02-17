extends Button

@export var topic_key : String = ""

func _ready() -> void:
	visible = false

	pressed.connect(_on_pressed)

	EduController.labarotry_mode_toggled.connect(_on_lab_toggled)
	_on_lab_toggled(EduController.is_labarotory_active)
	

func _on_lab_toggled(active : bool) -> void:
	visible = active

func _on_pressed() -> void:
	EduController.request_explanation(topic_key)