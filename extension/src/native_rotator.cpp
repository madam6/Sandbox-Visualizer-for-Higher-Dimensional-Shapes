#include "native_rotator.h"

#include "point_utils.h"

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/math.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void NativeRotator::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_rotation_matrix", "dim", "i", "j", "angle_rad"), &NativeRotator::get_rotation_matrix);
	ClassDB::bind_method(D_METHOD("rotate_shape", "shape", "angle_deg", "i", "j"), &NativeRotator::rotate_shape);
}

// Off-diagonal signs, copied from BaseRotator.get_rotation_matrix(): the XZ plane (0, 2)
// uses the opposite sign to every other plane.
static void plane_sines(int p_i, int p_j, double p_sin, double &r_ij, double &r_ji) {
	if (p_i == 0 && p_j == 2) {
		r_ij = p_sin;
		r_ji = -p_sin;
	} else {
		r_ij = -p_sin;
		r_ji = p_sin;
	}
}

Array NativeRotator::get_rotation_matrix(int p_dim, int p_i, int p_j, double p_angle_rad) const {
	Array matrix;
	if (p_dim < 1 || p_i < 0 || p_j < 0 || p_i >= p_dim || p_j >= p_dim) {
		UtilityFunctions::push_error("NativeRotator: plane (", p_i, ", ", p_j, ") is outside a ", p_dim, "D space.");
		return matrix;
	}

	const double c = Math::cos(p_angle_rad);
	double s_ij = 0.0;
	double s_ji = 0.0;
	plane_sines(p_i, p_j, Math::sin(p_angle_rad), s_ij, s_ji);

	for (int row = 0; row < p_dim; row++) {
		Array cells;
		for (int col = 0; col < p_dim; col++) {
			double value = row == col ? 1.0 : 0.0;
			if (row == p_i && col == p_i) {
				value = c;
			} else if (row == p_j && col == p_j) {
				value = c;
			} else if (row == p_i && col == p_j) {
				value = s_ij;
			} else if (row == p_j && col == p_i) {
				value = s_ji;
			}
			cells.push_back(value);
		}
		matrix.push_back(cells);
	}
	return matrix;
}

void NativeRotator::rotate_shape(Array p_shape, double p_angle_deg, int p_i, int p_j) const {
	const double angle = Math::deg_to_rad(p_angle_deg);
	const double c = Math::cos(angle);
	double s_ij = 0.0;
	double s_ji = 0.0;
	plane_sines(p_i, p_j, Math::sin(angle), s_ij, s_ji);

	// The matrix is the identity outside rows/columns i and j, so only those two
	// coordinates change. Multiplying the full matrix would give the same numbers.
	const int64_t count = p_shape.size();
	for (int64_t n = 0; n < count; n++) {
		native_math::PointN p;
		if (!native_math::read_point(p_shape[n], p)) {
			UtilityFunctions::push_error("NativeRotator: point ", n, " is not a Vector3, Vector4 or Array.");
			return;
		}
		if (p_i >= p.dim || p_j >= p.dim) {
			UtilityFunctions::push_error("NativeRotator: plane (", p_i, ", ", p_j, ") is outside a ", p.dim, "D shape.");
			return;
		}
		const double a = p.c[p_i];
		const double b = p.c[p_j];
		if (p_i < p_j) {
			p.c[p_i] = c * a + s_ij * b;
			p.c[p_j] = s_ji * a + c * b;
		} else {
			p.c[p_i] = s_ij * b + c * a;
			p.c[p_j] = c * b + s_ji * a;
		}
		p_shape[n] = native_math::write_point(p);
	}
}
