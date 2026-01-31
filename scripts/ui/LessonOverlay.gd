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

const lesson_tween_time : float = 0.5
const popup_tween_time : float = 0.5

func _ready():
	start_panel.visible = false
	lesson_panel.visible = false
	
	main_menu_edu_button.pressed.connect(_on_main_menu_edu_pressed)

	confirm_button.pressed.connect(_on_confirm_start)
	cancel_button.pressed.connect(_on_cancel_start)
	back_button.pressed.connect(_on_back_pressed)
	skip_button.pressed.connect(_on_skip_button_pressed)

	next_button.pressed.connect(_on_next_pressed)
	
	EduController.lesson_step_changed.connect(_on_lesson_step_changed)
	EduController.lesson_ended.connect(_on_lesson_ended)
	
	title_label.modulate.a = 0.0
	body_label.modulate.a = 0.0
	next_button.modulate.a = 0.0
	back_button.modulate.a = 0.0
	title_label.text = ""
	body_label.text = ""
	next_button.text = ""
	
	

func _on_skip_button_pressed():
	EduController.end_lesson()
	main_menu_edu_button.disabled = false

func _on_back_pressed():
	EduController.previous_step()

func _on_main_menu_edu_pressed():
	_fade_in(start_panel)
	start_panel.visible = true
	main_menu_edu_button.disabled = true

func _on_cancel_start():
	_fade_out(start_panel)
	main_menu_edu_button.disabled = false

func _on_confirm_start():
	mainUI.visible = false
	_fade_out(start_panel, func():
		_fade_in(lesson_panel)
		EduController.start_lesson()
		)

func _on_next_pressed():
	EduController.next_step()

func _on_lesson_step_changed(title: String, text: String, btn_text: String):
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


func _animate_step_in(show_back : bool):
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


func _on_lesson_ended():
	mainUI.visible = true
	lesson_panel.visible = false
	start_panel.visible = false
	main_menu_edu_button.visible = true
	main_menu_edu_button.disabled = false
	
func _fade_in(target_node: CanvasItem, duration: float = popup_tween_time):
	target_node.modulate.a = 0.0
	target_node.visible = true
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target_node, "modulate:a", 1.0, duration)
	
	
func _fade_out(target_node: CanvasItem, on_complete: Callable = Callable(), duration : float = popup_tween_time):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(target_node, "modulate:a", 0.0, duration)
	
	tween.tween_callback(func():
		target_node.visible = false
		if on_complete.is_valid():
			on_complete.call()
			)
