class_name Atom extends RefCounted

var name: String
var position: Vector3
var radius: float
var color: Color

func _init(_name, _position, _radius, _color) -> void:
	name = _name
	position = _position
	radius = _radius
	color = _color
