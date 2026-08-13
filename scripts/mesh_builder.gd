@tool
class_name MeshBuilder

enum MeshType {
	ATOM
}

static func build(mesh_type: MeshType, molecule: MoleculeData):
	match mesh_type:
		MeshType.ATOM:
			return _build_atom_mesh(molecule)

static func _build_atom_mesh(molecule: MoleculeData):
	var atom_count = molecule.get_atom_count()

	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true

	var sphere := SphereMesh.new()
	sphere.material = material
	sphere.radius = 1
	sphere.height = 2

	var mm = MultiMesh.new()
	mm.mesh = sphere
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.instance_count = atom_count

	for i in range(atom_count):
		var pos = molecule.atom_positions[i]
		var element_data = ElementsDB.get_element(molecule.atom_elements[i])
		var radius = element_data["radius"]
		var color: Color = element_data["color"].srgb_to_linear()

		var transform = Transform3D(Basis().scaled(Vector3(radius, radius, radius)), pos)
		mm.set_instance_transform(i, transform)
		mm.set_instance_color(i, color)

	return mm
