extends Selector

@export var dimension_selector: Selector

func _ready() -> void:
	if selected == -1 and item_count > 0:
		select(0)

	if not dimension_selector:
		push_error("DimensionSelector on ShapeSelector is not set")
		return

	if item_count > 0:
		_on_shape_selected(selected)
		
	check_items()
	item_selected.connect(_on_shape_selected)

func _on_shape_selected(_index: int) -> void:
	dimension_selector.update_dimension_selector()

func check_items() -> void:
	var config_shapes = ShapeMap.shape_map.keys()

	var dropdown_items := {}
	for i in range(item_count):
		dropdown_items[get_item_text(i)] = true

	for shape_name in config_shapes:
		if not dropdown_items.has(shape_name):
			push_warning("ShapeMap contains '%s', but it is missing from the Selector UI." % shape_name)
