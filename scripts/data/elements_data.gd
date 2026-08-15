@tool
class_name ElementsDB
extends RefCounted

static var _elements: Dictionary = {}

static func get_element(symbol: String) -> Dictionary:
	if _elements.is_empty():
		_initialize_database()

	return _elements.get(symbol, {})

static func _initialize_database() -> void:
	var file := FileAccess.open("res://data/elements.json", FileAccess.READ)
	if not file:
		push_error("Failed to open elements.json")
		return

	var json_data = JSON.parse_string(file.get_as_text())
	if typeof(json_data) != TYPE_DICTIONARY and typeof(json_data) != TYPE_ARRAY:
		push_error("Invalid JSON format in elements.json")
		return

	var element_list = json_data.data if typeof(json_data) == TYPE_DICTIONARY else json_data

	for element in element_list:
		var symbol = str(element["symbol"])
		var color = element.get("cpk_color")
		if color == null or str(color).is_empty():
			color = "#FFFFFF"

		var radius = element.get("atomic_radius")
		if radius == null:
			radius = 25.0

		_elements[symbol] = {
			"color": Color.html(str(color)),
			"radius": float(radius) / 100.0
		}
