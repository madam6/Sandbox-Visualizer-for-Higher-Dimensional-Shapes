extends Node

class_name VectorHelper

static func magnitude(vector: Array) -> float:
	var sum = 0.0
	
	for coord in vector:
		sum += coord * coord
	
	return sqrt(sum)
	

static func normalize(vector: Array) -> Array:
	var mag = magnitude(vector)
	var result = []
	
	for coord in vector:
		result.append(coord / mag)
		
	return result
	

static func convert_vec4_to_array(vector: Vector4) -> Array:
	return [vector.x, vector.y, vector.z, vector.w]
	
static func convert_array_to_vector4(vector: Array) -> Vector4:
	return Vector4(vector[0], vector[1], vector[2], vector[3])	
	
static func convert_vec3_to_array(vector: Vector3) -> Array:
	return [vector.x, vector.y, vector.z]
	
static func convert_array_to_vector3(vector: Array) -> Vector3:
	return Vector3(vector[0], vector[1], vector[2])

static func convert_vec2_to_array(vector: Vector2) -> Array:
	return [vector.x, vector.y]
	
static func convert_array_to_vector2(vector: Array) -> Vector2:
	return Vector2(vector[0], vector[1])
	
static func print_vector(vector: Array) -> void:
	var result = ""
	result += "["
	for element in vector:
		result += (str(element).pad_decimals(2) + ", ")
	result += "]"
	print(result)
