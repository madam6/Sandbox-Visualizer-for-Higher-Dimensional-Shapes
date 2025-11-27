extends HSlider

@export var rotation_label : Label
@export var camera_controller : Node3D

func _ready() -> void:
	if not rotation_label:
		push_error("Rotation speed slider slider does not have a size label setup.")
		return
		
	if not camera_controller:
		push_error("CameraController is not set on size slider.")
		return
	
	set_value(1.0)

	value_changed.connect(_on_value_changed)

	drag_started.connect(_on_drag_started)
	_on_value_changed(value)

func _on_value_changed(new_value: float) -> void:
	rotation_label.text = "Rotation Speed: " + str(new_value)
	Controller.set_rotation_speed(new_value)

func _on_drag_started() -> void:
	camera_controller.disable_dragging()
