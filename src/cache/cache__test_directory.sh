#==============================================================================
#  _______        _     _____  _               _             _
# |__   __|      | |   |  __ \(_)             | |           (_)
#    | | ___  ___| |_  | |  | |_ _ __ ___  ___| |_ ___  _ __ _  ___  ___
#    | |/ _ \/ __| __| | |  | | | '__/ _ \/ __| __/ _ \| '__| |/ _ \/ __|
#    | |  __/\__ \ |_  | |__| | | | |  __/ (__| || (_) | |  | |  __/\__ \
#    |_|\___||___/\__| |_____/|_|_|  \___|\___|\__\___/|_|  |_|\___||___/
#
#==============================================================================
# TEST DIRECTORIES
#==============================================================================

#==============================================================================
# For creating test fixtures, dm.test provides temporary test directories on
# three level. Test suite level, test file level, test case level. Each level
# corresponds to the lifetime of the given temporary test directory.
#
# The test suite level directory contents will be preserved during the
# execution of the whole test suite. The content there would be available for
# all test files and all test cases. Similarly, the test file and test case
# level temporary test directories will be available during the test file and
# test case execution.  After each test file and test case, their content will
# be invalidated (the global temp directory variables would point to a
# different directory).
#
# These three levels should help in writing test cases that require less clean
# up and there is a way to communicate between test files and test cases if
# needed.
#==============================================================================

# Variables that hold the test suite, test file and test case level test
# directory paths. These could be used in the test cases to set up testing
# fixtures. The naming of these variables breaks away from the conventions used
# in the codease to be able to use these variables in the test cases with ease.
DM_TEST__TEST_DIR__TEST_SUITE_LEVEL='__INVALID__'
DM_TEST__TEST_DIR__TEST_FILE_LEVEL='__INVALID__'
DM_TEST__TEST_DIR__TEST_CASE_LEVEL='__INVALID__'

#==============================================================================
# Creates the suite level test directory.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__TEST_DIR__TEST_SUITE_LEVEL
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__TEST_DIR__TEST_SUITE_LEVEL
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm_test__cache__init_test_directory__test_suite_level() {
  DM_TEST__TEST_DIR__TEST_SUITE_LEVEL="$( \
    dm_test__cache__create_temp_directory \
  )"

  dm_test__debug 'dm_test__cache__init_test_directory__test_suite_level' \
    'test suite level test dir created:'
  dm_test__debug 'dm_test__cache__init_test_directory__test_suite_level' \
    "$( \
      dm_tools__printf '%s' 'DM_TEST__TEST_DIR__TEST_SUITE_LEVEL: '; \
      dm_tools__echo "'${DM_TEST__TEST_DIR__TEST_SUITE_LEVEL}'" \
    )"
}

#==============================================================================
# Creates the file level test directory.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__TEST_DIR__TEST_FILE_LEVEL
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__TEST_DIR__TEST_FILE_LEVEL
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm_test__cache__init_test_directory__test_file_level() {
  DM_TEST__TEST_DIR__TEST_FILE_LEVEL="$(dm_test__cache__create_temp_directory)"

  dm_test__debug 'dm_test__cache__init_test_directory__test_file_level' \
    'test file level test dir created:'
  dm_test__debug 'dm_test__cache__init_test_directory__test_file_level' \
    "$( \
      dm_tools__printf '%s' 'DM_TEST__TEST_DIR__TEST_FILE_LEVEL: '; \
      dm_tools__echo "'${DM_TEST__TEST_DIR__TEST_FILE_LEVEL}'" \
    )"
}

#==============================================================================
# Creates the case level test directory.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__TEST_DIR__TEST_CASE_LEVEL
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__TEST_DIR__TEST_CASE_LEVEL
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm_test__cache__init_test_directory__test_case_level() {
  DM_TEST__TEST_DIR__TEST_CASE_LEVEL="$(dm_test__cache__create_temp_directory)"

  dm_test__debug 'dm_test__cache__init_test_directory__test_case_level' \
    'test case level test dir created:'
  dm_test__debug 'dm_test__cache__init_test_directory__test_case_level' \
    "$( \
      dm_tools__printf '%s' 'DM_TEST__TEST_DIR__TEST_CASE_LEVEL: '; \
      dm_tools__echo "'${DM_TEST__TEST_DIR__TEST_CASE_LEVEL}'" \
    )"
}
