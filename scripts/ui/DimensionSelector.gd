extends Selector

@export var ShapeSelector : Selector

var selected_shape : String
var allowed_dimensions : Array

func _ready() -> void:
	super._ready()
	
	if ShapeSelector == null:
		push_error("ShapeSelector on DimensionSelector is not set")
		return
		
	_populate_allowed_dimensions()
	

		
func _process(_delta: float) -> void:
	if ShapeSelector == null:
		push_error("DimensionSelector on ShapeSelector is not set")
		return
	
	if get_selected_id() != selected_item:
		selected_item = get_selected_id()
		var shape_map_data = ShapeMap.shape_map[ShapeSelector.get_selected_item_name()][get_selected_item_name()]
		controller.set_shape_strategy(ShapeMap.shape_map[ShapeSelector.get_selected_item_name()][get_selected_item_name()][Enums.ShapeDataRetriever.ShapeStrategyIndex])
		controller.set_new_shape_dimension(shape_map_data[Enums.ShapeDataRetriever.RotatorIndex], shape_map_data[Enums.ShapeDataRetriever.ProjectorIndex])
		

func update_dimension_selector():
	clear()
	_populate_allowed_dimensions()
	
func _populate_allowed_dimensions():
	allowed_dimensions = ShapeMap.shape_map[ShapeSelector.get_selected_item_name()].keys()
	
	for dimension in allowed_dimensions:
		add_item(dimension)
