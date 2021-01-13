#!/bin/sh
#==============================================================================
#      _            _            _         _
#     | |          | |          | |       | |
#   __| |_ __ ___  | |_ ___  ___| |_   ___| |__
#  / _` | '_ ` _ \ | __/ _ \/ __| __| / __| '_ \
# | (_| | | | | | || ||  __/\__ \ |_ _\__ \ | | |
#  \__,_|_| |_| |_(_)__\___||___/\__(_)___/_| |_|
#
#==============================================================================

#==============================================================================
# SANE ENVIRONMENT
#==============================================================================

set -e  # exit on error
set -u  # prevent unset variable expansion

#==============================================================================
# MAIN ERROR HANDLING ASSERTION FUNCTION
#==============================================================================

#==============================================================================
# Error reporting function that will display the given message and abort the
# execution. This needs to be defined in the highest level to be able to use it
# without sourcing the sub files.
#------------------------------------------------------------------------------
# Globals:
#   RED
#   BOLD
#   RESET
# Arguments:
#   [1] message - Error message that will be displayed.
#   [2] details - Detailed error message.
#   [3] reason - Reason of this error.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Error message.
# STDERR:
#   None
# Status:
#   1 - System will exit at the end of this function.
#------------------------------------------------------------------------------
# Tools:
#   echo sed
#==============================================================================
dm_test__report_error_and_exit() {
  ___message="$1"
  ___details="$2"
  ___reason="$3"

  # This function might be called before the global coloring valriables gets
  # initialized, hence the default value setting.
  RED="${RED:=}"
  BOLD="${BOLD:=}"
  RESET="${RESET:=}"

  >&2 printf '%s=======================================' "$RED"
  >&2 echo "========================================${RESET}"
  >&2 echo "  ${RED}${BOLD}FATAL ERROR${RESET}"
  >&2 printf '%s=======================================' "$RED"
  >&2 echo "========================================${RESET}"
  >&2 echo ''
  >&2 echo "  ${RED}${___message}${RESET}"
  >&2 echo "  ${RED}${___details}${RESET}"
  >&2 echo ''
  # Running in a subshell to keep line length below 80.
  # shellcheck disable=SC2005
  >&2 echo "$( \
    echo "${___reason}" | sed "s/^/  ${RED}/" | sed "s/$/${RESET}/" \
  )"
  >&2 echo ''
  >&2 printf '%s=======================================' "$RED"
  >&2 echo "========================================${RESET}"

  exit 1
}

#==============================================================================
# SOURCING SUBMODULES
#==============================================================================

#==============================================================================
# For better readability dm.test.sh is composed of smaller scripts that are
# sourced into it dynamically. As dm.test.sh is imported to the user codebase
# by sourcing, the conventional path determination cannot be used. The '$0'
# variable contains the the host script's path dm.test.sh is sourced from. The
# relative path to the root of the dm-test-runner subrepo has to be defined
# explicitly to the internal sourcing could be executed.
#==============================================================================

if [ -z ${DM_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX+x} ]
then
  dm_test__report_error_and_exit \
    'Initialization failed!' \
    'Mandatory path prefix variable is missing!' \
    'DM_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX'
fi

___path_prefix="${DM_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX}"

# shellcheck source=./src/config.sh
. "${___path_prefix}/src/config.sh"
# shellcheck source=./src/variables.sh
. "${___path_prefix}/src/variables.sh"
# shellcheck source=./src/assert.sh
. "${___path_prefix}/src/assert.sh"
# shellcheck source=./src/utils.sh
. "${___path_prefix}/src/utils.sh"
# shellcheck source=./src/test_suite.sh
. "${___path_prefix}/src/test_suite.sh"
# shellcheck source=./src/test_case.sh
. "${___path_prefix}/src/test_case.sh"
# shellcheck source=./src/hooks.sh
. "${___path_prefix}/src/hooks.sh"
# shellcheck source=./src/capture.sh
. "${___path_prefix}/src/capture.sh"

# shellcheck source=./src/cache/cache__base.sh
. "${___path_prefix}/src/cache/cache__base.sh"
# shellcheck source=./src/cache/cache__global_errors.sh
. "${___path_prefix}/src/cache/cache__global_errors.sh"
# shellcheck source=./src/cache/cache__test_result.sh
. "${___path_prefix}/src/cache/cache__test_result.sh"
# shellcheck source=./src/cache/cache__global_count.sh
. "${___path_prefix}/src/cache/cache__global_count.sh"
# shellcheck source=./src/cache/cache__global_failure.sh
. "${___path_prefix}/src/cache/cache__global_failure.sh"
# shellcheck source=./src/cache/cache__test_directory.sh
. "${___path_prefix}/src/cache/cache__test_directory.sh"

# shellcheck source=./src/debug.sh
. "${___path_prefix}/src/debug.sh"
# shellcheck source=./src/trap.sh
. "${___path_prefix}/src/trap.sh"

#==============================================================================
#     _    ____ ___    __                  _   _
#    / \  |  _ \_ _|  / _|_   _ _ __   ___| |_(_) ___  _ __  ___
#   / _ \ | |_) | |  | |_| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
#  / ___ \|  __/| |  |  _| |_| | | | | (__| |_| | (_) | | | \__ \
# /_/   \_\_|  |___| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
#==============================================================================
# API FUNCTIONS
#==============================================================================

#==============================================================================
# Only API function for the dm.test test runner. It looks for the test files in
# the predefined test root directory and executes the test cases one by one.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Execution results.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   None
#==============================================================================
dm_test__run_suite() {
  dm_test__debug__wrapper 'dm_test__test_suite__main'
}
