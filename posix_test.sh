#!/bin/sh
#==============================================================================
#                   _         _            _         _
#                  (_)       | |          | |       | |
#   _ __   ___  ___ ___  __  | |_ ___  ___| |_   ___| |__
#  | '_ \ / _ \/ __| \ \/ /  | __/ _ \/ __| __| / __| '_ \
#  | |_) | (_) \__ \ |>  <,__| ||  __/\__ \ |_ _\__ \ | | |
#  | .__/ \___/|___/_/_/\_|__|___\___||___/\__(_)___/_| |_|
#  | |
#==|_|=========================================================================

#==============================================================================
# Welcome to the posix-test source code! As a side-project during implementing
# the dotmodules configuration manager system, posix-test was born in a need to
# have a simple yet powerful pure bash testing library, that suit my needs:
# fast execution, detailed debugging, modern test-suite features (hooks,
# mocking possibilities, isolated testing). I found the existing test runners
# for pure shell/bash projects are lacking of these.
#==============================================================================

#==============================================================================
# I tried my best to write a well documented code base, and you might find it a
# bit too much, but don't forget that we are talking about shell code in here
# with a very poor control over the programming features like parameters and
# return values. I tried to balance these shortcomings with painfully explicit
# documentation. Each and every function in this project is prepended with a
# documentation section that states the purpose and interface of that function.
# With this in place, I believe that maintaining this codebase would be easier
# in the future.
#==============================================================================

#==============================================================================
# Since posix-test is intended to be used inside other codebase, and pure shell
# doesn't have scoping for variables, everything will be in a global namespace.
# Because of that, the posix-test project uses long function names with the
# 'posix_test__' prefix, and for every variable it will use the '___' prefix to
# (hopefully) not to clash with any other variables in the tested code base.
#==============================================================================

#==============================================================================
# To be able to be fully platform independent out-of-the-box, posix-test is
# relying on another side-side-project (already down three levels in the rabbit
# hole..) called posix-adapter. Every command line tool call in this project is
# executed through the posix-adapter interface after it is loaded (that means
# the first initialization of the test system runs on pure cli tools, which
# means special care needs to be taken in order to be platform independent!).
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
# without sourcing the sub files and the external dependencies. It should only
# use platform independent external commands and shell features.
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
#==============================================================================
posix_test__report_error_and_exit() {
  ___message="$1"
  ___details="$2"
  ___reason="$3"

  # This function might be called before the global coloring variables gets
  # initialized, hence the default value setting.
  RED="${RED:=}"
  BOLD="${BOLD:=}"
  RESET="${RESET:=}"

  >&2 printf '%s=======================================================' "$RED"
  >&2 echo "========================${RESET}"
  >&2 echo "  ${RED}${BOLD}FATAL ERROR${RESET}"
  >&2 printf '%s=======================================================' "$RED"
  >&2 echo "========================${RESET}"
  >&2 echo ''
  >&2 echo "  ${RED}${___message}${RESET}"
  >&2 echo "  ${RED}${___details}${RESET}"
  >&2 echo ''
  >&2 echo "${___reason}" | sed "s/^/  ${RED}/" | sed "s/$/${RESET}/"
  >&2 echo ''
  >&2 printf '%s=======================================================' "$RED"
  >&2 echo "========================${RESET}"

  exit 1
}

#==============================================================================
# GLOBAL PATH PREFIX
#==============================================================================

#==============================================================================
# For better readability posix_test.sh is composed out of smaller scripts that are
# sourced dynamically. As posix_test.sh is imported to the user code base by
# sourcing, the conventional path determination cannot be used. The '$0'
# variable contains the host script's path the posix_test.sh file is sourced from.
# The relative path to the root of the posix-test-runner subrepo has to be defined
# explicitly to the internal sourcing could be executed.
#==============================================================================

if [ -z ${POSIX_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX+x} ]
then
  posix_test__report_error_and_exit \
    'Initialization failed!' \
    'Mandatory path prefix variable is missing!' \
    'POSIX_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX'
fi

___path_prefix="${POSIX_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX}"

#==============================================================================
# POSIX_ADAPTER INTEGRATION
#==============================================================================

