extends HSlider

@export var SizeLabel : Label
@export var CameraController : Node3D
var current_size : float = 0

func _ready() -> void:
	if not SizeLabel:
		push_error("Size slider does not have a size label setup.")
		return
		
	if not Controller:
		push_error("Controller is not set on size slider.")
		return
		
	if not CameraController:
		push_error("CameraController is not set on size slider.")
		return
	
	current_size = value

func _process(_delta: float) -> void:
	if value!=current_size:
		CameraController.disable_dragging()
		current_size = value
		
		SizeLabel.text = "Size:" + str(current_size)
		Controller.set_shape_size(current_size)
