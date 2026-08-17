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
		var mesh_instance = _get_or_create_mesh_instance(mesh_type)
		mesh_instance.multimesh = MeshBuilder.build(mesh_type, molecule_data, resonance_structure, mesh_config)
		expected_names[mesh_instance.name] = true

	for child in get_children():
		if child is MultiMeshInstance3D and not expected_names.has(child.name):
			remove_child(child)
			child.queue_free()


func _get_or_create_mesh_instance(mesh_type: MeshBuilder.MeshType) -> MultiMeshInstance3D:
	var node_name = MeshBuilder.MeshType.keys()[mesh_type] + "_MultiMesh"
	var existing = get_node_or_null(NodePath(node_name))
	if existing is MultiMeshInstance3D:
		return existing

	var mesh_instance = MultiMeshInstance3D.new()
	mesh_instance.name = node_name
	add_child(mesh_instance)
	if Engine.is_editor_hint():
		mesh_instance.owner = get_tree().edited_scene_root
	return mesh_instance
