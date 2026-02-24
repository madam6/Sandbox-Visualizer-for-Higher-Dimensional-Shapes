extends PanelContainer

@export var ui_checkbox : CheckBox
@export var matrix_checkbox : CheckBox
@export var axes_ui_checkbox : CheckBox
@export var axes_3d_checkbox : CheckBox

@export var download_button : Button
@export var close_button : Button

@export var main_ui_layer : CanvasLayer 
@export var edu_ui_layer : CanvasLayer
@export var matrix_display : Control
@export var rotation_sliders : Control
@export var main_edu_button : Button


func _ready() -> void:
	download_button.pressed.connect(_on_download_pressed)
	close_button.pressed.connect(
		func():
			main_edu_button.disabled = false
			queue_free())

	ui_checkbox.button_pressed = true
	matrix_checkbox.button_pressed = true
	axes_ui_checkbox.button_pressed = true
	axes_3d_checkbox.button_pressed = true


func _on_download_pressed() -> void:
	var main_ui_states = {}
	for child in main_ui_layer.get_children():
		main_ui_states[child] = child.visible
		
	var edu_ui_states = {}
	for child in edu_ui_layer.get_children():
		edu_ui_states[child] = child.visible

	var axes_3d_was_visible = Controller.show_axes

	self.visible = false

	if not ui_checkbox.button_pressed:
		for child in main_ui_layer.get_children():
			child.visible = false
		for child in edu_ui_layer.get_children():
			child.visible = false

	if matrix_display:
		matrix_display.visible = matrix_checkbox.button_pressed
	if rotation_sliders:
		rotation_sliders.visible = axes_ui_checkbox.button_pressed

	Controller.toggle_axes(axes_3d_checkbox.button_pressed)

	await get_tree().process_frame
	await get_tree().process_frame

	Controller.save_visualization()

	for child in main_ui_states:
		if is_instance_valid(child):
			child.visible = main_ui_states[child]

	for child in edu_ui_states:
		if is_instance_valid(child):
			child.visible = edu_ui_states[child]

	Controller.toggle_axes(axes_3d_was_visible)
	main_edu_button.disabled = false

	queue_free()
