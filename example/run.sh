#!/bin/sh
# These two shellcheck errors are produced in the ascii arts. Disabling them
# globally.
# shellcheck disable=SC2016,SC1003

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
if target_path="$(readlink -f "$0")" 2>/dev/null
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
# DM_TOOLS INTEGRATION
#==============================================================================

if [ -z ${DM_TOOLS__READY+x} ]
then
  # If dm_tools has not sourced yet, we have to source it from this repository.
  DM_TOOLS__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX='../dependencies/dm-tools'
  if [ -d  "$DM_TOOLS__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX" ]
  then
    # shellcheck source=../dependencies/dm-tools/dm.tools.sh
    . "${DM_TOOLS__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX}/dm.tools.sh"
  else
    echo 'dm-tools submodule needs to be initialized. run make init'
  fi
fi

# IMPORTANT: After this, every non shell built-in command should be called
# through the provided dm_tools API to ensure the compatibility on different
# environments.

#==============================================================================
# PRETTY PRINTING
#==============================================================================

# Checking the availibility and usability of tput. If it is available and
# usable we can set the global coloring variables with it by expecting a
# possibly missing color/modifier.
if dm_tools__tput__is_available
then
  if ! RED="$(dm_tools__tput setaf 1)"
  then
    RED=''
  fi
  if ! GREEN="$(dm_tools__tput setaf 2)"
  then
    GREEN=''
  fi
  if ! BLUE="$(dm_tools__tput setaf 4)"
  then
    BLUE=''
  fi
  if ! RESET="$(dm_tools__tput sgr0)"
  then
    RESET=''
  fi
  if ! BOLD="$(dm_tools__tput bold)"
  then
    BOLD=''
  fi
  if ! DIM="$(dm_tools__tput dim)"
  then
    DIM=''
  fi
else
  RED=''
  GREEN=''
  BLUE=''
  RESET=''
  BOLD=''
  DIM=''
fi

log_task() {
  message="$1"
    dm_tools__echo "${BOLD}[ ${BLUE}..${RESET}${BOLD} ]${RESET} ${message}"
}

log_success() {
  message="$1"
    dm_tools__echo "${BOLD}[ ${GREEN}OK${RESET}${BOLD} ]${RESET} ${message}"
}

log_failure() {
  message="$1"
    dm_tools__echo "${BOLD}[ ${RED}!!${RESET}${BOLD} ]${RESET} ${message}"
}

#==============================================================================
# RESULT VALIDATION
#==============================================================================

assert_test_case_count() {
  ___expected_count="$1"
  ___count="$DM_TEST__RESULT__TEST_CASE_COUNT"

  log_task "expected test case count is ${BOLD}${___expected_count}${RESET}"

  if [ "$___count" -eq "$___expected_count" ]
  then
    log_success "actual count was ${BOLD}${___count}${RESET}"
  else
    log_failure "actual count was: ${BOLD}${___count}${RESET}"

    echo "${BOLD}${RED}"
    echo '==============================================================================='
    echo '                         Unexpected test case count!'
    echo '==============================================================================='
    echo "$RESET"

    exit 1
  fi
}

assert_failure_count() {
  ___expected_count="$1"
  ___count="$DM_TEST__RESULT__FAILURE_COUNT"

  log_task "expected failure count is ${BOLD}${___expected_count}${RESET}"

  if [ "$___count" -eq "$___expected_count" ]
  then
    log_success "actual count was ${BOLD}${___count}${RESET}"
    echo ""
  else
    log_failure "actual count was: ${BOLD}${___count}${RESET}"

    echo "${BOLD}${RED}"
    echo '==============================================================================='
    echo '                          Unexpected failure count!'
    echo '==============================================================================='
    echo "$RESET"

    exit 1
  fi
}

#==============================================================================
# RUNNING TEST SUITES
#==============================================================================

echo "${DIM}==============================================================================="
echo '                              _   _'
echo '      /\                     | | (_)'
echo '     /  \   ___ ___  ___ _ __| |_ _  ___  _ __  ___'
echo '    / /\ \ / __/ __|/ _ \ '\''__| __| |/ _ \| '\''_ \/ __|'
echo '   / ____ \\__ \__ \  __/ |  | |_| | (_) | | | \__ \'
echo '  /_/    \_\___/___/\___|_|   \__|_|\___/|_| |_|___/'
echo ''
echo '==============================================================================='
echo '  ASSERTION SUCCESS CASES'
echo '==============================================================================='
echo "${RESET}"
# Sourcing the sub-suites to be able to access the validation functions without
# sourcing a separate file from them.
. ./run__assert__success.sh

echo "${DIM}==============================================================================="
echo '                              _   _'
echo '      /\                     | | (_)'
echo '     /  \   ___ ___  ___ _ __| |_ _  ___  _ __  ___'
echo '    / /\ \ / __/ __|/ _ \ '\''__| __| |/ _ \| '\''_ \/ __|'
echo '   / ____ \\__ \__ \  __/ |  | |_| | (_) | | | \__ \'
echo '  /_/    \_\___/___/\___|_|   \__|_|\___/|_| |_|___/'
echo ''
echo '==============================================================================='
echo '  ASSERTION FAILURE CASES'
echo '==============================================================================='
echo "${RESET}"
. ./run__assert__failure.sh

