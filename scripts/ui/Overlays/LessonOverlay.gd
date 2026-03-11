extends Control

@export var start_panel: PanelContainer
@export var confirm_button: Button
@export var cancel_button: Button

@export var lesson_panel: PanelContainer
@export var title_label: Label
@export var body_label: RichTextLabel
@export var next_button: Button
@export var back_button: Button
@export var skip_button: Button
@export var main_menu_edu_button: Button
@export var mainUI : Node
@export var download_button : Button
@export var instruction_button : Button

const lesson_tween_time : float = 0.5
const popup_tween_time : float = 0.5

const INFO_POPUP_SCENE = preload("res://scenes/main/InfoPopup.tscn")
const DOWNLOAD_POPUP_SCENE = preload("res://scenes/main/DownloadPopup.tscn")
const INSTRUCTION_POPUP_SCENE = preload("res://scenes/main/InstructionsPopup.tscn")

var active_popup : Node = null

@export var START_LAB : String
@export var START_VISUALISER : String

func _ready():
	body_label.bbcode_enabled = true

	start_panel.visible = false
	lesson_panel.visible = false
	
	main_menu_edu_button.pressed.connect(_on_main_menu_edu_pressed)

	confirm_button.pressed.connect(_on_confirm_start)
	cancel_button.pressed.connect(_on_cancel_start)
	back_button.pressed.connect(_on_back_pressed)
	skip_button.pressed.connect(_on_skip_button_pressed)

	next_button.pressed.connect(_on_next_pressed)

	download_button.pressed.connect(_on_download_pressed)
	instruction_button.pressed.connect(_on_instruction_pressed)
	
	EduController.lesson_step_changed.connect(_on_lesson_step_changed)
	EduController.lesson_ended.connect(_on_lesson_ended)
	EduController.labarotry_mode_toggled.connect(_on_laboratory_toggled)
	EduController.explanation_requested.connect(_on_explanation_requested)

	title_label.modulate.a = 0.0
	body_label.modulate.a = 0.0
	next_button.modulate.a = 0.0
	back_button.modulate.a = 0.0
	title_label.text = ""
	body_label.text = ""
	next_button.text = ""
	

func _on_instruction_pressed() -> void:
	if active_popup != null:
		active_popup.queue_free()
	
	var popup_instance = INSTRUCTION_POPUP_SCENE.instantiate()
	active_popup = popup_instance
	active_popup.z_index = 100

	popup_instance.main_edu_button = main_menu_edu_button
	popup_instance.download_button = download_button

	add_child(popup_instance)
	main_menu_edu_button.disabled = true
	download_button.disabled = true

	_fade_in(popup_instance)

func _on_download_pressed() -> void:
	if active_popup != null:
		active_popup.queue_free()
	
	var popup_instance = DOWNLOAD_POPUP_SCENE.instantiate()
	active_popup = popup_instance
	active_popup.z_index = 100

	popup_instance.main_ui_layer = mainUI
	popup_instance.edu_ui_layer = get_parent()
	popup_instance.matrix_display = get_node("../MatrixDisplay")
	popup_instance.rotation_sliders = mainUI.get_node("RotationSliders")
	popup_instance.main_edu_button = main_menu_edu_button
	popup_instance.instructions_button = instruction_button
	
	add_child(popup_instance)
	main_menu_edu_button.disabled = true
	instruction_button.disabled = true

	_fade_in(popup_instance)

func _on_explanation_requested(title : String, text : String) -> void:
	if active_popup != null:
		active_popup.queue_free()
	
	var popup_instance = INFO_POPUP_SCENE.instantiate()
	active_popup = popup_instance

	add_child(popup_instance)

	_fade_in(popup_instance)

	if popup_instance.has_method("setup_data"):
		popup_instance.setup_data(title, text)

func _on_skip_button_pressed() -> void:
	lesson_panel.visible = false
	instruction_button.disabled = false
	EduController.complete_lesson_go_to_lab()

func _on_back_pressed() -> void:
	EduController.previous_step()

func _on_main_menu_edu_pressed() -> void:
	Controller.turn_processing_off()
	if EduController._has_completed_lesson:
		if EduController.is_labarotory_active:
			EduController.exit_laboratory()
		else:
			EduController.enter_educational_flow()
	else:
		_fade_in(start_panel)
		start_panel.visible = true
		main_menu_edu_button.disabled = true
		download_button.disabled = true
		instruction_button.disabled = true
	Controller.turn_processing_on()

func _on_cancel_start() -> void:
	_fade_out(start_panel)
	main_menu_edu_button.disabled = false
	download_button.disabled = false
	instruction_button.disabled = false

func _on_confirm_start() -> void:
	mainUI.visible = false
	download_button.disabled = false
	_fade_out(start_panel, func():
		_fade_in(lesson_panel)
		EduController.enter_educational_flow()
		)

func _on_next_pressed() -> void:
	EduController.next_step()

# Animates the transition between guided lesson steps.
# Uses parallel tweening to fade out the title, text, and buttons simultaneously.
# Once the fade-out completes, a callback is chained to swap the text content
# invisibly before firing a second animation to fade the new content back in.
func _on_lesson_step_changed(title: String, text: String, btn_text: String) -> void:
	var next_step_index = EduController.get_current_step_index()
	var will_show_back = next_step_index > 0
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(title_label, "modulate:a", 0.0, lesson_tween_time)
	tween.tween_property(body_label, "modulate:a", 0.0, lesson_tween_time)
	tween.tween_property(next_button, "modulate:a", 0.0, lesson_tween_time)
	
	if back_button.visible and not will_show_back:
		tween.tween_property(back_button, "modulate:a", 0.0, lesson_tween_time)
		
	tween.chain().tween_callback(func():
		title_label.text = title
		body_label.text = text
		next_button.text = btn_text
		
		var should_show_back = EduController.get_current_step_index() > 0
		
		if will_show_back:
			back_button.visible = true
			if back_button.modulate.a < 0.1: 
				back_button.modulate.a = 0.0
		else:
			back_button.visible = false
			
		_animate_step_in(should_show_back)
		)


func _animate_step_in(show_back : bool) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(title_label, "modulate:a", 1.0, lesson_tween_time)
	tween.tween_property(body_label, "modulate:a", 1.0, lesson_tween_time)
	tween.tween_property(next_button, "modulate:a", 1.0, lesson_tween_time)
	
	if show_back:
		if back_button.modulate.a < 0.9:
			tween.tween_property(back_button, "modulate:a", 1.0, lesson_tween_time)


func _on_lesson_ended() -> void:
	mainUI.visible = true
	lesson_panel.visible = false
	start_panel.visible = false
	main_menu_edu_button.visible = true
	main_menu_edu_button.disabled = false
	instruction_button.disabled = false
	
func _fade_in(target_node: CanvasItem, duration: float = popup_tween_time) -> void:
	target_node.modulate.a = 0.0
	target_node.visible = true
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target_node, "modulate:a", 1.0, duration)
	
	
func _fade_out(target_node: CanvasItem, on_complete: Callable = Callable(), duration : float = popup_tween_time) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(target_node, "modulate:a", 0.0, duration)
	
	tween.tween_callback(func():
		target_node.visible = false
		if on_complete.is_valid():
			on_complete.call()
			)


func _on_laboratory_toggled(active: bool) -> void:
	if active:
		lesson_panel.visible = false
		start_panel.visible = false
		main_menu_edu_button.text = START_VISUALISER
	else:
		main_menu_edu_button.text = START_LAB
