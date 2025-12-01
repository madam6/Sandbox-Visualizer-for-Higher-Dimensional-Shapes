extends VBoxContainer

@export var camera_controller : Node3D


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

func _ready() -> void:
	if not camera_controller:
		push_error("CameraController is not set on size slider.")
		return
	
	add_theme_constant_override("separation", 10)
	
	set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	grow_vertical = Control.GROW_DIRECTION_BEGIN
	
	update_rotator()
	
	for plane_enum in PLANE_NAMES:
		_create_slider_row(plane_enum)
	
	_sync_sliders(current_rotator.supported_planes.keys())

func update_rotator() -> void:
	current_rotator = Controller.get_current_rotator()
	if not current_rotator:
		return

	var active_planes: Array = current_rotator.supported_planes.keys()
	
	_sync_sliders(active_planes)

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
	slider.max_value = 360
	slider.step = 1.0
	slider.value = 0 
	row.add_child(slider)
	
	var label_val = Label.new()
	label_val.name = "ValueLabel"
	label_val.text = "0°"
	label_val.custom_minimum_size.x = 40
	label_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(label_val)

	slider.value_changed.connect(_on_slider_value_changed.bind(plane_enum, label_val))
	slider.drag_started.connect(_on_drag_started)
	
	add_child(row)

func _on_slider_value_changed(value: float, plane_enum: int, label_to_update: Label) -> void:
	label_to_update.text = str(value) + "°"

	Controller.rotate_shape_absolute(value, plane_enum)

func _on_drag_started() -> void:
	camera_controller.disable_dragging()

func _find_child_by_plane(plane_enum: int) -> Node:
	for child in get_children():
		if child.has_meta("plane_enum") and child.get_meta("plane_enum") == plane_enum:
			return child
	return null
