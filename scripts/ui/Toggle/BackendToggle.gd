extends CheckButton

# Switches the maths between GDScript and the C++ GDExtension, and shows how long
# rotation + projection takes per frame with the current choice.
# The row hides itself when the extension isn't loaded (web build, or not compiled yet).

@export var row : Control
@export var timing_label : Label

const REFRESH_SECONDS : float = 0.25

var _since_refresh : float = 0.0

func _ready() -> void:
	if not row or not timing_label:
		push_error("BackendToggle needs row and timing_label set.")
		return

	if not NativeBackend.is_available():
		row.visible = false
		set_process(false)
		return

	button_pressed = ShapeMap.use_native
	toggled.connect(_on_toggled)

func _on_toggled(toggled_on : bool) -> void:
	ShapeMap.set_native_backend(toggled_on)
	timing_label.text = ""

func _process(delta : float) -> void:
	_since_refresh += delta
	if _since_refresh < REFRESH_SECONDS:
		return
	_since_refresh = 0.0

	if Controller.math_time_usec >= 0.0:
		timing_label.text = "%d µs/frame" % roundi(Controller.math_time_usec)
