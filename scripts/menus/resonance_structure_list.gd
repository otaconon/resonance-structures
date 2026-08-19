class_name ResonanceStructureList
extends Control

const CORRECT_COLOR := Color(0.2, 0.8, 0.2, 0.5)

@onready var list = %ItemList
@onready var submit_button = %SubmitButton

## Renderer holding the molecule the player is currently editing; set by the owning scene.
var molecule_renderer: MoleculeRenderer

var resonance_structures: Array:
	get:
		return resonance_structures
	set(value):
		list.clear()
		resonance_structures = value
		for res_struct in resonance_structures:
			var label = res_struct.resource_name if not res_struct.resource_name.is_empty() else res_struct.resource_path.get_file().get_basename()
			var idx = list.add_item(label)
			list.set_item_metadata(idx, res_struct)


func _on_submit_button_pressed() -> void:
	if molecule_renderer == null:
		return
	var user_structure: ResonanceStructure = molecule_renderer.user_resonance_structure
	if user_structure == null:
		return

	for idx in list.item_count:
		var candidate: ResonanceStructure = list.get_item_metadata(idx)
		var is_correct = _structures_match(user_structure, candidate)
		list.set_item_custom_bg_color(idx, CORRECT_COLOR if is_correct else Color.TRANSPARENT)


func _structures_match(a: ResonanceStructure, b: ResonanceStructure) -> bool:
	return a.charges == b.charges and a.bond_types == b.bond_types
