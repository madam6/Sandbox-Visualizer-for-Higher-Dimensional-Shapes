extends VBoxContainer

func _ready() -> void:
	grow_vertical = Control.GROW_DIRECTION_BEGIN
	set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)