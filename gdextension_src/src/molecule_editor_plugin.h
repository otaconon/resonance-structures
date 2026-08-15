#pragma once

#include <godot_cpp/classes/editor_plugin.hpp>

#include "molecule_import_plugin.h"

namespace godot {
class MoleculeEditorPlugin : public EditorPlugin {
  GDCLASS(MoleculeEditorPlugin, EditorPlugin)

private:
  Ref<MoleculeImportPlugin> import_plugin;

protected:
  static void _bind_methods() {}

public:
  void _enter_tree() override {
    import_plugin.instantiate();
    add_import_plugin(import_plugin);
  }

  void _exit_tree() override {
    if (import_plugin.is_valid()) {
      remove_import_plugin(import_plugin);
      import_plugin.unref();
    }
  }
};

}
