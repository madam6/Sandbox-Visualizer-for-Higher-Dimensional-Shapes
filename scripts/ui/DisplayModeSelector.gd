extends Selector

@export var CameraController : Node3D

func _ready() -> void:
	if not CameraController:
		push_error("CameraController on DisplayModeSelector is not set")
		return
	item_selected.connect(_on_display_mode_changed)

func _on_display_mode_changed(_index: int) -> void:
	CameraController.disable_dragging()
	Renderer.set_display_mode(_index)
