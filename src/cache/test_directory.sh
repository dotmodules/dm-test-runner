#==============================================================================
#  _____         _     ____  _               _
# |_   _|__  ___| |_  |  _ \(_)_ __ ___  ___| |_ ___  _ __ _   _
#   | |/ _ \/ __| __| | | | | | '__/ _ \/ __| __/ _ \| '__| | | |
#   | |  __/\__ \ |_  | |_| | | | |  __/ (__| || (_) | |  | |_| |
#   |_|\___||___/\__| |____/|_|_|  \___|\___|\__\___/|_|   \__, |
#                                                          |___/
#==============================================================================
# TEST DIRECTORY
#==============================================================================

#==============================================================================
# For creating test fixtures, dm.test provides temporary test directories on
# three level. Test suite level, test file level, test case level. Each level
# corresponds to the lifetime of the given temporary test directory. The test
# suite level directory contents will be preserved during the execution of the
# whole test suite. The content there would be available for all test files and
# all test cases. Similarly, the test file and test case level temporary test
# directories will be available during the test file and test case execution.
# After each test file and test case, their content will be invalidated (the
# global temp directory variables would point to a different directory). These
# three level should help in writing test cases that require less clean up and
# there is a way to communicate between test files and test cases if needed.
#==============================================================================

# Variables that hold the test suite, test file and test case level test
# directory paths. These could be used in the test cases to set up testing
# fixtures.
DM_TEST__TEST_DIR__TEST_SUITE="__INVALID__"
DM_TEST__TEST_DIR__TEST_FILE="__INVALID__"
DM_TEST__TEST_DIR__TEST_CASE="__INVALID__"

#==============================================================================
# Creates the suite level test directory.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__TEST_DIR__TEST_SUITE
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__TEST_DIR__TEST_SUITE
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   None
#==============================================================================
dm_test__cache__init_test_directory__test_suite() {
  DM_TEST__TEST_DIR__TEST_SUITE="$(dm_test__cache__create_temp_directory)"

  dm_test__debug \
    'dm_test__cache__init_test_directory__test_suite' \
    "test suite level test directory created: '${DM_TEST__TEST_DIR__TEST_SUITE}'"
}

#==============================================================================
# Creates the file level test directory.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__TEST_DIR__TEST_FILE
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__TEST_DIR__TEST_FILE
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   None
#==============================================================================
dm_test__cache__init_test_directory__test_file() {
  DM_TEST__TEST_DIR__TEST_FILE="$(dm_test__cache__create_temp_directory)"

  dm_test__debug \
    'dm_test__cache__init_test_directory__test_file' \
    "test file level test directory created: '${DM_TEST__TEST_DIR__TEST_FILE}'"
}

#==============================================================================
# Creates the case level test directory.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__TEST_DIR__TEST_CASE
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__TEST_DIR__TEST_CASE
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   None
#==============================================================================
dm_test__cache__init_test_directory__test_case() {
  DM_TEST__TEST_DIR__TEST_CASE="$(dm_test__cache__create_temp_directory)"

  dm_test__debug \
    'dm_test__cache__init_test_directory__test_case' \
    "test case level test directory created: '${DM_TEST__TEST_DIR__TEST_CASE}'"
}
