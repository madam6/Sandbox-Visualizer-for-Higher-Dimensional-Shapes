extends Button

func _ready() -> void:
	visible = true

	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	Controller.save_visualization()