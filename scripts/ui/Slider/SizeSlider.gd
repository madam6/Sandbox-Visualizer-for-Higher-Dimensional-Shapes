extends HSlider

@export var size_label : Label
@export var camera_controller : Node3D

func _ready() -> void:
	if not size_label:
		push_error("Size slider does not have a size label setup.")
		return
		
	if not camera_controller:
		push_error("CameraController is not set on size slider.")
		return
	

	value_changed.connect(_on_value_changed)

	drag_started.connect(_on_drag_started)
	_on_value_changed(value)

func _on_value_changed(new_value: float) -> void:
	size_label.text = "Size: " + str(new_value)
	Controller.set_shape_size(new_value)

func _on_drag_started() -> void:
	camera_controller.disable_dragging()
