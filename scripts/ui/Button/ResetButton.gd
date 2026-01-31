extends Button

@export var camera_node : Node3D
@export var rotation_sliders : VBoxContainer

func _ready() -> void:
	if not camera_node:
		push_error("Camera node was not setup on the reset button.")
		
	if not rotation_sliders:
		push_error("Rotation node is not setup on reset button.")


func _on_pressed() -> void:
	Controller.reset_controller()
	camera_node.reset_camera_pos()
	rotation_sliders.reset_sliders()
