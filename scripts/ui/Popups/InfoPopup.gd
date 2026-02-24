extends PanelContainer

class_name InfoPopup

@export var title_label : Label
@export var body_label : RichTextLabel
@export var close_button : Button

func _ready() -> void:
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

func setup_data(title : String, text : String) -> void:
	if title_label : title_label.text = title
	if body_label : body_label.text = text

func _on_close_pressed() -> void:
	queue_free()