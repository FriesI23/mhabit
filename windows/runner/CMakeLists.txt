cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# Custom Flavors
set(ORIGINAL_RC "Runner.rc.in")
set(GENERATED_RC "Runner.rc")
file(READ ${ORIGINAL_RC} RC_CONTENT)
if(FLAVOR_NAME)
    string(REPLACE "{PRODUCT_NAME}" "${BINARY_NAME}-${FLAVOR_NAME}" RC_CONTENT "${RC_CONTENT}")
    string(REPLACE "{FILE_DESCRIPTION}" "${BINARY_NAME}-${FLAVOR_NAME}" RC_CONTENT "${RC_CONTENT}")
    string(REPLACE "{INTERNAL_NAME}" "${BINARY_NAME}-${FLAVOR_NAME}" RC_CONTENT "${RC_CONTENT}")
else()
    string(REPLACE "{PRODUCT_NAME}" "${BINARY_NAME}" RC_CONTENT "${RC_CONTENT}")
    string(REPLACE "{FILE_DESCRIPTION}" "${BINARY_NAME}" RC_CONTENT "${RC_CONTENT}")
    string(REPLACE "{INTERNAL_NAME}" "${BINARY_NAME}" RC_CONTENT "${RC_CONTENT}")
endif()
file(WRITE ${GENERATED_RC} "${RC_CONTENT}")

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
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)

if(FLAVOR)
  add_custom_command(TARGET ${BINARY_NAME} POST_BUILD
    # Debug
    COMMAND ${CMAKE_COMMAND} -E rm -rf "${CMAKE_BINARY_DIR}/runner/Debug"
    COMMAND ${CMAKE_COMMAND} -E create_symlink "${CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG}" "${CMAKE_BINARY_DIR}/runner/Debug"
    # Profile
    COMMAND ${CMAKE_COMMAND} -E rm -rf "${CMAKE_BINARY_DIR}/runner/Profile"
    COMMAND ${CMAKE_COMMAND} -E create_symlink "${CMAKE_RUNTIME_OUTPUT_DIRECTORY_PROFILE}" "${CMAKE_BINARY_DIR}/runner/Profile"
    # Release
    COMMAND ${CMAKE_COMMAND} -E rm -rf "${CMAKE_BINARY_DIR}/runner/Release"
    COMMAND ${CMAKE_COMMAND} -E create_symlink "${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE}" "${CMAKE_BINARY_DIR}/runner/Release"
  )
endif()

