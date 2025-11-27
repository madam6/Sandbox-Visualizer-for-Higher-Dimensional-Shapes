extends Selector

@export var ShapeSelector : Selector
@export var CameraController : Node3D

func _ready() -> void:
	if not ShapeSelector:
		push_error("ShapeSelector on DimensionSelector is not set")
		return

	item_selected.connect(_on_dimension_changed)
	
	ShapeSelector.item_selected.connect(_on_shape_changed)
	_on_dimension_changed(selected)

func _on_dimension_changed(_index: int) -> void:
	CameraController.disable_dragging()
	var shape_name := ShapeSelector.get_selected_item_name()
	var dim_name := get_item_text(_index)

	if not ShapeMap.shape_map.has(shape_name) or not ShapeMap.shape_map[shape_name].has(dim_name):
		return

	var shape_map_data = ShapeMap.shape_map[shape_name][dim_name]

	Controller.update_shape_settings(
		shape_map_data[Enums.ShapeDataRetriever.ShapeStrategyIndex],
		shape_map_data[Enums.ShapeDataRetriever.RotatorIndex],
		shape_map_data[Enums.ShapeDataRetriever.ProjectorIndex]
	)

func _on_shape_changed(_index: int) -> void:
	update_dimension_selector()

func update_dimension_selector():
	clear()
	_populate_allowed_dimensions()

	if get_item_count() > 0:
		select(0)
		_on_dimension_changed(0)

func _populate_allowed_dimensions():
	var shape_name = ShapeSelector.get_selected_item_name()
	if ShapeMap.shape_map.has(shape_name):
		var allowed_dimensions = ShapeMap.shape_map[shape_name].keys()
		for dimension in allowed_dimensions:
			add_item(dimension)
