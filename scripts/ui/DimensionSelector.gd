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
		var rotator_projector_pair = ShapeMap.shape_dimension_map[ShapeSelector.get_selected_item_name()][get_selected_item_name()]
		assert(rotator_projector_pair.size() == 2, "Rotator-Projector pair in shape dimension part didnt return a 2-ple, perhaps request keys are incorrect?")
		controller.set_shape_strategy(ShapeMap.shape_map[ShapeSelector.get_selected_item_name()][get_selected_item_name()])
		controller.set_new_shape_dimension(rotator_projector_pair[0], rotator_projector_pair[1])
		

func update_dimension_selector():
	clear()
	_populate_allowed_dimensions()
	
func _populate_allowed_dimensions():
	allowed_dimensions = ShapeMap.shape_map[ShapeSelector.get_selected_item_name()].keys()
	
	for dimension in allowed_dimensions:
		add_item(dimension)
