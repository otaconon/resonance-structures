#pragma once

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/variant/array.hpp>

namespace godot {
    class AtomData : public Resource {
        GDCLASS(AtomData, Resource)

    private:
        Array atoms;

    protected:
        static void _bind_methods();

    public:
        AtomData() = default;
        ~AtomData() = default;

        void set_atoms(const Array& p_atoms);
        Array get_atoms() const;
    };
}
