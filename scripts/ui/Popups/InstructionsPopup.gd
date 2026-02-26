extends PanelContainer

var main_edu_button : Button
var download_button : Button
@export var okay_button : Button

func _ready() -> void:
	okay_button.pressed.connect(_on_okay_pressed)

func _on_okay_pressed() -> void:
	main_edu_button.disabled = false
	download_button.disabled = false
	queue_free()

func _gui_input(event : InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			accept_event()