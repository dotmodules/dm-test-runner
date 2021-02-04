#!/bin/sh

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
# PRETTY PRINTING
#==============================================================================

# Checking the availibility and usability of tput. If it is available and
# usable we can set the global coloring variables with it.
if command -v tput >/dev/null && tput init >/dev/null 2>&1
then
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  BLUE="$(tput setaf 4)"
  RESET="$(tput sgr0)"
  BOLD="$(tput bold)"
  DIM="$(tput dim)"
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
    echo "${BOLD}[ ${BLUE}>>${RESET}${BOLD} ]${RESET} ${message}"
}

log_success() {
  message="$1"
    echo "${BOLD}[ ${GREEN}OK${RESET}${BOLD} ]${RESET} ${message}"
}

log_failure() {
  message="$1"
    echo "${BOLD}[ ${RED}!!${RESET}${BOLD} ]${RESET} ${message}"
}

#==============================================================================
# RESULT VALIDATION
#==============================================================================

assert_test_case_count() {
  ___expected_count="$1"
  ___count="$DM_TEST__RESULT__TEST_CASE_COUNT"

  _assert_count \
    "$___expected_count" \
    "$___count" \
    'Unexpected test case count!'
}

assert_failure_count() {
  ___expected_count="$1"
  ___count="$DM_TEST__RESULT__FAILURE_COUNT"

  _assert_count \
    "$___expected_count" \
    "$___count" \
    'Unexpected failure count!'
}

_assert_count() {
  ___expected_count="$1"
  ___count="$2"
  ___message="$3"

  if [ "$___count" -ne "$___expected_count" ]
  then
    echo "${BOLD}${RED}"
    echo '==============================================================================='
    echo "  ERROR: ${___message}"
    echo "    expected count: ${___expected_count}"
    echo "    actual count:   ${___count}"
    echo '==============================================================================='
    echo "$RESET"
    exit 1
  fi
}

#==============================================================================
# RUNNING THE TEST SUITES
#==============================================================================

echo "${DIM}==============================================================================="
echo '   _   _                            _'
echo '  | \ | |                          | |'
echo '  |  \| | ___  _ __ _ __ ___   __ _| |   ___ __ _ ___  ___  ___'
# shellcheck disable=SC2016
echo '  | . ` |/ _ \| '\''__| '\''_ ` _ \ / _` | |  / __/ _` / __|/ _ \/ __|'
# shellcheck disable=SC1003
echo '  | |\  | (_) | |  | | | | | | (_| | | | (_| (_| \__ \  __/\__ \'
echo '  |_| \_|\___/|_|  |_| |_| |_|\__,_|_|  \___\__,_|___/\___||___/'
echo "${RESET}"

# Sourcing the sub-suites to be able to access the validation functions without
# sourcing a separate file from them.
. ./run_basic.sh

echo "${DIM}==============================================================================="
echo '   ______    _ _'
echo '  |  ____|  (_) |'
echo '  | |__ __ _ _| |_   _ _ __ ___    ___ __ _ ___  ___  ___'
echo '  |  __/ _` | | | | | | '\''__/ _ \  / __/ _` / __|/ _ \/ __|'
# shellcheck disable=SC1003
echo '  | | | (_| | | | |_| | | |  __/ | (_| (_| \__ \  __/\__ \'
echo '  |_|  \__,_|_|_|\__,_|_|  \___|  \___\__,_|___/\___||___/'
echo "${RESET}"

. ./run_failures.sh

echo "${DIM}==============================================================================="
echo '    _____            _'
echo '   / ____|          | |'
echo '  | |     __ _ _ __ | |_ _   _ _ __ ___    ___ __ _ ___  ___  ___'
echo '  | |    / _` | '\''_ \| __| | | | '\''__/ _ \  / __/ _` / __|/ _ \/ __|'
# shellcheck disable=SC1003
echo '  | |___| (_| | |_) | |_| |_| | | |  __/ | (_| (_| \__ \  __/\__ \'
echo '   \_____\__,_| .__/ \__|\__,_|_|  \___|  \___\__,_|___/\___||___/'
echo '              | |'
echo "              |_|${RESET}"

. ./run_captures.sh

echo "${DIM}==============================================================================="
echo '   _______        _         _ _               _             _'
echo '  |__   __|      | |       | (_)             | |           (_)'
echo '     | | ___  ___| |_    __| |_ _ __ ___  ___| |_ ___  _ __ _  ___  ___'
echo '     | |/ _ \/ __| __|  / _` | | '\''__/ _ \/ __| __/ _ \| '\''__| |/ _ \/ __|'
# shellcheck disable=SC1003
echo '     | |  __/\__ \ |_  | (_| | | | |  __/ (__| || (_) | |  | |  __/\__ \'
echo '     |_|\___||___/\__|  \__,_|_|_|  \___|\___|\__\___/|_|  |_|\___||___/'
echo "${RESET}"

. ./run_test_directories.sh

echo "${DIM}==============================================================================="
echo '   _____       _                                       _'
echo '  |  __ \     | |                                     | |'
echo '  | |  | | ___| |__  _   _  __ _   _ __ ___   ___   __| | ___'
# shellcheck disable=SC1003,SC2016
echo '  | |  | |/ _ \ '\''_ \| | | |/ _` | | '\''_ ` _ \ / _ \ / _` |/ _ \'
echo '  | |__| |  __/ |_) | |_| | (_| | | | | | | | (_) | (_| |  __/'
echo '  |_____/ \___|_.__/ \__,_|\__, | |_| |_| |_|\___/ \__,_|\___|'
echo '                            __/ |'
echo "                           |___/${RESET}"

. ./run_debug_mode.sh

echo "${DIM}==============================================================================="
echo '   _____          _ _               _           _       _      _'
echo '  |  __ \        | (_)             | |         | |     | |    | |'
echo '  | |__) |___  __| |_ _ __ ___  ___| |_ ___  __| |   __| | ___| |__  _   _  __ _'
# shellcheck disable=SC1003,SC2016
echo '  |  _  // _ \/ _` | | '\''__/ _ \/ __| __/ _ \/ _` |  / _` |/ _ \ '\''_ \| | | |/ _` |'
echo '  | | \ \  __/ (_| | | | |  __/ (__| ||  __/ (_| | | (_| |  __/ |_) | |_| | (_| |'
echo '  |_|  \_\___|\__,_|_|_|  \___|\___|\__\___|\__,_|  \__,_|\___|_.__/ \__,_|\__, |'
echo '                                                                            __/ |'
echo "                                                                           |___/${RESET}"

. ./run_debug_mode_redirected.sh

echo "${DIM}==============================================================================="
echo '   _    _             _'
echo '  | |  | |           | |'
echo '  | |__| | ___   ___ | | _____'
echo '  |  __  |/ _ \ / _ \| |/ / __|'
# shellcheck disable=SC1003
echo '  | |  | | (_) | (_) |   <\__ \'
echo '  |_|  |_|\___/ \___/|_|\_\___/'
echo "${RESET}"

. ./run_test_hooks.sh

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
