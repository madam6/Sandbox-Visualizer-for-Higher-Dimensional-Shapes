extends Selector

@export var DimensionSelector : Selector

func _ready() -> void:
	super._ready()
	check_items()

func _process(_delta: float) -> void:
	if DimensionSelector == null:
		push_error("DimensionSelector on ShapeSelector is not set")
		return
	
	if get_selected_id() != selected_item:
		selected_item = get_selected_id()
		_set_new_shape()
	

func _set_new_shape() -> void:
	controller.set_shape_strategy(ShapeMap.shape_map[get_selected_item_name()]["3D"][Enums.ShapeDataRetriever.ShapeStrategyIndex])
	controller.set_new_shape_dimension(ShapeMap.default_rotator3D, ShapeMap.default_projector3d)
	DimensionSelector.update_dimension_selector()

func get_selected_item_name() -> String:
	return get_item_text(selected_item)

func check_items() -> void:
	var shapes = ShapeMap.shape_map.keys()

	var existing_items := {}
	for i in range(get_item_count()):
		existing_items[get_item_text(i)] = true

	for shape_name: String in shapes:
		if not existing_items.has(shape_name):
			push_error("Added option to ShapeSelector is not present in the config.")
