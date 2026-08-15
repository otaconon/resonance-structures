@tool
class_name SDFParser extends RefCounted

static func load_sdf(file_path: String) -> MoleculeData:
	if not FileAccess.file_exists(file_path):
		push_error("File not found: " + file_path)
		return null

	var file = FileAccess.open(file_path, FileAccess.READ)
	var lines = file.get_as_text().split("\n")

	if lines.size() < 4:
		push_error("Invalid SDF file format: " + file_path)
		return null

	var counts_line = lines[3]
	if counts_line.contains("V2000"):
		return parse_V2000(counts_line, lines)
	else:
		push_error("Unknown SDF file format: " + file_path)
	return null

static func parse_V2000(counts_line: String, lines) -> MoleculeData:
	var atom_count = counts_line.substr(0, 3).to_int()
	var bond_count = counts_line.substr(3, 3).to_int()

	var molecule_data = MoleculeData.new()

	var current_line_idx = 4
	for atom_idx in range(atom_count):
		var line = lines[current_line_idx]

		var x = line.substr(0, 10).to_float()
		var y = line.substr(10, 10).to_float()
		var z = line.substr(20, 10).to_float()

		var element = line.substr(31, 3).strip_edges()
		molecule_data.atom_positions.append(Vector3(x, y, z))
		molecule_data.atom_elements.append(element)

		current_line_idx += 1

	for bond_idx in range(bond_count):
		var line = lines[current_line_idx]

		var atom1_idx = line.substr(0, 3).to_int() - 1
		var atom2_idx = line.substr(3, 3).to_int() - 1
		var bond_type = line.substr(6, 3).to_int()

		molecule_data.bond_atom1_indices.append(atom1_idx)
		molecule_data.bond_atom2_indices.append(atom2_idx)
		molecule_data.bond_types.append(bond_type)

		current_line_idx += 1

	print("Loaded molecule data")
	return molecule_data
