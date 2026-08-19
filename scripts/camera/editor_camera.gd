extends Camera3D

@export var orbit_target: Vector3 = Vector3.ZERO

@export var orbit_sensitivity: float = 0.01
@export var look_sensitivity: float = 0.005
@export var pan_sensitivity: float = 0.001

@export var zoom_step: float = 0.9
@export var min_distance: float = 0.5
@export var max_distance: float = 200.0

@export var fly_speed: float = 5.0
@export var fly_speed_fast_multiplier: float = 4.0

enum DragMode { NONE, ORBIT, PAN, FREE_LOOK }
var _drag_mode := DragMode.NONE

var _yaw: float
var _pitch: float
var _distance: float


func _ready() -> void:
	_sync_spherical_from_transform()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion and _drag_mode != DragMode.NONE:
		_handle_mouse_motion(event)


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	match event.button_index:
		MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				_start_drag(DragMode.PAN if event.shift_pressed else DragMode.ORBIT)
			else:
				_end_drag()
		MOUSE_BUTTON_RIGHT:
			if event.pressed:
				_start_drag(DragMode.FREE_LOOK)
			else:
				_end_drag()
		MOUSE_BUTTON_WHEEL_UP:
			_zoom(zoom_step)
		MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(1.0 / zoom_step)


func _start_drag(mode: DragMode) -> void:
	_drag_mode = mode
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _end_drag() -> void:
	if _drag_mode == DragMode.FREE_LOOK:
		_sync_spherical_from_transform()
	_drag_mode = DragMode.NONE
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	match _drag_mode:
		DragMode.ORBIT:
			_orbit(event.relative)
		DragMode.PAN:
			_pan(event.relative)
		DragMode.FREE_LOOK:
			_look(event.relative)


func _process(delta: float) -> void:
	if _drag_mode == DragMode.FREE_LOOK:
		_fly(delta)


func _sync_spherical_from_transform() -> void:
	var offset := global_position - orbit_target
	_distance = clamp(offset.length(), min_distance, max_distance)
	if _distance > 0.0001:
		_yaw = atan2(offset.x, offset.z)
		_pitch = clamp(asin(clamp(offset.y / _distance, -1.0, 1.0)), -1.5, 1.5)
	orbit_target = global_position - _spherical_offset()


func _spherical_offset() -> Vector3:
	return Vector3(
		_distance * cos(_pitch) * sin(_yaw),
		_distance * sin(_pitch),
		_distance * cos(_pitch) * cos(_yaw)
	)


func _apply_spherical() -> void:
	global_position = orbit_target + _spherical_offset()
	look_at(orbit_target, Vector3.UP)


func _orbit(rel: Vector2) -> void:
	_yaw -= rel.x * orbit_sensitivity
	_pitch = clamp(_pitch + rel.y * orbit_sensitivity, -1.5, 1.5)
	_apply_spherical()


func _pan(rel: Vector2) -> void:
	var right := global_transform.basis.x
	var up := global_transform.basis.y
	var delta := (-right * rel.x + up * rel.y) * pan_sensitivity * _distance
	orbit_target += delta
	global_position += delta


func _zoom(factor: float) -> void:
	_distance = clamp(_distance * factor, min_distance, max_distance)
	_apply_spherical()


func _look(rel: Vector2) -> void:
	rotate_y(-rel.x * look_sensitivity)
	rotate_object_local(Vector3.RIGHT, -rel.y * look_sensitivity)


func _fly(delta: float) -> void:
	var move := Vector3.ZERO
	if Input.is_physical_key_pressed(KEY_W):
		move -= transform.basis.z
	if Input.is_physical_key_pressed(KEY_S):
		move += transform.basis.z
	if Input.is_physical_key_pressed(KEY_A):
		move -= transform.basis.x
	if Input.is_physical_key_pressed(KEY_D):
		move += transform.basis.x
	if Input.is_physical_key_pressed(KEY_E):
		move += transform.basis.y
	if Input.is_physical_key_pressed(KEY_Q):
		move -= transform.basis.y

	if move.length_squared() == 0.0:
		return

	var speed := fly_speed
	if Input.is_physical_key_pressed(KEY_SHIFT):
		speed *= fly_speed_fast_multiplier

	global_position += move.normalized() * speed * delta
