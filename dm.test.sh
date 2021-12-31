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
# Welcome to the dm-test source code! As a side-project during implementing the
# dotmodules configuration manager system, dm-test was born in a need to have a
# simple yet powerful pure bash testing library, that suit my needs: fast
# execution, detailed debugging, modern test-suite features (hooks, mocking
# possibilities, isolated testing). I found the existing test runners for pure
# shell/bash project lack of these.
#==============================================================================

#==============================================================================
# I tried my best to write a well documented code base, and you might find it a
# bit too much, but don't forget that we are talking with shell code in here
# with a very poor control over the programming features like parameters and
# return values. I tried to balance these shortcomings with painfully
# explicit documentation. Each and every function in this project is prepended
# with a documentation section that states the purpose and interface of that
# function. With this in place, I believe that maintaining this codebase would
# be easier in the future.
#==============================================================================

#==============================================================================
# Since dm-test is intended to be used inside other codebase, and pure shell
# doesn't have scoping for variables, everything will be in a global namespace.
# Because of these, the dm-test project uses long function names with the
# 'dm_test__' prefix, and for every variable it will use the '___' prefix to
# (hopefully) not to clash with any other variables in the tested code base.
#==============================================================================

#==============================================================================
# To be able to be fully platform independent out-of-the-box, dm-tools is
# relying on another side-side-project (already down three levels in the rabbit
# hole..) called dm-tools. Every command line tool call in this project is
# executed through the dm-tools interface after it is loaded (that means the
# first initialization of the test system runs on pure cli tools, which means
# special care needs to be taken in order to be platform independent!).
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
dm_test__report_error_and_exit() {
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
# For better readability dm.test.sh is composed out of smaller scripts that are
# sourced dynamically. As dm.test.sh is imported to the user code base by
# sourcing, the conventional path determination cannot be used. The '$0'
# variable contains the host script's path the dm.test.sh file is sourced from.
# The relative path to the root of the dm-test-runner subrepo has to be defined
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

#==============================================================================
# DM_TOOLS INTEGRATION
#==============================================================================

#==============================================================================
# The first module we are loading is the dm-tools project that would provide
# the necessary platform independent interface for the command line tools. We
# are only loading the dm-tools system when it hasn't been loaded by the other
# code (the tested system for example).
#==============================================================================

if [ -z ${DM_TOOLS__READY+x} ]
then
  # If dm_tools has not sourced yet, we have to source it from this repository.
  ___dm_tools_path_prefix="${___path_prefix}/dependencies/dm-tools"
  DM_TOOLS__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX="$___dm_tools_path_prefix"
  if [ -d "$DM_TOOLS__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX" ]
  then
    # shellcheck source=./dependencies/dm-tools/dm.tools.sh
    . "${DM_TOOLS__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX}/dm.tools.sh"
  else
    dm_test__report_error_and_exit \
      'Initialization failed!' \
      'dm_tools needs to be initialized but its git submodule is missing!' \
      'You need to source it or init its submodule here: git submodule init'
  fi
fi

#==============================================================================
# IMPORTANT: After this, every non shell built-in command should be called
# through the provided dm_tools API to ensure the compatibility on different
# environments.
#==============================================================================

#==============================================================================
# SOURCING SUBMODULES
#==============================================================================

# shellcheck source=./src/config.sh
. "${___path_prefix}/src/config.sh"
# shellcheck source=./src/variables.sh
. "${___path_prefix}/src/variables.sh"
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

# shellcheck source=./src/assert/assert__common.sh
. "${___path_prefix}/src/assert/assert__common.sh"
# shellcheck source=./src/assert/assert__basic.sh
. "${___path_prefix}/src/assert/assert__basic.sh"
# shellcheck source=./src/assert/assert__file_system.sh
. "${___path_prefix}/src/assert/assert__file_system.sh"
# shellcheck source=./src/assert/assert__context_based.sh
. "${___path_prefix}/src/assert/assert__context_based.sh"

# shellcheck source=./src/store.sh
. "${___path_prefix}/src/store.sh"

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
#==============================================================================
dm_test__run_suite() {
  dm_test__debug__wrapper 'dm_test__test_suite__main'
}
