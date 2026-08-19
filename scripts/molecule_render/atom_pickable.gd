class_name AtomPickable
extends Area3D

signal atom_clicked(pickable: AtomPickable)

var atom: Atom
var atom_index: int

func _ready() -> void:
	input_event.connect(_on_input_event)

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		atom_clicked.emit(self)
