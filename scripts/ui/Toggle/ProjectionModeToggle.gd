extends CheckButton

@export var dimension_options: Selector
@export var shape_options: Selector

func _ready() -> void:
	if not dimension_options:
		push_error("Missing dependencies in ProjectionToggle.")
		return
	
	toggled.connect(_on_projection_toggled)

	dimension_options.item_selected.connect(_on_dimension_changed)
	shape_options.item_selected.connect(_on_shape_changed)
	
	_update_projection_logic()


func _on_shape_changed(_index: int) -> void:
	_update_projection_logic()

func _on_dimension_changed(_index: int) -> void:
	_update_projection_logic()

func _on_projection_toggled(_toggled_on: bool) -> void:
	_update_projection_logic()


func _update_projection_logic() -> void:
	var current_dim_name : String = dimension_options.get_selected_item_name()
	var use_perspective : bool = button_pressed

	var new_projector : ProjectionStrategy = null

	match current_dim_name:
		"4D":
			new_projector = ShapeMap.perspective_projector4d if use_perspective else ShapeMap.default_projector4d
		"5D":
			new_projector = ShapeMap.perspective_projector5d if use_perspective else ShapeMap.default_projector5d
		_:
			_set_layout_visibility(false)


	if new_projector:
		Controller.set_new_projector(new_projector)
		
		if new_projector == ShapeMap.default_projector3d:
			_set_layout_visibility(false)
		else:
			_set_layout_visibility(true)
			
func _set_layout_visibility(new_is_visible: bool) -> void:
	if new_is_visible:
		modulate.a = 1.0 
		mouse_filter = Control.MOUSE_FILTER_STOP 
	else:
		modulate.a = 0.0 
		mouse_filter = Control.MOUSE_FILTER_IGNORE
