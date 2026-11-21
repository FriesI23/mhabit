cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# Flutter publishes FLUTTER_APP_FLAVOR after adding the flutter subdirectory.
set(PRODUCT_NAME "${BINARY_NAME}")
if(FLUTTER_APP_FLAVOR STREQUAL "f_dev")
  set(PRODUCT_NAME "${BINARY_NAME}-dev")
  add_compile_definitions(APP_TITLE_SUFFIX=" - dev")
elseif(FLUTTER_APP_FLAVOR STREQUAL "f_store")
  set(PRODUCT_NAME "${BINARY_NAME}-store")
elseif(FLUTTER_APP_FLAVOR AND NOT FLUTTER_APP_FLAVOR STREQUAL "f_generic")
  message(FATAL_ERROR "Unsupported Windows flavor: ${FLUTTER_APP_FLAVOR}")
endif()

# Keep generated resources inside each flavor's build directory.
set(GENERATED_RC "${CMAKE_CURRENT_BINARY_DIR}/Runner.rc")
configure_file("Runner.rc.in" "${GENERATED_RC}" @ONLY)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "${GENERATED_RC}"
  "runner.exe.manifest"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# Disable Windows macros that collide with C++ standard library functions.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Add dependency libraries and include directories. Add any application-specific
# dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
target_include_directories(${BINARY_NAME} PRIVATE
  "${CMAKE_SOURCE_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}"
)

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)

