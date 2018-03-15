# QuickProject

> Useful files and tools for boostrapping C++ projects.

> This project is a work in progress.

## Overview

* `util.cmake` with functions for adding tests and other convenience functions
* Testing using Catch or a shim for faster compile-times

## Cmake Functions [util.cmake]

`quick_project_add_check_target` 

* Adds a custom target `check` typically used for running all available tests

`quick_project_add_test(test_name, file_name)`
* Adds a single test from a source containing its own `main` function
  * `{test_name}` - test target compiles the test
  * `run.{test_name}` - custom target that runs the test

Example:

```
quick_project_add_test("test.mpdef.map" map.cpp)
```

`quick_project_catch_test_suite(output, suite_name, file_names...)`

* Adds targets for testing a group of cpp source files containing tests using both individual executables as well as a single executable with multiple translation units.
* Target names have slashes converted to `.` and the `.cpp` suffix removed
  * `{suite_name}` - test target compiles test suite with all test cpp source files
  * `run.{suite_name}` - custom target that runs the test suite
  * `individual.{suite_name}.{file_name}` - test target compiles an individual test file
  * `run.individual.{suite_name}.{file_name}` - custom target runs the compiled individual test
* The "`individual`" targets are not included in the `check` target.
* The `output` is a list with all of the executable targets

Example

```cmake
quick_project_catch_test_suite(build_targets test.nbdl.websocket
  detail/get_auth_token.cpp
  detail/message.cpp
  detail/parse_handshake_request.cpp
  detail/send_handshake_response.cpp
  endpoint.cpp
)

foreach(_target IN LISTS build_targets)
  target_link_libraries(${_target} ${CMAKE_THREAD_LIBS_INIT})
endforeach()
```

## Enable Using Catch [util.cmake]

* Cmake definition indicating if tests should use Catch or the shim (defaults to the shim)

Example:

```
cmake -DQUICK_PROJECT_USE_CATCH=1 .
```

## Supported Catch assertion macros

  * `TEST_CASE`
  * `REQUIRE`
  * `CHECK`
