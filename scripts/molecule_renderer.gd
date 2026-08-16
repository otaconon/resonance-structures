@tool
extends Node3D

@export var atom_data: AtomData
@export var meshes: Array[MeshBuilder.MeshType]
@export var reload_molecule: bool = false:
	set(value):
		if value != true:
			return

		for child in get_children():
			remove_child(child)
			child.queue_free()
		render()
		reload_molecule = false


func render() -> void:
	print("Rendering molecule with atom data: ", atom_data)
	for mesh_type in meshes:
		var mesh = MeshBuilder.build(mesh_type, atom_data)
		var mesh_instance = MultiMeshInstance3D.new()
		mesh_instance.multimesh = mesh
		mesh_instance.name = MeshBuilder.MeshType.keys()[mesh_type] + "_MultiMesh"
		add_child(mesh_instance)
		if Engine.is_editor_hint():
			mesh_instance.owner = get_tree().edited_scene_root
