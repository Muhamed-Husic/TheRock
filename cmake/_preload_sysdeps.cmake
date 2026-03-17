# Prefer *Config* packages (i.e. <pkg>-config.cmake) over Find*.cmake
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG ON)

# Compute superbuild root from child CMAKE_BINARY_DIR (three levels up)
set(_therock_super "${CMAKE_BINARY_DIR}")
foreach(_i RANGE 1 3)
  cmake_path(GET _therock_super PARENT_PATH _therock_super)
endforeach()

# TheRock yaml-cpp CMake roots
set(_yaml_cmake_roots
  "${_therock_super}/third-party/yaml-cpp/stage/lib/cmake"
  "${_therock_super}/third-party/yaml-cpp/dist/lib/cmake"
)

# Prepend TheRock roots to CMAKE_PREFIX_PATH (and remove duplicates)
list(PREPEND CMAKE_PREFIX_PATH ${_yaml_cmake_roots})
list(REMOVE_DUPLICATES CMAKE_PREFIX_PATH)

# Check whether TheRock actually has the yaml-cpp package (Config file)
set(_yaml_cfgs
  "${_therock_super}/third-party/yaml-cpp/stage/lib/cmake/yaml-cpp/yaml-cpp-config.cmake"
  "${_therock_super}/third-party/yaml-cpp/dist/lib/cmake/yaml-cpp/yaml-cpp-config.cmake"
)
set(_therock_has_yaml FALSE)
foreach(_p IN LISTS _yaml_cfgs)
  if(EXISTS "${_p}")
    set(_therock_has_yaml TRUE)
    break()
  endif()
endforeach()

# Disable vendoring in timemory repo-wide ONLY if TheRock provides yaml-cpp
# no FORCE => CLI or child CMakeLists can override
if(_therock_has_yaml)
  option(TIMEMORY_BUILD_YAML "Enable building yaml-cpp from timemory submodule" OFF)
endif()

# Expose yaml-cpp target early if available
# So to not fail the build if it's missing; provider/search will handle it later.
find_package(yaml-cpp QUIET CONFIG)