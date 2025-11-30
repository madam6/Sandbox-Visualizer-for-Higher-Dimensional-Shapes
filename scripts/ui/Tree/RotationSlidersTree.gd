extends Tree

var current_rotator : BaseRotator
const PLANE_NAMES: Dictionary = {
	Enums.PLANES.XY: "XY",
	Enums.PLANES.XZ: "XZ",
	Enums.PLANES.YZ: "YZ",
	Enums.PLANES.XW: "XW",
	Enums.PLANES.YW: "YW",
	Enums.PLANES.ZW: "ZW",
	Enums.PLANES.XV: "XV",
	Enums.PLANES.YV: "YV",
	Enums.PLANES.ZV: "ZV",
	Enums.PLANES.WV: "WV",
}
var tree_root : TreeItem

func _get_plane_name(plane: Enums.PLANES) -> String:
	return PLANE_NAMES.get(plane, "UNKNOWN")

func _ready() -> void:
	columns = 2
	set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	grow_vertical = Control.GROW_DIRECTION_BEGIN
	
	set_column_title(0, "Plane")
	set_column_title(1, "Degree")
	set_column_titles_visible(true)
	
	tree_root = create_item()
	set_hide_root(true)

	update_rotator()


func _item_exists(item_name : String) -> bool:
	var item = tree_root.get_first_child()
	while item:
		if item.get_text(0) == item_name:
			return true
		item = item.get_next()
	return false
	
func _total_height() -> float:
	var result = 0
	var item = tree_root.get_first_child()
	while item:
		result += get_item_area_rect(item).size.y
		item = item.get_next()
	return result + get_item_area_rect(tree_root).size.y + 40

func convert_enums_to_strings(enums_array: Array) -> Array:
	var result : Array = []
	for value in enums_array:
		result.append(_get_plane_name(value))
	return result

func _sync_tree_items(planes_to_keep: Array) -> void:
	if not tree_root: return
	
	var current_item : TreeItem = tree_root.get_first_child()
	
	while current_item:
		var next_item = current_item.get_next()
		
		var current_plane_name = current_item.get_text(0)
		
		if current_plane_name not in planes_to_keep:
			current_item.free()
		
		current_item = next_item
		
	for plane in planes_to_keep:
		if not _item_exists(plane):
			_create_single_rotator(plane)
	
	custom_minimum_size.y = _total_height()
	

func _create_single_rotator(plane_name: String) -> void:
	var item = create_item(tree_root)
	item.set_text(0, plane_name)
	
	item.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
	item.set_range_config(1, 0.0, 360, 1.0)
	
	item.set_range(1, 0)
	item.set_editable(1, true)

func update_rotator() -> void:
	current_rotator = Controller.get_current_rotator()
	
	var target_plane_names = convert_enums_to_strings(current_rotator.supported_planes.keys())
	_sync_tree_items(target_plane_names)
