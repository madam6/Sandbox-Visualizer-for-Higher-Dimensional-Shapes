extends CheckButton

@export var rotation_sliders : VBoxContainer

func _ready() -> void:
	if not rotation_sliders:
		push_error("Rotation sliders container is not set.")
		return
		
	
	toggled.connect(_on_check_button_toggled)
	
	
func _on_check_button_toggled(_toggled_on: bool) -> void:
	rotation_sliders.switch_sliders()
