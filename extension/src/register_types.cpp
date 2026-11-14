#include "register_types.h"

#include "native_projector.h"
#include "native_rotator.h"
#include "native_shapes.h"

#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

using namespace godot;

void initialize_native_math(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}
	GDREGISTER_CLASS(NativeRotator);
	GDREGISTER_CLASS(NativeProjector);
	GDREGISTER_CLASS(NativeShapes);
}

void uninitialize_native_math(ModuleInitializationLevel p_level) {
}

extern "C" {
// Entry point named in bin/native_math.gdextension.
GDExtensionBool GDE_EXPORT native_math_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization) {
	GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);
	init_obj.register_initializer(initialize_native_math);
	init_obj.register_terminator(uninitialize_native_math);
	init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);
	return init_obj.init();
}
}
