@tool
class_name MeshBuilder

enum MeshType {
	ATOM, BOND, CHARGE
}

static func build(mesh_type: MeshType, molecule_data: MoleculeData, resonance_structure: ResonanceStructure = null, config: MeshBuilderConfig = null) -> Node3D:
	config = config if config else MeshBuilderConfig.new()
	match mesh_type:
		MeshType.ATOM:
			return _build_atom_meshes(molecule_data.atoms, config)
		MeshType.BOND:
			return _build_bond_meshes(molecule_data, resonance_structure, config)
		MeshType.CHARGE:
			if resonance_structure != null:
				return _build_charge_aura_meshes(molecule_data, resonance_structure, config)
			push_warning("Tried to render charges without resonance structure resource")
	return null

static func _make_sphere_mesh(radius: float, material: Material) -> SphereMesh:
	var sphere := SphereMesh.new()
	sphere.material = material
	sphere.radius = radius
	sphere.height = radius * 2.0
	return sphere

static func _make_pickable_mesh(node_name: String, mesh: Mesh, collision_shape: Shape3D, transform: Transform3D) -> Area3D:
	var area := Area3D.new()
	area.name = node_name
	area.input_ray_pickable = true
	area.transform = transform

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "MeshInstance3D"
	mesh_instance.mesh = mesh
	area.add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	collision.shape = collision_shape
	area.add_child(collision)

	return area

static func _build_atom_meshes(atoms: Array, config: MeshBuilderConfig) -> Node3D:
	var container := Node3D.new()

	for i in atoms.size():
		var atom = atoms[i]
		var element_data = ElementsDB.get_element(atom.symbol)
		var radius: float = element_data["radius"]
		var color: Color = element_data["color"].srgb_to_linear()

		var material := StandardMaterial3D.new()
		material.albedo_color = color

		var shape := SphereShape3D.new()
		shape.radius = radius*config.atom_radius_scale

		var transform := Transform3D(Basis(), atom.position)
		var atom_node := _make_pickable_mesh("Atom_%d" % i, _make_sphere_mesh(radius*config.atom_radius_scale, material), shape, transform)
		atom_node.set_meta("atom_index", i)
		container.add_child(atom_node)

	return container

static func _bond_strand_count(bond_type: Bond.BondType) -> int:
	match bond_type:
		Bond.TRIPLE:
			return 3
		Bond.DOUBLE:
			return 2
		Bond.SINGLE:
			return 1
	return 0

static func _build_bond_meshes(molecule_data: MoleculeData, resonance_structure: ResonanceStructure, config: MeshBuilderConfig) -> Node3D:
	var atoms = molecule_data.atoms
	var bonds = molecule_data.bonds
	var bond_types = resonance_structure.bond_types if resonance_structure != null else []

	var material := StandardMaterial3D.new()
	var container := Node3D.new()

	for i in bonds.size():
		var bond = bonds[i]
		var atom_a = atoms[bond.atom_a_idx]
		var atom_b = atoms[bond.atom_b_idx]

		var offset = atom_b.position - atom_a.position
		var distance = offset.length()
		var direction = offset / distance
		var rotation = Quaternion(Vector3.UP, direction)
		var center = atom_a.position + offset * 0.5

		var reference_axis = Vector3.UP if absf(direction.dot(Vector3.BACK)) > 0.99 else Vector3.BACK
		var side = direction.cross(reference_axis).normalized()

		var bond_type = bond_types[i] if i < bond_types.size() else bond.bond_type
		var strand_count = _bond_strand_count(bond_type)
		var strand_radius = config.bond_radius * config.multi_bond_radius_scale if strand_count > 1 else config.bond_radius

		for strand in strand_count:
			var lateral_offset = (strand - (strand_count - 1) / 2.0) * config.multi_bond_spacing
			var strand_center = center + side * lateral_offset

			var capsule := CapsuleMesh.new()
			capsule.material = material
			capsule.radius = strand_radius
			capsule.height = distance

			var shape := CapsuleShape3D.new()
			shape.radius = strand_radius
			shape.height = distance

			var transform := Transform3D(Basis(rotation), strand_center)
			var node_name = "Bond_%d" % i if strand_count == 1 else "Bond_%d_%d" % [i, strand]
			var bond_node := _make_pickable_mesh(node_name, capsule, shape, transform)
			bond_node.set_meta("bond_index", i)
			container.add_child(bond_node)

	return container

static func _build_charge_aura_meshes(molecule: MoleculeData, resonance_structure: ResonanceStructure, config: MeshBuilderConfig) -> Node3D:
	var container := Node3D.new()
	var charges = resonance_structure.charges

	for atom_idx in range(molecule.atoms.size()):
		var charge = charges[atom_idx]
		if charge == 0:
			continue

		var pos = molecule.atoms[atom_idx].position
		var base_radius = ElementsDB.get_element(molecule.atoms[atom_idx].symbol)["radius"]
		var aura_radius = base_radius * config.charge_aura_scale

		var material := StandardMaterial3D.new()
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = config.positive_charge_color if charge > 0 else config.negative_charge_color

		var mesh_instance := MeshInstance3D.new()
		mesh_instance.name = "Charge_%d" % atom_idx
		mesh_instance.mesh = _make_sphere_mesh(aura_radius, material)
		mesh_instance.transform = Transform3D(Basis(), pos)
		container.add_child(mesh_instance)

	return container
