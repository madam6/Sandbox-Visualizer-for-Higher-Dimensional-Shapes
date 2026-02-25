extends PanelContainer

@export var main_menu_layer : CanvasLayer
@export var edu_layer : CanvasLayer
@export var okay_button : Button

const FADE_DURATION: float = 0.7

func _ready() -> void:
	main_menu_layer.visible = false
	edu_layer.visible = false

	if okay_button:
		okay_button.pressed.connect(_on_okay_button_pressed)

func _on_okay_button_pressed() -> void:
	Controller.turn_processing_on()

	main_menu_layer.visible = true
	edu_layer.visible = true
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	_fade_in_layer_children(main_menu_layer, tween)
	_fade_in_layer_children(edu_layer, tween)

	tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
	
	tween.chain().tween_callback(func(): queue_free())


func _fade_in_layer_children(layer: CanvasLayer, tween: Tween) -> void:
	for child in layer.get_children():
		if child is CanvasItem:
			child.modulate.a = 0.0 
			tween.tween_property(child, "modulate:a", 1.0, FADE_DURATION)
