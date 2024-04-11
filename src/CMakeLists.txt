# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(sp_scanner_library VERSION 0.0.1 LANGUAGES C)

add_library(sp_scanner SHARED
  "sp_scanner.c"
)

set_target_properties(sp_scanner PROPERTIES
  PUBLIC_HEADER sp_scanner.h
  OUTPUT_NAME "sp_scanner"
)

target_compile_definitions(sp_scanner PUBLIC DART_SHARED_LIB)
