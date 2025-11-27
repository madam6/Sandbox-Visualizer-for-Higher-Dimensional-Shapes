extends OptionButton

class_name Selector

func get_selected_item_name() -> String:
	if selected == -1:
		return ""
	
	return get_item_text(selected)
