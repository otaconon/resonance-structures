class_name MoleculePicker
extends Control

@onready var molecule_list = $MoleculeList

signal molecule_selected(molecule)

var molecules: Array[MoleculeData]:
    get:
        return molecules
    set(value):
        molecule_list.clear()
        molecules = value
        for mol in molecules:
            var label = mol.resource_name if not mol.resource_name.is_empty() else mol.resource_path.get_file().get_basename()
            var idx = molecule_list.add_item(label)
            molecule_list.set_item_metadata(idx, mol)


func _on_molecule_list_item_selected(index: int) -> void:
    molecule_selected.emit(molecule_list.get_item_metadata(index))
