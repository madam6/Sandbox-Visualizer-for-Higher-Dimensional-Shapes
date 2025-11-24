extends Node3D

var camera : Camera3D

var _pitch : float
var _yaw : float
var _dragging : bool = false

@export var radius : float = 25
@export var rotational_speed : float = 0.01
@export var max_degree_top : float = 80
@export var max_degree_bottom : float =-80


func _ready() -> void:
	for child in get_children():
		if child is Camera3D:
			camera = child
			break
			
	if not camera:
		push_error("CameraOrbit script requires a Camera3D child to function.")
		set_process_input(false)
		return
	
	camera.position = Vector3(0, 0, radius)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	
	_pitch = rotation.x
	_yaw = rotation.y
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
			
	if event is InputEventMouseMotion and _dragging:
		var mouse_delta : Vector2 = event.relative
		
		_yaw -= mouse_delta.x * rotational_speed
		
		_pitch -= mouse_delta.y * rotational_speed
		_pitch = clamp(_pitch, deg_to_rad(max_degree_bottom), deg_to_rad(max_degree_top))
		
		
		rotation = Vector3(_pitch, _yaw, 0)
		
	zoom(event)
		
func zoom(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			radius = max(1.0, radius-0.5)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			radius = min(100.0, radius+0.5)
			
		camera.position = Vector3(0, 0, radius)

func _process(_delta: float) -> void:
	if camera and camera.position.z != radius:
		camera.position = Vector3(0, 0, radius)
	pass
