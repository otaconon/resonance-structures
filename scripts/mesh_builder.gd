@tool
class_name MeshBuilder

enum MeshType {
	ATOM, BOND, CHARGE
}

static func build(mesh_type: MeshType, molecule: MoleculeData):
	match mesh_type:
		MeshType.ATOM:
			return _build_atom_mesh(molecule)
		MeshType.BOND:
			return _build_bond_mesh(molecule)
		MeshType.CHARGE:
			return _build_charge_aura_mesh(molecule)

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

static func _build_bond_mesh(molecule: MoleculeData):
	var bond_count = molecule.get_bond_count()
	var material := StandardMaterial3D.new()

	var cylinder := CylinderMesh.new()
	cylinder.material = material
	cylinder.top_radius = 0.2
	cylinder.bottom_radius = 0.2
	cylinder.height = 1.0

	var mm = MultiMesh.new()
	mm.mesh = cylinder
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = bond_count

	for i in range(bond_count):
		var atom_a_idx = molecule.bond_atom1_indices[i]
		var atom_b_idx = molecule.bond_atom2_indices[i]

		var pos_a = molecule.atom_positions[atom_a_idx]
		var pos_b = molecule.atom_positions[atom_b_idx]

		var offset = pos_b - pos_a
		var distance = offset.length()
		var direction = offset.normalized()
		var midpoint = pos_a + (offset / 2.0)

		var rotation = Quaternion(Vector3.UP, direction)
		var scale = Vector3(1.0, distance, 1.0)

		var transform = Transform3D(Basis(rotation).scaled(scale), midpoint)
		mm.set_instance_transform(i, transform)

	return mm

static func _build_charge_aura_mesh(molecule: MoleculeData) -> MultiMesh:
	var charged_indices = []
	for i in range(molecule.get_atom_count()):
		charged_indices.append(i)

	if charged_indices.is_empty():
		return null

	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true

	var sphere := SphereMesh.new()
	sphere.material = material
	sphere.radius = 1.0
	sphere.height = 2.0

	var mm = MultiMesh.new()
	mm.mesh = sphere
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.instance_count = charged_indices.size()

	for i in range(charged_indices.size()):
		var atom_idx = charged_indices[i]
		#var charge = molecule.atom_charges[atom_idx]
		var charge = 1
		var pos = molecule.atom_positions[atom_idx]

		var base_radius = ElementsDB.get_element(molecule.atom_elements[atom_idx])["radius"]
		var aura_radius = base_radius * 1.3 # Scale up to envelope the atom

		var transform = Transform3D(Basis().scaled(Vector3(aura_radius, aura_radius, aura_radius)), pos)
		mm.set_instance_transform(i, transform)

		var color = Color(0, 0, 1, 0.4) if charge > 0 else Color(1, 0, 0, 0.4)
		mm.set_instance_color(i, color)

	return mm
