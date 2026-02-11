extends RefCounted

class_name BasisAxes

static func create(dimension : int, size : float) -> ShapeData:
    var data = ShapeData.new()

    var append_basis := func(coord: int):
        var basis := []
        basis.resize(dimension)
        basis.fill(0)
        basis[coord - 1] = size
        data.vertices.append(basis)

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