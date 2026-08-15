#include "atom_data.h"
#include "molecule_editor_plugin.h"
#include "molecule_import_plugin.h"

namespace godot {
void initialize_importer_types(ModuleInitializationLevel p_level) {
  if (p_level == MODULE_INITIALIZATION_LEVEL_SCENE) {
    ClassDB::register_class<AtomData>();
  }

  if (p_level == MODULE_INITIALIZATION_LEVEL_EDITOR) {
    ClassDB::register_class<MoleculeImportPlugin>();
    ClassDB::register_class<MoleculeEditorPlugin>();

    EditorPlugins::add_by_type<MoleculeEditorPlugin>();
  }
}

void uninitialize_importer_types(ModuleInitializationLevel p_level) {
    // Empty, but required by the engine during shutdown
}
} // namespace godot

extern "C" {
    GDExtensionBool GDE_EXPORT initialize_extension_module(
        GDExtensionInterfaceGetProcAddress p_get_proc_address,
        const GDExtensionClassLibraryPtr p_library,
        GDExtensionInitialization *r_initialization) {

        godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

        // Pass the renamed namespace functions here
        init_obj.register_initializer(godot::initialize_importer_types);
        init_obj.register_terminator(godot::uninitialize_importer_types);
        init_obj.set_minimum_library_initialization_level(godot::MODULE_INITIALIZATION_LEVEL_SCENE);

        return init_obj.init();
    }
}
