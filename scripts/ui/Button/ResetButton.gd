extends Button

@export var camera_node : Node3D

func _ready() -> void:
	if not camera_node:
		push_error("Camera node was not setup on the reset button.")


func _on_pressed() -> void:
	Controller.reset_rotation()
	camera_node.reset_camera_pos()