echo "${DIM}==============================================================================="
echo '    _____            _'
echo '   / ____|          | |'
echo '  | |     __ _ _ __ | |_ _   _ _ __ ___    ___ __ _ ___  ___  ___'
echo '  | |    / _` | '\''_ \| __| | | | '\''__/ _ \  / __/ _` / __|/ _ \/ __|'
echo '  | |___| (_| | |_) | |_| |_| | | |  __/ | (_| (_| \__ \  __/\__ \'
echo '   \_____\__,_| .__/ \__|\__,_|_|  \___|  \___\__,_|___/\___||___/'
echo '              | |'
echo '==============|_|=============================================================='
echo '  CAPTURE CASES'
echo '==============================================================================='
echo "${RESET}"
. ./run__captures.sh

echo "${DIM}==============================================================================="
echo '   _______        _         _ _               _             _'
echo '  |__   __|      | |       | (_)             | |           (_)'
echo '     | | ___  ___| |_    __| |_ _ __ ___  ___| |_ ___  _ __ _  ___  ___'
echo '     | |/ _ \/ __| __|  / _` | | '\''__/ _ \/ __| __/ _ \| '\''__| |/ _ \/ __|'
echo '     | |  __/\__ \ |_  | (_| | | | |  __/ (__| || (_) | |  | |  __/\__ \'
echo '     |_|\___||___/\__|  \__,_|_|_|  \___|\___|\__\___/|_|  |_|\___||___/'
echo ''
echo '==============================================================================='
echo '  TEST DIRECTORIES CASES'
echo '==============================================================================='
echo "${RESET}"
. ./run__test_directories.sh

echo "${DIM}==============================================================================="
echo '   _____       _                                       _'
echo '  |  __ \     | |                                     | |'
echo '  | |  | | ___| |__  _   _  __ _   _ __ ___   ___   __| | ___'
echo '  | |  | |/ _ \ '\''_ \| | | |/ _` | | '\''_ ` _ \ / _ \ / _` |/ _ \'
echo '  | |__| |  __/ |_) | |_| | (_| | | | | | | | (_) | (_| |  __/'
echo '  |_____/ \___|_.__/ \__,_|\__, | |_| |_| |_|\___/ \__,_|\___|'
echo '                            __/ |'
echo '===========================|___/==============================================='
echo '  DEFAULT DEBUG CASES'
echo '==============================================================================='
echo "${RESET}"
. ./run__debug_mode__default.sh

echo "${DIM}==============================================================================="
echo '   _____          _ _               _           _       _      _'
echo '  |  __ \        | (_)             | |         | |     | |    | |'
echo '  | |__) |___  __| |_ _ __ ___  ___| |_ ___  __| |   __| | ___| |__  _   _  __ _'
echo '  |  _  // _ \/ _` | | '\''__/ _ \/ __| __/ _ \/ _` |  / _` |/ _ \ '\''_ \| | | |/ _` |'
echo '  | | \ \  __/ (_| | | | |  __/ (__| ||  __/ (_| | | (_| |  __/ |_) | |_| | (_| |'
echo '  |_|  \_\___|\__,_|_|_|  \___|\___|\__\___|\__,_|  \__,_|\___|_.__/ \__,_|\__, |'
echo '                                                                            __/ |'
echo '===========================================================================|___/'
echo '  REDIRECTED DEBUG CASES'
echo '==============================================================================='
echo "${RESET}"
. ./run__debug_mode__redirected.sh

echo "${DIM}==============================================================================="
echo '   _    _             _'
echo '  | |  | |           | |'
echo '  | |__| | ___   ___ | | _____'
echo '  |  __  |/ _ \ / _ \| |/ / __|'
echo '  | |  | | (_) | (_) |   <\__ \'
echo '  |_|  |_|\___/ \___/|_|\_\___/'
echo ''
echo '==============================================================================='
echo '  HOOK CASES'
echo '==============================================================================='
echo "${RESET}"
. ./run__hooks.sh

echo "${DIM}==============================================================================="
echo '    _____ _'
echo '   / ____| |'
echo '  | (___ | |_ ___  _ __ ___'
echo '   \___ \| __/ _ \| '\''__/ _ \'
echo '   ____) | || (_) | | |  __/'
echo '  |_____/ \__\___/|_|  \___|'
echo ''
echo '==============================================================================='
echo '  STORE CASES'
echo '==============================================================================='
echo "${RESET}"
. ./run__store.sh

#==============================================================================
# SHELLCHECK VALIDATION
#==============================================================================

run_shellcheck() {
  if command -v shellcheck >/dev/null
  then
    log_task 'running shellcheck..'
    current_path="$(pwd)"
    cd ../src
    # Specifying shell type here to be able to omit the shebangs from the
    # modules.
    # More info: https://github.com/koalaman/shellcheck/wiki/SC2148
    shellcheck --shell=sh -x ./*.sh
    cd "$current_path"
    log_success 'shellcheck finished'
  else
    echo "WARNING: shellcheck won't be executed as it cannot be found."
  fi
}

run_shellcheck

#==============================================================================
# SUMMARY
#==============================================================================

echo "${BOLD}${GREEN}"
echo '==============================================================================='
echo '                      All example test suite executed with'
echo '                    the expected test case and failure count.'
echo '==============================================================================='
echo "$RESET"
