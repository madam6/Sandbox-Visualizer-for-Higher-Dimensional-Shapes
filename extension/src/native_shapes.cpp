#include "native_shapes.h"

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/array.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/variant/vector2i.hpp>
#include <godot_cpp/variant/vector3.hpp>
#include <godot_cpp/variant/vector4.hpp>

#include <initializer_list>

using namespace godot;

void NativeShapes::_bind_methods() {
	ClassDB::bind_method(D_METHOD("cube", "dim", "size"), &NativeShapes::cube);
	ClassDB::bind_method(D_METHOD("pyramid", "dim", "size", "height_proportion"), &NativeShapes::pyramid);
}

namespace {

Array index_array(std::initializer_list<int> p_indices, int p_offset = 0) {
	Array a;
	for (int idx : p_indices) {
		a.push_back(idx + p_offset);
	}
	return a;
}

Dictionary make_shape(const Array &p_vertices, const Array &p_edges, const Array &p_faces) {
	Dictionary shape;
	shape["vertices"] = p_vertices;
	shape["edges"] = p_edges;
	shape["faces"] = p_faces;
	return shape;
}

// The 8 corners of a cube in the order Cube3D.gd lists them.
const int CORNERS[8][3] = {
	{ -1, -1, -1 }, { 1, -1, -1 }, { 1, 1, -1 }, { -1, 1, -1 },
	{ -1, -1, 1 }, { 1, -1, 1 }, { 1, 1, 1 }, { -1, 1, 1 },
};
const int CUBE_EDGES[12][2] = {
	{ 0, 1 }, { 1, 2 }, { 2, 3 }, { 3, 0 },
	{ 4, 5 }, { 5, 6 }, { 6, 7 }, { 7, 4 },
	{ 0, 4 }, { 1, 5 }, { 2, 6 }, { 3, 7 },
};
const int CUBE_FACES[6][4] = {
	{ 0, 3, 2, 1 }, { 4, 5, 6, 7 }, // back, front
	{ 0, 4, 7, 3 }, { 1, 2, 6, 5 }, // left, right
	{ 3, 7, 6, 2 }, { 0, 1, 5, 4 }, // top, bottom
};

void add_cube_edges(Array &r_edges, int p_offset) {
	for (const auto &e : CUBE_EDGES) {
		r_edges.push_back(Vector2i(e[0] + p_offset, e[1] + p_offset));
	}
}

void add_cube_faces(Array &r_faces, int p_offset) {
	for (const auto &f : CUBE_FACES) {
		r_faces.push_back(index_array({ f[0], f[1], f[2], f[3] }, p_offset));
	}
}

Dictionary cube_3d(double s) {
	Array vertices;
	for (const auto &c : CORNERS) {
		vertices.push_back(Vector3(c[0] * s, c[1] * s, c[2] * s));
	}
	Array edges;
	add_cube_edges(edges, 0);
	Array faces;
	add_cube_faces(faces, 0);
	return make_shape(vertices, edges, faces);
}

// Cube4D.gd: an inner cube at w = -size and an outer cube at w = +size, joined corner to corner.
Dictionary cube_4d(double s) {
	Array vertices;
	for (double w : { -s, s }) {
		for (const auto &c : CORNERS) {
			vertices.push_back(Vector4(c[0] * s, c[1] * s, c[2] * s, w));
		}
	}

	Array edges;
	add_cube_edges(edges, 0);
	add_cube_edges(edges, 8);
	for (int i = 0; i < 8; i++) {
		edges.push_back(Vector2i(i, i + 8));
	}

	Array faces;
	add_cube_faces(faces, 0);
	add_cube_faces(faces, 8);
	const int connectors[12][4] = {
		{ 0, 1, 9, 8 }, { 1, 2, 10, 9 }, { 2, 3, 11, 10 }, { 3, 0, 8, 11 },
		{ 4, 5, 13, 12 }, { 5, 6, 14, 13 }, { 6, 7, 15, 14 }, { 7, 4, 12, 15 },
		{ 0, 4, 12, 8 }, { 1, 5, 13, 9 }, { 2, 6, 14, 10 }, { 3, 7, 15, 11 },
	};
	for (const auto &f : connectors) {
		faces.push_back(index_array({ f[0], f[1], f[2], f[3] }));
	}
	return make_shape(vertices, edges, faces);
}

// Cube5D.gd builds its 32 vertices with five nested loops over {-size, +size}, first coordinate
// outermost. So vertex index = sum of bit(d) << (4 - d), where bit(d) is 1 when coordinate d is +size.
int penteract_index(const int p_bits[5]) {
	int index = 0;
	for (int d = 0; d < 5; d++) {
		index |= p_bits[d] << (4 - d);
	}
	return index;
}

Dictionary cube_5d(double s) {
	Array vertices;
	for (int index = 0; index < 32; index++) {
		Array point;
		for (int d = 0; d < 5; d++) {
			point.push_back((index >> (4 - d)) & 1 ? s : -s);
		}
		vertices.push_back(point);
	}

	// Two vertices share an edge when they differ in exactly one coordinate,
	// which for these indices means i XOR j has a single bit set.
	Array edges;
	for (int i = 0; i < 32; i++) {
		for (int j = i + 1; j < 32; j++) {
			const int diff = i ^ j;
			if ((diff & (diff - 1)) == 0) {
				edges.push_back(Vector2i(i, j));
			}
		}
	}

	// One square face for every pair of axes (a, b) and every combination of the other three
	// coordinates, wound in the same order as Cube5D.gd: (-,-), (+,-), (+,+), (-,+).
	Array faces;
	for (int a = 0; a < 5; a++) {
		for (int b = a + 1; b < 5; b++) {
			int other[3];
			int count = 0;
			for (int d = 0; d < 5; d++) {
				if (d != a && d != b) {
					other[count++] = d;
				}
			}
			for (int mask = 0; mask < 8; mask++) {
				int bits[5] = { 0, 0, 0, 0, 0 };
				for (int k = 0; k < 3; k++) {
					bits[other[k]] = (mask >> k) & 1;
				}
				int corner[4];
				int n = 0;
				for (int sa = 0; sa < 2; sa++) {
					for (int sb = 0; sb < 2; sb++) {
						bits[a] = sa;
						bits[b] = sb;
						corner[n++] = penteract_index(bits);
					}
				}
				faces.push_back(index_array({ corner[0], corner[2], corner[3], corner[1] }));
			}
		}
	}
	return make_shape(vertices, edges, faces);
}

// Pyramid3D.gd: square base at y = -size, apex above it.
Dictionary pyramid_3d(double s, double p_height_proportion) {
	const double apex_y = -s + s * p_height_proportion;
	Array vertices;
	vertices.push_back(Vector3(0, apex_y, 0));
	vertices.push_back(Vector3(-s, -s, -s));
	vertices.push_back(Vector3(s, -s, -s));
	vertices.push_back(Vector3(s, -s, s));
	vertices.push_back(Vector3(-s, -s, s));

	Array edges;
	const int pyramid_edges[8][2] = {
		{ 1, 2 }, { 2, 3 }, { 3, 4 }, { 4, 1 },
		{ 0, 1 }, { 0, 2 }, { 0, 3 }, { 0, 4 },
	};
	for (const auto &e : pyramid_edges) {
		edges.push_back(Vector2i(e[0], e[1]));
	}

	Array faces;
	faces.push_back(index_array({ 1, 4, 3, 2 })); // base
	faces.push_back(index_array({ 0, 1, 2 }));
	faces.push_back(index_array({ 0, 2, 3 }));
	faces.push_back(index_array({ 0, 3, 4 }));
	faces.push_back(index_array({ 0, 4, 1 }));
	return make_shape(vertices, edges, faces);
}

// Pyramid4D.gd: a tetrahedron at w = -size (alternate corners of a cube) with the apex along W.
// Every pair of vertices is an edge and every triple is a face.
Dictionary pyramid_4d(double s, double p_height_proportion) {
	const double apex_w = -s + s * p_height_proportion;
	Array vertices;
	vertices.push_back(Vector4(0, 0, 0, apex_w));
	vertices.push_back(Vector4(s, s, s, -s));
	vertices.push_back(Vector4(s, -s, -s, -s));
	vertices.push_back(Vector4(-s, s, -s, -s));
	vertices.push_back(Vector4(-s, -s, s, -s));

	Array edges;
	Array faces;
	for (int i = 0; i < 5; i++) {
		for (int j = i + 1; j < 5; j++) {
			edges.push_back(Vector2i(i, j));
		}
	}
	for (int i = 0; i < 5; i++) {
		for (int j = i + 1; j < 5; j++) {
			for (int k = j + 1; k < 5; k++) {
				faces.push_back(index_array({ i, j, k }));
			}
		}
	}
	return make_shape(vertices, edges, faces);
}

} // namespace

Dictionary NativeShapes::cube(int p_dim, double p_size) const {
	switch (p_dim) {
		case 3:
			return cube_3d(p_size);
		case 4:
			return cube_4d(p_size);
		case 5:
			return cube_5d(p_size);
		default:
			UtilityFunctions::push_error("NativeShapes: no ", p_dim, "D cube.");
			return Dictionary();
	}
}

Dictionary NativeShapes::pyramid(int p_dim, double p_size, double p_height_proportion) const {
	switch (p_dim) {
		case 3:
			return pyramid_3d(p_size, p_height_proportion);
		case 4:
			return pyramid_4d(p_size, p_height_proportion);
		default:
			UtilityFunctions::push_error("NativeShapes: no ", p_dim, "D pyramid.");
			return Dictionary();
	}
}
