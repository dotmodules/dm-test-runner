#!/bin/sh

# This file was intended to be sourced into every test runner.
# Expressions don't expand inside single quotes.
# shellcheck disable=SC2016
# Single quote escapement.
# shellcheck disable=SC1003
# Single quote escapement.
# shellcheck disable=SC2034

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
  RED="$(dm_tools__tput setaf 1)"
  GREEN="$(dm_tools__tput setaf 2)"
  BLUE="$(dm_tools__tput setaf 4)"
  RESET="$(dm_tools__tput sgr0)"
  BOLD="$(dm_tools__tput bold)"
  DIM="$(dm_tools__tput dim)"
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

    dm_tools__echo "${BOLD}${RED}"
    dm_tools__echo '==============================================================================='
    dm_tools__echo '                         Unexpected test case count!'
    dm_tools__echo '==============================================================================='
    dm_tools__echo "$RESET"

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
    dm_tools__echo ""
  else
    log_failure "actual count was: ${BOLD}${___count}${RESET}"

    dm_tools__echo "${BOLD}${RED}"
    dm_tools__echo '==============================================================================='
    dm_tools__echo '                          Unexpected failure count!'
    dm_tools__echo '==============================================================================='
    dm_tools__echo "$RESET"

    exit 1
  fi
}
