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

# At this point we have dm_tools loaded.
cd "$(dm_tools__dirname "$(dm_tools__readlink --canonicalize "$0")")"

#==============================================================================
# DM_TEST_RUNNER CONFIGURATION
#==============================================================================

# Relative path to from the current path to the test runner repo.
DM_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX='./runner'

DM_TEST__CONFIG__MANDATORY__TEST_FILE_PREFIX='test_capture__'
DM_TEST__CONFIG__MANDATORY__TEST_CASE_PREFIX='test_'
DM_TEST__CONFIG__MANDATORY__TEST_FILES_ROOT='./tests'

DM_TEST__CONFIG__OPTIONAL__CACHE_PARENT_DIRECTORY='./temp_cache_directory'
DM_TEST__CONFIG__OPTIONAL__EXIT_ON_FAILURE=0
DM_TEST__CONFIG__OPTIONAL__EXIT_STATUS_ON_FAILURE=1
DM_TEST__CONFIG__OPTIONAL__ALWAYS_DISPLAY_FILE_LEVEL_HOOK_OUTPUT=0
DM_TEST__CONFIG__OPTIONAL__SORTED_TEST_CASE_EXECUTION=0
DM_TEST__CONFIG__OPTIONAL__DEBUG_ENABLED=0

#==============================================================================
# TEST RUNNER IMPORT
#==============================================================================

# shellcheck source=./runner/dm.test.sh
. "${DM_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX}/dm.test.sh"

#==============================================================================
# ENTRY POINT
#==============================================================================

dm_test__run_suite

assert_test_case_count 5
assert_failure_count 4
