#!/bin/sh
# shellcheck disable=SC2034

#==============================================================================
# SANE ENVIRONMENT
#==============================================================================

set -e  # exit on error
set -u  # prevent unset variable expansion

#==============================================================================
# PATH CHANGE
#==============================================================================

cd "$(dirname "$(readlink -f "$0")")"

#==============================================================================
# DM_TEST_RUNNER CONFIGURATION
#==============================================================================

# Relative path to from the current path to the test runner repo.
DM_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX='./runner'

DM_TEST__CONFIG__MANDATORY__TEST_FILE_PREFIX='testdebug_'
DM_TEST__CONFIG__MANDATORY__TEST_CASE_PREFIX='test_'
DM_TEST__CONFIG__MANDATORY__TEST_CASES_ROOT='./tests'

DM_TEST__CONFIG__OPTIONAL__CACHE_PARENT_DIRECTORY='./temp_cache_directory'
DM_TEST__CONFIG__OPTIONAL__EXIT_ON_FAILURE=0
DM_TEST__CONFIG__OPTIONAL__EXIT_STATUS_ON_FAILURE=1
DM_TEST__CONFIG__OPTIONAL__ALWAYS_DISPLAY_FILE_LEVEL_HOOK_OUTPUT=0
DM_TEST__CONFIG__OPTIONAL__DEBUG_ENABLED=1

#==============================================================================
# TEST RUNNER IMPORT
#==============================================================================

# shellcheck source=./runner/dm.test.sh
. "${DM_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX}/dm.test.sh"

#==============================================================================
# REDIRECTING THE DEBUGGER TO A DIFFERENT FILE DESCRIPTOR THAN FD4
#==============================================================================
# For more details check out the 'src/debug.sh' file.

dm_test__debug__printf() {
  # shellcheck disable=SC2059
  >&8 printf "$@"
}

dm_test__debug__wrapper() {
  "$@" 8>&1
}

#==============================================================================
# ENTRY POINT
#==============================================================================

dm_test__run_suite

assert_test_case_count 2
assert_failure_count 1
