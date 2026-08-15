#include <GraphMol/GraphMol.h>
#include <GraphMol/FileParsers/FileParsers.h>
#include <Geometry/point.h>

#include <godot_cpp/variant/variant.hpp>
#include <godot_cpp/classes/resource_saver.hpp>
#include <godot_cpp/classes/project_settings.hpp>

#include <string>

using namespace godot;

static Array load_atom_data(const String& file_path) {
    Array atom_data_array;

    String real_path = ProjectSettings::get_singleton()->globalize_path(file_path);
    std::string path_str = real_path.utf8().get_data();

    std::unique_ptr<RDKit::ROMol> mol(RDKit::MolFileToMol(path_str));

    if (!mol || mol->getNumConformers() == 0) {
        return atom_data_array;
    }

    const RDKit::Conformer& conf = mol->getConformer();

    for (const auto atom : mol->atoms()) {
        Dictionary atom_dict;

        String symbol(atom->getSymbol().c_str());
        atom_dict[String("symbol")] = symbol;

        RDGeom::Point3D pos = conf.getAtomPos(atom->getIdx());

        atom_dict[String("position")] = Vector3(pos.x, pos.y, pos.z);

        atom_data_array.push_back(atom_dict);
    }

    return atom_data_array;
}
