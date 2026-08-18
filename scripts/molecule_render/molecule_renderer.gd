@tool
extends Node3D

@export var molecule_data: MoleculeData
@export var meshes: Array[MeshBuilder.MeshType]
@export var resonance_structure: ResonanceStructure
@export var mesh_config: MeshBuilderConfig

@export_tool_button("Reload Molecule")
var reload_molecule_action: Callable = render

func render() -> void:
	var expected_names: Dictionary = {}
	for mesh_type in meshes:
		var node_name = MeshBuilder.MeshType.keys()[mesh_type] + "_Meshes"
		var existing = get_node_or_null(NodePath(node_name))
		if existing:
			remove_child(existing)
			existing.queue_free()

		var container = MeshBuilder.build(mesh_type, molecule_data, resonance_structure, mesh_config)
		if container == null:
			continue

		container.name = node_name
		add_child(container)
		if Engine.is_editor_hint():
			_set_owner_recursive(container, get_tree().edited_scene_root)
		expected_names[node_name] = true

	for child in get_children():
		if child.name.ends_with("_Meshes") and not expected_names.has(child.name):
			remove_child(child)
			child.queue_free()


func _set_owner_recursive(node: Node, scene_owner: Node) -> void:
	if node != scene_owner:
		node.owner = scene_owner
	for child in node.get_children():
		_set_owner_recursive(child, scene_owner)
