#!/bin/sh
#==============================================================================
# TEST HOOKS
#==============================================================================

#==============================================================================
# Test file and test case level setup and teardown hooks are available for
# setting up test fixtures. You can run arbitrary code in them, but you should
# use the provided temporary directories for storing the fixtures.
#
# The hook functions are gathered during the test file initialization step by
# looking into the actual test file and collect the functions that are named
# with the right names. If you have redefined a hook function by mistake, only
# the last hook function will be executed when calling it.
#==============================================================================

setup_file() {
  posix_adapter__echo ''
  posix_adapter__echo '--- MULTIPLE HOOK FUNCTIONS -----------------------------------------------------'
  posix_adapter__echo 'echo during [setup file] hook'
}

setup() {
  posix_adapter__echo 'echo during first [setup] hook function'
}

setup() {
  posix_adapter__echo 'echo during second [setup] hook function'
}

setup() {
  # Only this will be executed!
  posix_adapter__echo 'echo during third [setup] hook function'
}

test__hooks__test_case__multiple_hook_functions() {
  posix_adapter__echo 'echo during test case - error will happen after this to see the logs'
  posix_adapter__cat invalid_file
}
