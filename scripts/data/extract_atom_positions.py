import json
import sys

from rdkit import Chem


def main():
    mol_file_path = sys.argv[1]
    output_file = sys.argv[2]

    mol = Chem.MolFromMolFile(mol_file_path, removeHs=False)
    conf = mol.GetConformer()

    atom: Chem.Atom
    atom_data = []
    for atom in mol.GetAtoms():
        atom_data.append({
            "symbol": atom.GetSymbol(),
            "position": conf.GetAtomPosition(atom.GetIdx())
        })

    with open(output_file, 'w') as f:
        json.dump(atom_data, f)

if __name__ == "__main__":
    main()
