cmake_minimum_required(VERSION 3.13)
project(mhabit_desktop_window_chrome LANGUAGES CXX)
set(PLUGIN_NAME "mhabit_desktop_window_chrome_plugin")
add_library(${PLUGIN_NAME} SHARED
  desktop_window_chrome_plugin.cc desktop_title_bar.g.cc native_title_bar.cc
  native_window_persistence.cc window_persistence.g.cc)
apply_standard_settings(${PLUGIN_NAME})
target_compile_features(${PLUGIN_NAME} PRIVATE cxx_std_17)
set_target_properties(${PLUGIN_NAME} PROPERTIES CXX_VISIBILITY_PRESET hidden)
target_include_directories(${PLUGIN_NAME} INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter PkgConfig::GTK)
set(mhabit_desktop_window_chrome_bundled_libraries "" PARENT_SCOPE)
