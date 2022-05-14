#!/bin/sh

# This file was intended to be sourced into every test runner.
# Expressions don't expand inside single quotes.
# shellcheck disable=SC2016
# Single quote escapement.
# shellcheck disable=SC1003
# Single quote escapement.
# shellcheck disable=SC2034

#==============================================================================
# POSIX_ADAPTER INTEGRATION
#==============================================================================

if [ -z ${POSIX_ADAPTER__READY+x} ]
then
  # If posix_adapter has not sourced yet, we have to source it from this repository.
  POSIX_ADAPTER__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX='../dependencies/posix-adapter'
  if [ -d  "$POSIX_ADAPTER__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX" ]
  then
    # shellcheck source=../dependencies/posix-adapter/posix_adapter.sh
    . "${POSIX_ADAPTER__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX}/posix_adapter.sh"
  else
    echo 'posix_adapter submodule needs to be initialized. run make init'
    exit
  fi
fi

# IMPORTANT: After this, every non shell built-in command should be called
# through the provided posix_adapter API to ensure the compatibility on different
# environments.

#==============================================================================
# PRETTY PRINTING
#==============================================================================

# Checking the availibility and usability of tput. If it is available and
# usable we can set the global coloring variables with it by expecting a
# possibly missing color/modifier.
if posix_adapter__tput --is-available
then
  RED="$(posix_adapter__tput setaf 1)"
  GREEN="$(posix_adapter__tput setaf 2)"
  BLUE="$(posix_adapter__tput setaf 4)"
  RESET="$(posix_adapter__tput sgr0)"
  BOLD="$(posix_adapter__tput bold)"
  DIM="$(posix_adapter__tput dim)"
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
    echo "${BOLD}[ ${BLUE}..${RESET}${BOLD} ]${RESET} ${message}"
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
  ___count="$POSIX_TEST__RESULT__TEST_CASE_COUNT"

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
  ___count="$POSIX_TEST__RESULT__FAILURE_COUNT"

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
