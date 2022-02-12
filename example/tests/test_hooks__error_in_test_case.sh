#!/bin/sh
#==============================================================================
# TEST HOOKS
#==============================================================================

#==============================================================================
# Test file and test case level setup and teardown hooks are available for
# setting up test fixtures. You can run arbitrary code in them, but you should
# use the provided temporary directories for storing the fixtures.
#
# An error during the test case will make the test case to fail, but the
# corresponding [teardown] hook will be executed. after that the next test case
# will be executed.
#
# 1. [setup file] hook will be executed
# 2. [setup] hook will be executed
# 3. test case will be executed but error happens
# 4. [teardown] hook will be executed
# 5. next test case will be executed with the [setup] and [teardown] hooks
# 6. [teardown file] hook will be executed after the last test case in that
#    file
# 7. next test file will be executed with the [setup file] and [teardown file]
#    hooks
#==============================================================================

setup_file() {
  dm_tools__echo ''
  dm_tools__echo '--- ERROR DURING TEST CASE ------------------------------------------------------'
  dm_tools__echo 'echo during [setup file] hook'
}

setup() {
  dm_tools__echo 'echo during [setup] hook'
}

teardown() {
  dm_tools__echo 'echo during [teardown] hook'
}

teardown_file() {
  dm_tools__echo 'echo during [teardown file] hook'
}

test__hooks__test_case__error_during_test_case__case_1() {
  dm_tools__echo 'echo during test case 1 - error will happen after this'
  dm_tools__cat invalid_file
}

test__hooks__test_case__error_during_test_case__case_2() {
  dm_tools__echo 'echo during test case 2'
}
