@tool
class_name ElementsDB
extends Resource

static var elements: Dictionary = {}
static var _instance: ElementsDB = preload("res://data/elements_db.tres")

static func get_element(symbol: String) -> Dictionary:
	if _instance:
		return _instance.elements.get(symbol)
	else:
		push_error("Tried to access elements data that is not initlized")
		return {}
