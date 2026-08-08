@tool
class_name ElementsDB
extends RefCounted

static var elements_json = preload("res://data/elements.json")
static var elements_data: Dictionary = {}

static func _static_init() -> void:
	if elements_json and elements_json.data:
		for element in elements_json.data:
			var symbol = element["symbol"]
			var color = element.get("cpk_color")
			if color == null:
				color = "#FFFFFF"
			var radius = element.get("atomic_radius")
			if radius == null:
				radius = 25.0
			elements_data[symbol] = {
				"color": Color(color.substr(1, 6)),
				"radius": radius / 100.0
			}
