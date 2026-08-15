import json
import sys

from rdkit import Chem
from rdkit.Chem import rdPartialCharges
from rdkit.Chem.rdchem import ResonanceFlags


def calculate_heuristic_penalty(res_mol):
    penalty = 0
    atom: Chem.Atom
    for atom in res_mol.GetAtoms():
        fc = atom.GetFormalCharge()
        symbol = atom.GetSymbol()
        bonds = atom.GetTotalDegree()

        if fc != 0:
            penalty += abs(fc) * 10

            # Penalize negative charges on electropositive/less electronegative atoms
            if fc < 0:
                if symbol == 'C':
                    penalty += 50
                elif symbol == 'N':
                    penalty += 20
                # O and halogens receive no additional penalty for negative charges

            # Penalize positive charges based on octet and electronegativity
            elif fc > 0:
                if symbol == 'C':
                    if bonds < 4:
                        penalty += 100 # Incomplete octet (carbocation)
                elif symbol in ['O', 'N', 'F', 'Cl']:
                    # Positive highly electronegative atoms are acceptable ONLY IF they have a full octet
                    # e.g., O with 3 bonds and +1 charge has a full octet. O with 1 bond and +1 charge does not.
                    expected_bonds_for_octet = 3 if symbol == 'O' else (4 if symbol == 'N' else 2)
                    if bonds < expected_bonds_for_octet:
                        penalty += 200 # Severe violation
                    else:
                        penalty += 30

    return penalty

def main():
    molecule_sdf_path = sys.argv[1]
    output_json_path = sys.argv[2]

    mol = Chem.MolFromMolFile(molecule_sdf_path, removeHs=False)

    flags: ResonanceFlags = Chem.rdchem.ResonanceFlags.ALLOW_CHARGE_SEPARATION
    supplier = Chem.ResonanceMolSupplier(mol, flags)

    all_structures = []

    for idx, res_mol in enumerate(supplier):
        rdPartialCharges.ComputeGasteigerCharges(res_mol)

        atoms = []
        atom: Chem.Atom
        for atom in res_mol.GetAtoms():
            atoms.append({
                "formal_charge": atom.GetFormalCharge(),
                "partial_charge": float(atom.GetProp('_GasteigerCharge'))
            })

        bonds = []
        for bond in res_mol.GetBonds():
            bonds.append({
                "idx_a": bond.GetBeginAtomIdx(),
                "idx_b": bond.GetEndAtomIdx(),
                "order": bond.GetBondTypeAsDouble()
            })

        all_structures.append({
            "structure_id": idx,
            "atoms": atoms,
            "bonds": bonds
        })

    with open(output_json_path, "w") as f:
        json.dump(all_structures, f, indent=4)

if __name__ == "__main__":
    main()
