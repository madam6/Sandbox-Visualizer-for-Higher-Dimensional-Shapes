extends RefCounted

class_name BasisAxes

# Procedurally generates the coordinate axes for the active dimension.
# Returns a ShapeData object where the first vertex is always the Origin (0,0,0...),
# and subsequent vertices are unit vectors projected along each spatial dimension.

static func create(dimension : int, size : float) -> ShapeData:
    var data = ShapeData.new()

    # Creates an empty array of N dimensions, filling the target coordinate with the size
    var append_basis := func(coord: int):
        var basis := []
        basis.resize(dimension)
        basis.fill(0)
        basis[coord - 1] = size
        data.vertices.append(basis)

    # Always anchor the first vertex at mathematical zero
    var origin := []
    origin.resize(dimension)
    origin.fill(0)
    data.vertices.append(origin)

    for i in dimension:
        append_basis.call(i + 1)

    if dimension == 3:
        data.vertices = data.vertices.map(VectorHelper.convert_array_to_vector3)
    elif dimension == 4:
        data.vertices = data.vertices.map(VectorHelper.convert_array_to_vector4)

    return data