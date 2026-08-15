#include "atom_data.h"
#include <godot_cpp/core/class_db.hpp>

namespace godot {
    void AtomData::_bind_methods() {
        ClassDB::bind_method(D_METHOD("set_atoms", "atoms"), &AtomData::set_atoms);
        ClassDB::bind_method(D_METHOD("get_atoms"), &AtomData::get_atoms);

        ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "atoms"), "set_atoms", "get_atoms");
    }

    void AtomData::set_atoms(const Array& p_atoms) {
        atoms = p_atoms;
    }

    Array AtomData::get_atoms() const {
        return atoms;
    }
}
