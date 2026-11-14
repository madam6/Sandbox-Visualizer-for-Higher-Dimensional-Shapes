#pragma once

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/array.hpp>

// C++ version of the classes in scripts/math/projection/.
// Every method takes the shape as the GDScript side stores it and returns an Array of Vector3.
class NativeProjector : public godot::RefCounted {
	GDCLASS(NativeProjector, godot::RefCounted)

protected:
	static void _bind_methods();

public:
	// Dummy3DProjection, Orthographic4DProjection and Orthographic5DProjection: drop every
	// coordinate after z. A 3D shape is returned as-is, like Dummy3DProjection does.
	godot::Array project_orthographic(const godot::Array &p_shape) const;

	// Perspective4DProjection.project()
	godot::Array project_perspective_4d(const godot::Array &p_shape, double p_w_distance, double p_fov_scale) const;

	// Perspective5DProjection.project(): 5D -> 4D through V, then 4D -> 3D through W.
	godot::Array project_perspective_5d(const godot::Array &p_shape, double p_v_distance, double p_w_distance, double p_fov_scale) const;
};
