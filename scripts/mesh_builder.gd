@tool
class_name MeshBuilder

enum MeshType {
	ATOM, BOND, CHARGE
}

static func build(mesh_type: MeshType, molecule_data: MoleculeData, resonance_structure: ResonanceStructure = null, config: MeshBuilderConfig = null) -> MultiMesh:
	config = config if config else MeshBuilderConfig.new()
	match mesh_type:
		MeshType.ATOM:
			return _build_atom_mesh(molecule_data.atoms)
		MeshType.BOND:
			return _build_bond_mesh(molecule_data, config)
		MeshType.CHARGE:
			if resonance_structure != null:
				return _build_charge_aura_mesh(molecule_data, resonance_structure, config)
			push_warning("Tried to render charges without resonance structure resource")
	return null

static func _make_sphere_mesh(radius: float, height: float, material: Material) -> SphereMesh:
	var sphere := SphereMesh.new()
	sphere.material = material
	sphere.radius = radius
	sphere.height = height
	return sphere

static func _build_atom_mesh(atoms: Array) -> MultiMesh:
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true

	var mm := MultiMesh.new()
	mm.mesh = _make_sphere_mesh(1.0, 2.0, material)
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

static func _build_bond_mesh(molecule_data: MoleculeData, config: MeshBuilderConfig) -> MultiMesh:
	var atoms = molecule_data.atoms
	var bonds = molecule_data.bonds

	var material := StandardMaterial3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.material = material
	cylinder.top_radius = config.bond_radius
	cylinder.bottom_radius = config.bond_radius
	cylinder.height = 1.0

	var mm := MultiMesh.new()
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

static func _build_charge_aura_mesh(molecule: MoleculeData, resonance_structure: ResonanceStructure, config: MeshBuilderConfig) -> MultiMesh:
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true

	var charges = resonance_structure.charges
	var charge_count = charges.reduce(func(count, next): return count + 1 if next != 0 else count, 0)

	var mm := MultiMesh.new()
	mm.mesh = _make_sphere_mesh(1.0, 2.0, material)
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.instance_count = charge_count

	var instance_idx = 0
	for atom_idx in range(molecule.atoms.size()):
		var charge = charges[atom_idx]
		if charge == 0:
			continue

		var pos = molecule.atoms[atom_idx].position
		var base_radius = ElementsDB.get_element(molecule.atoms[atom_idx].symbol)["radius"]
		var aura_radius = base_radius * config.charge_aura_scale

		var transform = Transform3D(Basis().scaled(Vector3(aura_radius, aura_radius, aura_radius)), pos)
		mm.set_instance_transform(instance_idx, transform)

		var color = config.positive_charge_color if charge > 0 else config.negative_charge_color
		mm.set_instance_color(instance_idx, color)

		instance_idx += 1

	return mm
