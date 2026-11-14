#pragma once

#include <godot_cpp/variant/array.hpp>
#include <godot_cpp/variant/variant.hpp>
#include <godot_cpp/variant/vector3.hpp>
#include <godot_cpp/variant/vector4.hpp>

namespace native_math {

// The GDScript side stores a point as a Vector3 (3D), a Vector4 (4D) or a 5-element Array (5D).
// PointN holds any of them as plain doubles so the maths can work on one type.
struct PointN {
	double c[5] = { 0.0, 0.0, 0.0, 0.0, 0.0 };
	int dim = 0;
};

inline bool read_point(const godot::Variant &p_value, PointN &r_point) {
	switch (p_value.get_type()) {
		case godot::Variant::VECTOR3: {
			const godot::Vector3 v = p_value;
			r_point.c[0] = v.x;
			r_point.c[1] = v.y;
			r_point.c[2] = v.z;
			r_point.dim = 3;
			return true;
		}
		case godot::Variant::VECTOR4: {
			const godot::Vector4 v = p_value;
			r_point.c[0] = v.x;
			r_point.c[1] = v.y;
			r_point.c[2] = v.z;
			r_point.c[3] = v.w;
			r_point.dim = 4;
			return true;
		}
		case godot::Variant::ARRAY: {
			const godot::Array a = p_value;
			const int64_t n = a.size();
			if (n < 1 || n > 5) {
				return false;
			}
			for (int64_t k = 0; k < n; k++) {
				r_point.c[k] = double(a[k]);
			}
			r_point.dim = int(n);
			return true;
		}
		default:
			return false;
	}
}

// Writes the point back in the same representation it was read from.
inline godot::Variant write_point(const PointN &p_point) {
	switch (p_point.dim) {
		case 3:
			return godot::Vector3(p_point.c[0], p_point.c[1], p_point.c[2]);
		case 4:
			return godot::Vector4(p_point.c[0], p_point.c[1], p_point.c[2], p_point.c[3]);
		default: {
			godot::Array a;
			for (int k = 0; k < p_point.dim; k++) {
				a.push_back(p_point.c[k]);
			}
			return a;
		}
	}
}

} // namespace native_math
