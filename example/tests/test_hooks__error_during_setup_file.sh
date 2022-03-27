#!/bin/sh
#==============================================================================
# TEST HOOKS
#==============================================================================

#==============================================================================
# Test file and test case level setup and teardown hooks are available for
# setting up test fixtures. You can run arbitrary code in them, but you should
# use the provided temporary directories for storing the fixtures.
#
# An error during the [setup file] test hook execution would terminate the
# current test file execution, as it is a non recoverable error. Execution will
# continue on the next test file if present.
#
# 1. [setup file] hook will be executed, but error happens
# 2. whole test file execution will be aborted
# 3. [teardown file] hook won't be executed
# 4. other test files will be executed
#==============================================================================

setup_file() {
  posix_adapter__echo ''
  posix_adapter__echo '--- ERROR DURING SETUP FILE HOOK ------------------------------------------------'
  posix_adapter__echo 'echo during [setup file] hook - error will happen here'
  posix_adapter__cat invalid_file
}

setup() {
  posix_adapter__echo 'echo during [setup] hook'
}

teardown() {
  posix_adapter__echo 'echo during [teardown] hook'
}

teardown_file() {
  posix_adapter__echo 'echo during [teardown file] hook'
}

test__hooks__test_case() {
  posix_adapter__echo 'echo during test case'
}
