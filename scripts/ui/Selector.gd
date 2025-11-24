extends OptionButton

class_name Selector

var controller : Node
var selected_item : int

func _ready() -> void:
	selected_item = get_selected_id()
	controller = get_node("/root/Main/Controller")
	
func _process(_delta : float):
	push_error("Selector._process() must be implemented.")

func get_selected_item_name() -> String:
	assert(selected_item >= 0 && selected_item <= 10000, "Uninitialised selected_item in Selector")
	return get_item_text(selected_item)
