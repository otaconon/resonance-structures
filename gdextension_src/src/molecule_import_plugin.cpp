#include "molecule_import_plugin.h"

#include "atom_data.h"
#include "load_atom_data.h"

namespace godot {
void MoleculeImportPlugin::_bind_methods() {
  // Empty, but required for GDExtension registration
}

String MoleculeImportPlugin::_get_preset_name(int32_t p_preset) const {
  return "Default";
}
String MoleculeImportPlugin::_get_importer_name() const {
  return "molecule.rdkit.importer";
}

String MoleculeImportPlugin::_get_visible_name() const {
  return "Molecule (RDKit)";
}

PackedStringArray MoleculeImportPlugin::_get_recognized_extensions() const {
  PackedStringArray exts;
  exts.push_back("mol");
  exts.push_back("sdf");
  return exts;
}

String MoleculeImportPlugin::_get_save_extension() const { return "res"; }

String MoleculeImportPlugin::_get_resource_type() const { return "AtomData"; }

int32_t MoleculeImportPlugin::_get_preset_count() const { return 0; }

TypedArray<Dictionary>
MoleculeImportPlugin::_get_import_options(const String &p_path,
                                          int32_t p_preset) const {
  return TypedArray<Dictionary>();
}

bool MoleculeImportPlugin::_get_option_visibility(
    const String &p_path, const StringName &p_option_name,
    const Dictionary &p_options) const {
  return true;
}

Error MoleculeImportPlugin::_import(
    const String &p_source_file, const String &p_save_path,
    const Dictionary &p_options, const TypedArray<String> &p_platform_variants,
    const TypedArray<String> &p_gen_files) const {
  Array atoms;
  try {
    atoms = load_atom_data(p_source_file);
  } catch (const std::exception &e) {
    UtilityFunctions::printerr("Failed to parse '", p_source_file,
                               "': ", e.what());
    return ERR_PARSE_ERROR;
  } catch (...) {
    UtilityFunctions::printerr("Failed to parse '", p_source_file,
                               "': unknown error");
    return ERR_PARSE_ERROR;
  }

  if (atoms.is_empty()) {
    return ERR_FILE_CORRUPT;
  }
  Ref<AtomData> atom_data;
  atom_data.instantiate();
  atom_data->set_atoms(atoms);
  String out_path = vformat("%s.%s", p_save_path, _get_save_extension());
  return ResourceSaver::get_singleton()->save(atom_data, out_path);
}
} // namespace godot
