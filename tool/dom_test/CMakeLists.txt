add_custom_command(
  OUTPUT ${quick_project_dom_test_dir}/index.js
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/tool/dom_test ${quick_project_dom_test_dir}
)

add_custom_command(
  OUTPUT ${quick_project_dom_test_dir}/node_modules
  COMMAND npm install --silent
  WORKING_DIRECTORY ${quick_project_dom_test_dir}
  COMMENT "Resolving npm deps for dom_test."
)

add_custom_target(tool.dom_test
  DEPENDS
    ${quick_project_dom_test_dir}/index.js
    ${quick_project_dom_test_dir}/node_modules
)
