#pragma once

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/dictionary.hpp>

// C++ version of the shape classes in scripts/math/shapes/.
// Returns { "vertices": Array, "edges": Array of Vector2i, "faces": Array of index Arrays },
// in exactly the same order as the GDScript classes, so the two can be compared index by index.
class NativeShapes : public godot::RefCounted {
	GDCLASS(NativeShapes, godot::RefCounted)

protected:
	static void _bind_methods();

public:
	// Cube3D, Cube4D (tesseract) or Cube5D (penteract), depending on p_dim.
	godot::Dictionary cube(int p_dim, double p_size) const;

	// Pyramid3D (square base) or Pyramid4D (tetrahedral base, i.e. a 5-cell).
	godot::Dictionary pyramid(int p_dim, double p_size, double p_height_proportion) const;
};
