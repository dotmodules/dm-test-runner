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
DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX='./runner'

DM_TEST__CONFIG__TEST_FILE_PREFIX='test_'
DM_TEST__CONFIG__TEST_CASE_PREFIX='capture_test_'
DM_TEST__CONFIG__TEST_CASES_ROOT='./tests'
DM_TEST__CONFIG__DEBUG_ENABLED=0

#==============================================================================
# TEST RUNNER IMPORT
#==============================================================================

# shellcheck source=./runner/dm.test.sh
. "${DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX}/dm.test.sh"

#==============================================================================
# ENTRY POINT
#==============================================================================

dm_test__run_suite
