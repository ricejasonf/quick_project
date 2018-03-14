cmake_minimum_required(VERSION 3.9)

if (${QUICK_PROJECT_USE_CATCH})
  add_definitions(-DQUICK_PROJECT_USE_CATCH)
endif (${QUICK_PROJECT_USE_CATCH})

function(quick_project_add_check_target)
  add_custom_target(check
    COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure --exclude-regex ".*individual\..*"
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Running high level tests."
  )
endfunction()

function(quick_project_add_test name_)
  string(REPLACE "/" "." name ${name_})
  add_executable("${name}" EXCLUDE_FROM_ALL ${ARGN})
  add_dependencies(check "${name}")
  add_test(
    NAME ${name}
    COMMAND ${QUICK_PROJECT_TEST_COMMAND} ./${name}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  )
  add_custom_target(run.${name}
    COMMAND ${QUICK_PROJECT_TEST_COMMAND} ./${name}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Build and run test: ${name}"
  )
  add_dependencies(run.${name} ${name})
endfunction()

function(quick_project_catch_test_suite out suite_name)
  set(_catch_main ${quick_project_project_SOURCE_DIR}/test/catch_main.cpp)
  foreach(_source IN ITEMS ${ARGN})
    string(REPLACE ".cpp" "" __name ${_source})
    string(REPLACE "/" "." _name ${__name})
    list(APPEND _build_targets "individual.${suite_name}.${_name}")
    quick_project_add_test("individual.${suite_name}.${_name}" ${_catch_main} ${_source})
  endforeach()
  quick_project_add_test(${suite_name} ${_catch_main} ${ARGN})
  list(APPEND _build_targets "${suite_name}")
  set(${out} ${_build_targets} PARENT_SCOPE)
endfunction()

# EMSCRIPTEN related testing stuffs
if (EMSCRIPTEN)
  set(quick_project_dom_test_dir ${CMAKE_CURRENT_LIST_DIR}/tool/dom_test)
  add_subdirectory(${quick_project_dom_test_dir})
  set(QUICK_PROJECT_TEST_COMMAND "node")

  function(quick_project_add_dom_test name_)
    string(REPLACE "/" "." name ${name_})
    if (NOT EMSCRIPTEN)
      return()
    endif(NOT EMSCRIPTEN)
    add_executable("${name}" EXCLUDE_FROM_ALL ${ARGN})
    add_dependencies(check "${name}")
    add_dependencies(${name} tool.dom_test)
    get_target_property(link_flags_ ${name} LINK_FLAGS)
    set_target_properties(${name} PROPERTIES LINK_FLAGS
      "${link_flags} --bind -s ASSERTIONS=1 --memory-init-file 0"
    )
    add_test(
      NAME ${name}
      COMMAND ${QUICK_PROJECT_TEST_COMMAND} ${quick_project_dom_test_dir}/index.js ./${name}.js
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )
    add_custom_target(run.${name}
      COMMAND ${QUICK_PROJECT_TEST_COMMAND} ${quick_project_dom_test_dir}/index.js ./${name}.js
      DEPENDS ${name} tool.dom_test
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      COMMENT "Build and run test: ${name}"
    )
  endfunction()

  function(quick_project_catch_dom_test_suite out suite_name)
    if (NOT EMSCRIPTEN)
      return()
    endif(NOT EMSCRIPTEN)
    set(_catch_main ${quick_project_project_SOURCE_DIR}/test/catch_main.cpp)
    foreach(_source IN ITEMS ${ARGN})
      string(REPLACE ".cpp" "" _name ${_source})
      list(APPEND _build_targets "individual.${suite_name}.${_name}")
      quick_project_add_dom_test("individual.${suite_name}.${_name}" ${_catch_main} ${_source})
    endforeach()
    quick_project_add_dom_test(${suite_name} ${_catch_main} ${ARGN})
    list(APPEND _build_targets "${suite_name}")
    set(${out} ${_build_targets} PARENT_SCOPE)
  endfunction()
endif(EMSCRIPTEN)
