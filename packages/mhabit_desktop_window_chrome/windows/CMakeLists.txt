cmake_minimum_required(VERSION 3.14)
project(mhabit_desktop_window_chrome LANGUAGES CXX)

set(PLUGIN_NAME "mhabit_desktop_window_chrome_plugin")
add_library(${PLUGIN_NAME} SHARED
  "desktop_window_chrome_plugin.cpp"
  "desktop_title_bar.g.cpp"
  "native_title_bar.cpp"
)
apply_standard_settings(${PLUGIN_NAME})
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL NOMINMAX)
target_include_directories(${PLUGIN_NAME} INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin dwmapi)
set(mhabit_desktop_window_chrome_bundled_libraries "" PARENT_SCOPE)
