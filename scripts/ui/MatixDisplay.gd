extends PanelContainer

class_name MatrixDisplay

var vbox : VBoxContainer
var title_label : Label

var grid : GridContainer
var cells : Array[Label] = []
var active_dim : int = 0

var color_default := Color(0.8, 0.8, 0.8, 0.5)
var color_highlight := Color(1, 1, 0, 1)
var bg_default := StyleBoxFlat.new()
var bg_highlight := StyleBoxFlat.new()

func _ready() -> void:
	grow_vertical = Control.GROW_DIRECTION_BEGIN
	set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)

	bg_default.bg_color = Color(0,0,0,0.2)
	bg_highlight.bg_color = Color(1, 1, 0, 0.1)

	vbox = VBoxContainer.new()
	add_child(vbox)

	title_label = Label.new()
	title_label.text = "Rotation Matrix"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_label)

	grid = GridContainer.new()
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(grid)
	EduController.switch_overlay_visibility.connect(_on_switch_overlay_visibility)

	visible = false
	#For initial display
	update_matrix(Controller.get_rotation_matrix_for_plane(0, 0), ShapeMap.planes_array_map.get(0, []))

func _on_switch_overlay_visibility(visibility : bool) -> void:
	visible = visibility

func setup_grid(dimension : int) -> void:
	if active_dim == dimension : return
	active_dim = dimension

	for child in grid.get_children():
		child.queue_free()
	cells.clear()

	grid.columns = dimension

	for i in range(dimension * dimension):
		var panel = PanelContainer.new()
		panel.add_theme_stylebox_override("panel", bg_default)

		var lbl = Label.new()
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.text = "0.0"
		lbl.custom_minimum_size = Vector2(40, 30)

		panel.add_child(lbl)
		grid.add_child(panel)
		cells.append(lbl)

	
func update_matrix(matrix : Array, affected_indices : Array = [], plane_name : String = "") -> void:
	if plane_name != "":
		title_label.text = "Rotation matrix for plane: " + plane_name
	
	if matrix.size() != active_dim:
		setup_grid(matrix.size())
	
	var flat_idx = 0
	for r in range(active_dim):
		for c in range(active_dim):
			var val = matrix[r][c]
			var lbl = cells[flat_idx]
			var panel = lbl.get_parent() as PanelContainer

			if is_zero_approx(val): val = 0.0
			lbl.text = "%.2f" % val

			var is_active = (r in affected_indices) and (c in affected_indices)

			if is_active:
				lbl.modulate = color_highlight
				panel.add_theme_stylebox_override("panel", bg_highlight)
			else:
				lbl.modulate = color_default
				panel.add_theme_stylebox_override("panel", bg_default)

			flat_idx += 1
