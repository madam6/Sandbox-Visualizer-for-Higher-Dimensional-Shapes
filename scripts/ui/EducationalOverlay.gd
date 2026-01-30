extends Control

@export var start_panel: PanelContainer
@export var confirm_button: Button
@export var cancel_button: Button

@export var lesson_panel: PanelContainer
@export var title_label: Label
@export var body_label: RichTextLabel
@export var next_button: Button
@export var back_button: Button
@export var main_menu_edu_button: Button

func _ready():
	start_panel.visible = false
	lesson_panel.visible = false

	main_menu_edu_button.pressed.connect(_on_main_menu_edu_pressed)

	confirm_button.pressed.connect(_on_confirm_start)
	cancel_button.pressed.connect(_on_cancel_start)
	back_button.pressed.connect(_on_back_pressed)

	next_button.pressed.connect(_on_next_pressed)
	
	EduController.lesson_step_changed.connect(_on_lesson_step_changed)
	EduController.lesson_ended.connect(_on_lesson_ended)

func _on_back_pressed():
	EduController.previous_step()

func _on_main_menu_edu_pressed():
	start_panel.visible = true
	main_menu_edu_button.visible = false

func _on_cancel_start():
	start_panel.visible = false
	main_menu_edu_button.visible = true

func _on_confirm_start():
	start_panel.visible = false
	lesson_panel.visible = true
	EduController.start_lesson()

func _on_next_pressed():
	EduController.next_step()

func _on_lesson_step_changed(title: String, text: String, btn_text: String):
	title_label.text = title
	body_label.text = text
	next_button.text = btn_text
	if EduController.get_current_step_index() == 0:
		back_button.visible = false

func _on_lesson_ended():
	lesson_panel.visible = false
	start_panel.visible = false
	main_menu_edu_button.visible = true
