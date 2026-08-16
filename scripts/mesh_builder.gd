@tool
class_name MeshBuilder

enum MeshType {
	ATOM, BOND, CHARGE
}

static func build(mesh_type: MeshType, molecule_data: MoleculeData) -> MultiMesh:
	match mesh_type:
		MeshType.ATOM:
			return _build_atom_mesh(molecule_data.atoms)
		MeshType.BOND:
			return _build_bond_mesh(molecule_data)
		#MeshType.CHARGE:
		#	return _build_charge_aura_mesh(molecule)
	return null

static func _build_atom_mesh(atoms: Array) -> MultiMesh:
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
	mm.instance_count = atoms.size()

	for i in atoms.size():
		var pos = atoms[i].position
		var element_data = ElementsDB.get_element(atoms[i].symbol)
		var radius = element_data["radius"]
		var color: Color = element_data["color"].srgb_to_linear()

		var transform = Transform3D(Basis().scaled(Vector3(radius, radius, radius)), pos)
		mm.set_instance_transform(i, transform)
		mm.set_instance_color(i, color)

	return mm

static func _build_bond_mesh(molecule_data: MoleculeData) -> MultiMesh:
	var atoms = molecule_data.atoms
	var bonds = molecule_data.bonds

	var material := StandardMaterial3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.material = material
	cylinder.top_radius = 0.2
	cylinder.bottom_radius = 0.2
	cylinder.height = 1.0

	var mm = MultiMesh.new()
	mm.mesh = cylinder
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = bonds.size()

	for i in range(bonds.size()):
		var atom_a = atoms[bonds[i].atom_a_idx]
		var atom_b = atoms[bonds[i].atom_b_idx]

		var offset = atom_b.position - atom_a.position
		var distance = offset.length()
		var direction = offset / distance
		var rotation = Quaternion(Vector3.UP, direction)
		var bond_basis = Basis(rotation).scaled(Vector3(1.0, distance, 1.0))

		var transform = Transform3D(bond_basis, atom_a.position + offset * 0.5)
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
