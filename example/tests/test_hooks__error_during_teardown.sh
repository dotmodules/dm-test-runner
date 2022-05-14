#!/bin/sh
#==============================================================================
# TEST HOOKS
#==============================================================================

#==============================================================================
# Test file and test case level setup and teardown hooks are available for
# setting up test fixtures. You can run arbitrary code in them, but you should
# use the provided temporary directories for storing the fixtures.
#
# An error during the [teardown] hook would make the test case fail.
#
# 1. [setup file] hook will be executed
# 2. [setup] hook will be executed
# 3. test case will be executed
# 4. [teardown] hook will be executed, but error happens
# 5. test case will be marked as failed regardless of the test case result
# 6. next test cases will be executed with the [setup] and [teardown] hooks
# 7. [teardown file] hook will be executed
#==============================================================================

setup_file() {
  echo ''
  echo '--- ERROR DURING TEARDOWN HOOK --------------------------------------------------'
  echo 'echo during [setup file] hook'
}

setup() {
  echo 'echo during [setup] hook'
}

teardown() {
  echo 'echo during [teardown] hook - error will happen here'
  posix_adapter__cat invalid_file
}

teardown_file() {
  echo 'echo during [teardown file] hook - this hook will still run'
}

test__hooks__test_case__error_during_teardown() {
  echo 'echo during test case'
}
