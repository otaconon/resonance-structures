@tool
class_name MoleculeData extends Resource

@export var atom_positions := PackedVector3Array()
@export var atom_elements := PackedStringArray()
@export var bond_atom1_indices := PackedInt64Array()
@export var bond_atom2_indices := PackedInt64Array()
@export var bond_types := PackedInt64Array()

func get_atom_count() -> int:
	return atom_positions.size()

func get_bond_count() -> int:
	return bond_types.size()

func get_bond(bond_idx: int) -> Bond:
	return Bond.new(
		bond_atom1_indices[bond_idx],
		bond_atom2_indices[bond_idx],
		bond_types[bond_idx]
	)
