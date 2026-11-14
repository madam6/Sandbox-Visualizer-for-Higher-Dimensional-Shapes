#include "native_projector.h"

#include "point_utils.h"

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

// Same guard as the GDScript projections: a point at (or past) the projection camera
// would divide by zero, so the divisor never goes below this.
static constexpr double MIN_DIVISOR = 0.001;

static double clamp_divisor(double p_div) {
	return p_div <= MIN_DIVISOR ? MIN_DIVISOR : p_div;
}

void NativeProjector::_bind_methods() {
	ClassDB::bind_method(D_METHOD("project_orthographic", "shape"), &NativeProjector::project_orthographic);
	ClassDB::bind_method(D_METHOD("project_perspective_4d", "shape", "w_distance", "fov_scale"), &NativeProjector::project_perspective_4d);
	ClassDB::bind_method(D_METHOD("project_perspective_5d", "shape", "v_distance", "w_distance", "fov_scale"), &NativeProjector::project_perspective_5d);
}

Array NativeProjector::project_orthographic(const Array &p_shape) const {
	if (p_shape.is_empty() || p_shape[0].get_type() == Variant::VECTOR3) {
		return p_shape;
	}

	Array projected;
	projected.resize(p_shape.size());
	for (int64_t n = 0; n < p_shape.size(); n++) {
		native_math::PointN p;
		if (!native_math::read_point(p_shape[n], p) || p.dim < 3) {
			UtilityFunctions::push_error("NativeProjector: point ", n, " can't be projected orthographically.");
			return Array();
		}
		projected[n] = Vector3(p.c[0], p.c[1], p.c[2]);
	}
	return projected;
}

Array NativeProjector::project_perspective_4d(const Array &p_shape, double p_w_distance, double p_fov_scale) const {
	Array projected;
	projected.resize(p_shape.size());
	for (int64_t n = 0; n < p_shape.size(); n++) {
		if (p_shape[n].get_type() != Variant::VECTOR4) {
			UtilityFunctions::push_error("NativeProjector: 4D perspective expects Vector4 points.");
			return Array();
		}
		const Vector4 point = p_shape[n];
		const double w_factor = p_fov_scale / clamp_divisor(p_w_distance - point.w);
		projected[n] = Vector3(point.x * w_factor, point.y * w_factor, point.z * w_factor);
	}
	return projected;
}

Array NativeProjector::project_perspective_5d(const Array &p_shape, double p_v_distance, double p_w_distance, double p_fov_scale) const {
	Array projected;
	projected.resize(p_shape.size());
	for (int64_t n = 0; n < p_shape.size(); n++) {
		native_math::PointN p;
		if (!native_math::read_point(p_shape[n], p) || p.dim != 5) {
			UtilityFunctions::push_error("NativeProjector: 5D perspective expects 5-element Array points.");
			return Array();
		}

		// The GDScript version keeps the intermediate 4D point in a Vector4,
		// so this does too. That way both versions round the same way.
		const double v_factor = 1.0 / clamp_divisor(p_v_distance - p.c[4]);
		const Vector4 point_4d(p.c[0] * v_factor, p.c[1] * v_factor, p.c[2] * v_factor, p.c[3] * v_factor);

		const double w_factor = p_fov_scale / clamp_divisor(p_w_distance - point_4d.w);
		projected[n] = Vector3(point_4d.x * w_factor, point_4d.y * w_factor, point_4d.z * w_factor);
	}
	return projected;
}
