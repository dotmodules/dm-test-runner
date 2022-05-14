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
  echo ''
  echo '--- ERROR DURING SETUP FILE HOOK ------------------------------------------------'
  echo 'echo during [setup file] hook - error will happen here'
  posix_adapter__cat invalid_file
}

setup() {
  echo 'echo during [setup] hook'
}

teardown() {
  echo 'echo during [teardown] hook'
}

teardown_file() {
  echo 'echo during [teardown file] hook'
}

test__hooks__test_case() {
  echo 'echo during test case'
}
