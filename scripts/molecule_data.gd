@tool
class_name MoleculeData
extends RefCounted

var atom_positions := PackedVector3Array()
var atom_elements := PackedStringArray()
var bond_atom1_indices := PackedInt64Array()
var bond_atom2_indices := PackedInt64Array()
var bond_types := PackedInt64Array()
