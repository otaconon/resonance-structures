@tool
extends EditorScript

func _run() -> void:
	var db = ElementsDB.new()
	var elements_json = preload("res://data/elements.json")
	if elements_json and elements_json.data:
			for element in elements_json.data:
				var symbol = element["symbol"]
				var color = element.get("cpk_color")
				if color == null:
					color = "#FFFFFF"
				var radius = element.get("atomic_radius")
				if radius == null:
					radius = 25.0
				db.elements[symbol] = {
					"color": Color(color.substr(1, 6)),
					"radius": radius / 100.0
				}
	ResourceSaver.save(db, "res://data/elements_db.tres")
	print("ElementsDB resource generated successfully.")
