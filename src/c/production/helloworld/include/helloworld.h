#pragma once

#include <stdint.h>

#if defined(WIN32) || defined(_WIN32) || defined(__WIN32__) || defined(__NT__)
    #define FFI_LIBRARY_API_DECL __declspec(dllexport)
#else
    #define FFI_LIBRARY_API_DECL extern
#endif

FFI_LIBRARY_API_DECL void hw_hello_world();
FFI_LIBRARY_API_DECL void hw_print_string(const char* s);