extends Tree

const BTN_COLOR = 0

func _ready():
	columns = 1
	hide_root = false
	scroll_vertical_enabled = false

	var root = create_item()
	root.set_text(0, "Colors")
	root.collapsed = true
	
	custom_minimum_size.y = get_item_area_rect(root).size.y + 6

	_add_color_item(root, "Vertex color", Color.RED)
	_add_color_item(root, "Edge color", Color.GREEN)
	_add_color_item(root, "Face color", Color.BLUE)
	_add_color_item(root, "Selected color", Color.YELLOW)

	button_clicked.connect(_on_button_clicked)
	item_collapsed.connect(_on_item_collapsed)



func _add_color_item(parent: TreeItem, label: String, color: Color):
	var item = create_item(parent)
	item.set_text(0, label)

	item.add_button(0, _make_color_texture(color), BTN_COLOR)
	item.set_metadata(0, color)


func _make_color_texture(color: Color) -> Texture2D:
	var img := Image.create(10, 10, false, Image.FORMAT_RGBA8)
	img.fill(color)

	var tex := ImageTexture.create_from_image(img)
	return tex


func _on_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button: int):
	if id != BTN_COLOR:
		return

	var current_color: Color = item.get_metadata(0)

	var picker_btn = ColorPickerButton.new()
	picker_btn.color = current_color
	picker_btn.custom_minimum_size = Vector2(0, 0)
	get_tree().current_scene.add_child(picker_btn)

	var popup = picker_btn.get_popup()
	popup.popup()

	picker_btn.color_changed.connect(
	func(new_color: Color):
		item.set_metadata(0, new_color)
		var tex = _make_color_texture(new_color)
		item.set_button(0, id, tex)
		)

	picker_btn.popup_closed.connect(func():
		picker_btn.queue_free())
		
		
func _on_item_collapsed(item: TreeItem):
	var collapsed = item.collapsed

	if collapsed:
		custom_minimum_size.y = get_item_area_rect(item).size.y + 8
	else:
		custom_minimum_size.y = 175
