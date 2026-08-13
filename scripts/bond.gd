class_name Bond extends RefCounted

enum BondType {
	SINGLE_BOND, DOUBLE_BOND, TRIPLE_BOND
}

var atom1_idx: int
var atom2_idx: int
var bond_type: BondType

func _init(_atom1_idx, _atom2_idx, _bond_type):
	atom1_idx = _atom1_idx
	atom2_idx = _atom2_idx
	bond_type = _bond_type
