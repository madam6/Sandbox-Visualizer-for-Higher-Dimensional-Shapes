extends PanelContainer

# UI Input Interceptor / Scroll Blocker
# 
# This script is attached to background UI panels (like WarningPopup and 
# StartConfirmationPanel) to intentionally trap mouse scroll events.
# 
# Quirk: Because the 3D CameraOrbit script listens to "_unhandled_input" for zooming,
# scrolling the mouse wheel while hovering over a UI menu would accidentally 
# zoom the camera in the background. By calling "accept_event()" here, we consume 
# the input at the UI Control layer, preventing it from reaching the 3D world
func _gui_input(event : InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			accept_event()