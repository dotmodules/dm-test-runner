#!/bin/sh
#==============================================================================
# TEST DIRECTORIES
#==============================================================================

#==============================================================================
# During execution the test runner provides temporary directories that are
# available for the test cases to create and reuse test fixtures. There are
# three level of persistency: test case, test file and test suite. The test case
# level only valid for a lifetime of a test case. The test case level is
# available during a test file exeution. The test suite level is available
# during the whole test suite execution.
#
# Test directories can be access via the 3 positional arguments injected into
# every test case function and hook function. You can simply use those variables
# when you need to. Naming them is up to you. The ordering is always the same:
#
# - 1st injected variable - test suite level test directory path
# - 2nd injected variable - test file level test directory path
# - 3rd injected variable - test case level test directory path
#
# The following test cases will demonstrate this behavior. The test case level
# path should be unique for every test case. The test file level paths should be
# unique for a test file. The test suite level path should be the same for the
# test suite.
#==============================================================================

setup_file() {
  test_suite_level_test_directory="$1"
  test_file_level_test_directory="$2"
  # Test case level test directory cannot be inteerpreted in the setup and
  # teardown file hooks. There are only two parameters passed to these functions
  # containing the test suite and test file level test directory paths.

  dm_tools__echo "setup file 1 - [test suite]: ${test_suite_level_test_directory}"
  dm_tools__echo "setup file 1 - [test file]:  ${test_file_level_test_directory}"
}

teardown_file() {
  test_suite_level_test_directory="$1"
  test_file_level_test_directory="$2"
  # Test case level test directory cannot be inteerpreted in the setup and
  # teardown file hooks. There are only two parameters passed to these functions
  # containing the test suite and test file level test directory paths.

  dm_tools__echo "teardown file 1 - [test suite]: ${test_suite_level_test_directory}"
  dm_tools__echo "teardown file 1 - [test file]:  ${test_file_level_test_directory}"
}

setup() {
  test_suite_level_test_directory="$1"
  test_file_level_test_directory="$2"
  test_case_level_test_directory="$3"

  dm_tools__echo "setup 1 - [test suite]: ${test_suite_level_test_directory}"
  dm_tools__echo "setup 1 - [test file]:  ${test_file_level_test_directory}"
  dm_tools__echo "setup 1 - [test case]:  ${test_case_level_test_directory}"
}

teardown() {
  test_suite_level_test_directory="$1"
  test_file_level_test_directory="$2"
  test_case_level_test_directory="$3"

  dm_tools__echo "teardown 1 - [test suite]: ${test_suite_level_test_directory}"
  dm_tools__echo "teardown 1 - [test file]:  ${test_file_level_test_directory}"
  dm_tools__echo "teardown 1 - [test case]:  ${test_case_level_test_directory}"
}

test__test_directories__file_1__case_1() {
  test_suite_level_test_directory="$1"
  test_file_level_test_directory="$2"
  test_case_level_test_directory="$3"

  dm_tools__echo "test case 1 - [test suite]: ${test_suite_level_test_directory}"
  dm_tools__echo "test case 1 - [test file]:  ${test_file_level_test_directory}"
  dm_tools__echo "test case 1 - [test case]:  ${test_case_level_test_directory}"
}

test__test_directories__file_1__case_2() {
  test_suite_level_test_directory="$1"
  test_file_level_test_directory="$2"
  test_case_level_test_directory="$3"

  dm_tools__echo "test case 1 - [test suite]: ${test_suite_level_test_directory}"
  dm_tools__echo "test case 1 - [test file]:  ${test_file_level_test_directory}"
  dm_tools__echo "test case 1 - [test case]:  ${test_case_level_test_directory}"
}
