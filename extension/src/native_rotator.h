#pragma once

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/array.hpp>

// C++ version of scripts/math/rotation/BaseRotator.gd.
// Rotates N-dimensional points (N = 3, 4 or 5) in the plane formed by axes i and j.
class NativeRotator : public godot::RefCounted {
	GDCLASS(NativeRotator, godot::RefCounted)

protected:
	static void _bind_methods();

public:
	// Same matrix as BaseRotator.get_rotation_matrix(), returned as an Array of row Arrays.
	godot::Array get_rotation_matrix(int p_dim, int p_i, int p_j, double p_angle_rad) const;

	// Rotates every point of p_shape in place, like BaseRotator._rotate_shape(). Angle is in degrees.
	void rotate_shape(godot::Array p_shape, double p_angle_deg, int p_i, int p_j) const;
};
