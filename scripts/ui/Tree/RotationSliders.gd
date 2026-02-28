extends VBoxContainer

@export var camera_controller : Node3D
@export var matrix_display : MatrixDisplay

class RotationSlider:
	var container: HBoxContainer
	var title_label: Label
	var slider: HSlider
	var value_label: Label
	var plane_enum: int


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

var current_rotator : BaseRotator
var sliders : Array
var static_rotation : bool = true

func _ready() -> void:
	if not camera_controller:
		push_error("CameraController is not set on size slider.")
		return
	
	add_theme_constant_override("separation", 10)
	
	set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	grow_vertical = Control.GROW_DIRECTION_BEGIN
	EduController.labarotry_mode_toggled.connect(_on_lab_toggled)
	for plane_enum in PLANE_NAMES:
		_create_slider_row(plane_enum)
	
	update_rotator()

func _sync() -> void:
	var active_planes: Array = current_rotator.supported_planes.keys()
	_sync_sliders(active_planes)

func _on_lab_toggled(_toggled : bool) -> void:
	update_rotator()

func update_rotator() -> void:
	current_rotator = Controller.get_current_rotator()
	if not current_rotator:
		return

	_sync()

func _sync_sliders(active_planes: Array) -> void:
	for child in get_children():
		var child_plane = child.get_meta("plane_enum", -1)
		if child_plane == -1:
			continue        
		child.visible = child_plane in active_planes

func _create_slider_row(plane_enum: int) -> void:
	var plane_string = PLANE_NAMES.get(plane_enum, "UNK")

	var row = HBoxContainer.new()
	row.name = "Row_" + plane_string
	row.set_meta("plane_enum", plane_enum)

	var label_name = Label.new()
	label_name.text = plane_string + ":"
	label_name.custom_minimum_size.x = 40
	row.add_child(label_name)

	var slider = HSlider.new()
	slider.name = "Slider"
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.min_value = 0
	slider.step = 1.0
	slider.value = 0 
	row.add_child(slider)
	
	var label_val = Label.new()
	label_val.name = "ValueLabel"
	label_val.custom_minimum_size.x = 40
	label_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(label_val)
	slider.drag_started.connect(_on_drag_started)
	
	slider.max_value = 360
		
	label_val.text = "0.0°"
	slider.value_changed.connect(_on_slider_value_changed_regular.bind(plane_enum, label_val))
		
	var slider_struct = RotationSlider.new()
	slider_struct.container = row
	slider_struct.title_label = label_name
	slider_struct.slider = slider
	slider_struct.value_label = label_val
	slider_struct.plane_enum = plane_enum
	sliders.append(slider_struct)
	
	add_child(row)

func _on_slider_value_changed_regular(value: float, plane_enum: int, label_to_update: Label) -> void:
	label_to_update.text = str(value) + "°"

	Controller.rotate_shape_absolute(value, plane_enum)

	if matrix_display and matrix_display.visible:
		var mat = Controller.get_rotation_matrix_for_plane(plane_enum, value)

		var indices = ShapeMap.planes_array_map.get(plane_enum, [])

		var plane_name = PLANE_NAMES.get(plane_enum, "Unknown")

		matrix_display.update_matrix(mat, indices, plane_name)

func _on_slider_value_changed_cont(value: float, plane_enum: int, label_to_update: Label) -> void:
	label_to_update.text = str(value)
	Controller.set_speed_in_plane(plane_enum, value)

	if matrix_display and matrix_display.visible:
		var mat = Controller.get_rotation_matrix_for_plane(plane_enum, value)

		var indices = ShapeMap.planes_array_map.get(plane_enum, [])

		var plane_name = PLANE_NAMES.get(plane_enum, "Unknown")

		matrix_display.update_matrix(mat, indices, plane_name)

func _on_drag_started() -> void:
	camera_controller.disable_dragging()

func _find_child_by_plane(plane_enum: int) -> Node:
	for child in get_children():
		if child.has_meta("plane_enum") and child.get_meta("plane_enum") == plane_enum:
			return child
	return null

func reset_sliders() -> void:
	for slider in sliders:
		slider.slider.value = 0

func switch_sliders() -> void:
	static_rotation = !static_rotation
	for slider in sliders:
		var callable_regular = _on_slider_value_changed_regular.bind(slider.plane_enum, slider.value_label)
		var callable_cont = _on_slider_value_changed_cont.bind(slider.plane_enum, slider.value_label)
		
		if static_rotation:
			if slider.slider.value_changed.is_connected(callable_cont):
				slider.slider.value_changed.disconnect(callable_cont)

			if not slider.slider.value_changed.is_connected(callable_regular):
				slider.slider.value_changed.connect(callable_regular)

			slider.slider.max_value = 360
			slider.slider.step = 1
			slider.value_label.text = str(slider.slider.value) + "°"
			Controller.reset_speeds()

		else:
			if slider.slider.value_changed.is_connected(callable_regular):
				slider.slider.value_changed.disconnect(callable_regular)
			
			if not slider.slider.value_changed.is_connected(callable_cont):
				slider.slider.value_changed.connect(callable_cont)

			slider.slider.max_value = 7
			slider.slider.step = 0.25
			slider.value_label.text = str(slider.slider.value)