#==============================================================================
# The first module we are loading is the posix-adapter project that would
# provide the necessary platform independent interface for the command line
# tools. We are only loading the posix-adapter system when it hasn't been
# loaded by other code (the tested system for example).
#==============================================================================

if [ -z ${POSIX_ADAPTER__READY+x} ]
then
  # If posix_adapter has not sourced yet, we have to source it from this
  # repository. Implementing the posix-adapter inporting system variables.
  ___posix_adapter_path_prefix="${___path_prefix}/dependencies/posix-adapter"
  POSIX_ADAPTER__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX="$___posix_adapter_path_prefix"
  if [ -d "$POSIX_ADAPTER__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX" ]
  then
    # shellcheck source=./dependencies/posix-adapter/posix_adapter.sh
    . "${POSIX_ADAPTER__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX}/posix_adapter.sh"
  else
    posix_test__report_error_and_exit \
      'Initialization failed!' \
      'posix_adapter needs to be initialized but its git submodule is missing!' \
      'You need to source it or init its submodule here: git submodule init'
  fi
fi

#==============================================================================
# IMPORTANT: After this, every non shell built-in command should be called
# through the provided posix-adapter API to ensure the compatibility on
# different environments.
#==============================================================================

#==============================================================================
# SOURCING SUBMODULES
#==============================================================================

# shellcheck source=./src/core/config.sh
. "${___path_prefix}/src/core/config.sh"
# shellcheck source=./src/core/variables.sh
. "${___path_prefix}/src/core/variables.sh"
# shellcheck source=./src/core/utils.sh
. "${___path_prefix}/src/core/utils.sh"
# shellcheck source=./src/core/test_suite.sh
. "${___path_prefix}/src/core/test_suite.sh"
# shellcheck source=./src/core/test_case.sh
. "${___path_prefix}/src/core/test_case.sh"
# shellcheck source=./src/core/hooks.sh
. "${___path_prefix}/src/core/hooks.sh"
# shellcheck source=./src/core/capture.sh
. "${___path_prefix}/src/core/capture.sh"

# shellcheck source=./src/core/cache/cache__base.sh
. "${___path_prefix}/src/core/cache/cache__base.sh"
# shellcheck source=./src/core/cache/cache__global_errors.sh
. "${___path_prefix}/src/core/cache/cache__global_errors.sh"
# shellcheck source=./src/core/cache/cache__test_result.sh
. "${___path_prefix}/src/core/cache/cache__test_result.sh"
# shellcheck source=./src/core/cache/cache__global_count.sh
. "${___path_prefix}/src/core/cache/cache__global_count.sh"
# shellcheck source=./src/core/cache/cache__global_failure.sh
. "${___path_prefix}/src/core/cache/cache__global_failure.sh"
# shellcheck source=./src/core/cache/cache__test_directory.sh
. "${___path_prefix}/src/core/cache/cache__test_directory.sh"

# shellcheck source=./src/api/assert/assert__common.sh
. "${___path_prefix}/src/api/assert/assert__common.sh"
# shellcheck source=./src/api/assert/assert__basic.sh
. "${___path_prefix}/src/api/assert/assert__basic.sh"
# shellcheck source=./src/api/assert/assert__file_system.sh
. "${___path_prefix}/src/api/assert/assert__file_system.sh"
# shellcheck source=./src/api/assert/assert__context_based.sh
. "${___path_prefix}/src/api/assert/assert__context_based.sh"

# shellcheck source=./src/core/store.sh
. "${___path_prefix}/src/core/store.sh"

# shellcheck source=./src/core/debug.sh
. "${___path_prefix}/src/core/debug.sh"
# shellcheck source=./src/core/trap.sh
. "${___path_prefix}/src/core/trap.sh"

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
# Only API function for the posix_test test runner. It looks for the test files
# in the predefined test root directory and executes the test cases one by one.
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
#==============================================================================
posix_test__run_suite() {
  if posix_test__config__debug_is_enabled
  then
    # Wrapping the main function of the test suite runner in order to initialize
    # the debugger file descriptor.
    posix_test__debug__wrapper 'posix_test__test_suite__main'
  else
    posix_test__test_suite__main
  fi
}
