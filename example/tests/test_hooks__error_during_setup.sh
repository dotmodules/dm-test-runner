#!/bin/sh
#==============================================================================
# TEST HOOKS
#==============================================================================

#==============================================================================
# Test file and test case level setup and teardown hooks are available for
# setting up test fixtures. You can run arbitrary code in them, but you should
# use the provided temporary directories for storing the fixtures.
#
# An error during the [setup] hook would make the test case failed, and
# interrupt the test execution. The [teardown] hook won't be executed here, as
# it cannot be determined how far the setup hook reached before it failed.
#
# 1. [setup file] hook will be executed
# 2. [setup] hook will be executed, but error happens
# 3. test case will be marked as failed without execution
# 4. [teardown] hook won't be executed, as [setup] hook failed
# 5. next test cases will be executed with the [setup] and [teardown] hook, but
#    possibly they will fail also if the [setup] hook is static
# 6. [teardown file] hook will be executed
#==============================================================================

setup_file() {
  echo ''
  echo '--- ERROR DURING SETUP HOOK -----------------------------------------------------'
  echo 'echo during [setup file] hook'
}

setup() {
  echo 'echo during [setup] hook - error will happen here'
  cat invalid_file
}

teardown() {
  echo 'echo during [teardown] hook'
}

teardown_file() {
  echo 'echo during [teardown file] hook'
}

test__hooks__test_case__error_during_setup__case_2() {
  echo 'echo during test case 2'
}

test__hooks__test_case__error_during_setup__case_1() {
  echo 'echo during test case 1'
}
