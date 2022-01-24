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
# RUNNING TEST SUITES
#==============================================================================

./run__assert__success.sh
./run__assert__failure.sh
./run__captures.sh
./run__test_directories.sh
./run__debug_mode__default.sh
./run__debug_mode__redirected.sh
./run__hooks.sh
./run__store.sh

#==============================================================================
# SHELLCHECK VALIDATION
#==============================================================================

run_shellcheck() {
  log_task 'running shellcheck..'
  # Specifying shell type here to be able to omit the shebangs from the
  # modules. More info: https://github.com/koalaman/shellcheck/wiki/SC2148
  shellcheck --shell=sh -x \
    ../src/api/assert/*.sh \
    ../src/core/*.sh \
    ../src/core/cache/*.sh \
    ../example/*.sh
  log_success 'shellcheck finished'
}

if command -v shellcheck >/dev/null
then
  run_shellcheck
else
  dm_tools__echo "WARNING: shellcheck won't be executed as it cannot be found."
fi

#==============================================================================
# SUMMARY
#==============================================================================
# If we reach this point the runners didn't reported an error so we are safe to
# say the test suite succeeded.
dm_tools__echo "${BOLD}${GREEN}"
dm_tools__echo '==============================================================================='
dm_tools__echo '                      All example test suite executed with'
dm_tools__echo '                    the expected test case and failure count.'
dm_tools__echo '==============================================================================='
dm_tools__echo "$RESET"
