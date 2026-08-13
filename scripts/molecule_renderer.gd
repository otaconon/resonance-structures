@tool
extends Node3D

@export_global_file("*.sdf") var molecule_data_path: String

@export var meshes: Array[MeshBuilder.MeshType]

@export var reload_molecule: bool = false:
	set(value):
		if value == true:
			load_and_render()
		reload_molecule = false

func load_and_render():
	for child in get_children():
		remove_child(child)
		child.queue_free()

	print("Rendering")
	var molecule = SDFParser.load_sdf(molecule_data_path)
	render_molecule(molecule)

func render_molecule(molecule: MoleculeData) -> void:
	for mesh_type in meshes:
		var mesh = MeshBuilder.build(mesh_type, molecule)
		var mesh_instance = MultiMeshInstance3D.new()
		mesh_instance.multimesh = mesh
		mesh_instance.name = MeshBuilder.MeshType.keys()[mesh_type] + "_MultiMesh"
		add_child(mesh_instance)
		if Engine.is_editor_hint():
			mesh_instance.owner = get_tree().edited_scene_root
