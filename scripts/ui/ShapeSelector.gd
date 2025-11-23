extends OptionButton

var selected_item: int
var controller : Node

func _ready() -> void:
	check_items()
	selected_item = get_selected_id()
	controller = get_node("/root/Main/Controller")

func _process(_delta: float) -> void:
	if get_selected_id() != selected_item:
		selected_item = get_selected_id()
		controller.set_shape_strategy(ShapeMap.shape_map[get_item_text(selected_item)]["3D"])
		

func check_items() -> void:
	var shapes = ShapeMap.shape_map.keys()

	var existing_items := {}
	for i in range(get_item_count()):
		existing_items[get_item_text(i)] = true

	for shape_name: String in shapes.keys():
		if not existing_items.has(shape_name):
			push_error("Added option to ShapeSelector is not present in the config.")
