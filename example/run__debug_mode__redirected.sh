#!/bin/sh
# Expressions don't expand inside single quotes.
# shellcheck disable=SC2016
# Single quote escapement.
# shellcheck disable=SC1003
# Single quote escapement.
# shellcheck disable=SC2034

#==============================================================================
# SANE ENVIRONMENT
#==============================================================================

set -e  # exit on error
set -u  # prevent unset variable expansion

#==============================================================================
# PATH CHANGE
#==============================================================================

# This is the only part where the code has to be prepared for missing tool
# capabilities. It is known that on MacOS readlink does not support the -f flag
# by default.
if target_path="$(readlink -f "$0" 2>/dev/null)"
then
  cd "$(dirname "$target_path")"
else
  # If the path cannot be determined with readlink, we have to check if this
  # script is executed through a symlink or not.
  if [ -L "$0" ]
  then
    # If the current script is executed through a symlink, we are out of luck,
    # because without readlink, there is no universal solution for this problem
    # that uses the default shell toolset.
    echo "symlinked script won't work on this machine.."
  else
    cd "$(dirname "$0")"
  fi
fi

#==============================================================================
# COMMON TEST SUITE LIB
#==============================================================================

. ./common.sh

#==============================================================================
# POSIX_TEST_RUNNER CONFIGURATION
#==============================================================================

# Relative path to from the current path to the test runner repo.
POSIX_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX='./runner'

POSIX_TEST__CONFIG__MANDATORY__TEST_FILE_PREFIX='test_debug__'
POSIX_TEST__CONFIG__MANDATORY__TEST_CASE_PREFIX='test_'
POSIX_TEST__CONFIG__MANDATORY__TEST_FILES_ROOT='./tests'

POSIX_TEST__CONFIG__OPTIONAL__CACHE_PARENT_DIRECTORY='./temp_cache_directory'
POSIX_TEST__CONFIG__OPTIONAL__EXIT_ON_FAILURE=0
POSIX_TEST__CONFIG__OPTIONAL__EXIT_STATUS_ON_FAILURE=1
POSIX_TEST__CONFIG__OPTIONAL__ALWAYS_DISPLAY_FILE_LEVEL_HOOK_OUTPUT=0
POSIX_TEST__CONFIG__OPTIONAL__DISPLAY_CAPTURED_OUTPUT_ON_SUCCESS=0
POSIX_TEST__CONFIG__OPTIONAL__SORTED_TEST_CASE_EXECUTION=0
POSIX_TEST__CONFIG__OPTIONAL__DEBUG_ENABLED=1

#==============================================================================
# TEST RUNNER IMPORT
#==============================================================================

# shellcheck source=./runner/posix_test.sh
. "${POSIX_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX}/posix_test.sh"

#==============================================================================
# REDIRECTING THE DEBUGGER TO A DIFFERENT FILE DESCRIPTOR THAN FD4
#==============================================================================

posix_test__debug__printf() {
  # Overriding the internal debugger output redirection function. In this way
  # the debugger will emit messages through the file descriptior set by this
  # overridden function. For more details check out the 'src/debug.sh' file.
  # shellcheck disable=SC2059
  >&8 printf "$@"
}

posix_test__debug__wrapper() {
  # For more details check out the 'src/debug.sh' file.
  "$@" 8>&1
}

#==============================================================================
# ENTRY POINT
#==============================================================================

posix_adapter__echo "${DIM}==============================================================================="
posix_adapter__echo '   _____          _ _               _           _       _      _'
posix_adapter__echo '  |  __ \        | (_)             | |         | |     | |    | |'
posix_adapter__echo '  | |__) |___  __| |_ _ __ ___  ___| |_ ___  __| |   __| | ___| |__  _   _  __ _'
posix_adapter__echo '  |  _  // _ \/ _` | | '\''__/ _ \/ __| __/ _ \/ _` |  / _` |/ _ \ '\''_ \| | | |/ _` |'
posix_adapter__echo '  | | \ \  __/ (_| | | | |  __/ (__| ||  __/ (_| | | (_| |  __/ |_) | |_| | (_| |'
posix_adapter__echo '  |_|  \_\___|\__,_|_|_|  \___|\___|\__\___|\__,_|  \__,_|\___|_.__/ \__,_|\__, |'
posix_adapter__echo '                                                                            __/ |'
posix_adapter__echo '===========================================================================|___/'
posix_adapter__echo '  REDIRECTED DEBUG CASES'
posix_adapter__echo '==============================================================================='
posix_adapter__echo "${RESET}"

posix_test__run_suite

assert_test_case_count 2
assert_failure_count 1
