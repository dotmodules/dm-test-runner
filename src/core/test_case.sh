#!/bin/sh
#==============================================================================
#   _______        _      _____
#  |__   __|      | |    / ____|
#     | | ___  ___| |_  | |     __ _ ___  ___
#     | |/ _ \/ __| __| | |    / _` / __|/ _ \
#     | |  __/\__ \ |_  | |___| (_| \__ \  __/
#     |_|\___||___/\__|  \_____\__,_|___/\___|
#
#==============================================================================
# TEST CASES
#==============================================================================

#==============================================================================
# Test case related functionality for executing test cases inside a test file.
#==============================================================================

# Currently executing test file name.
POSIX_TEST__TEST_CASE__RUNTIME__FILE_UNDER_EXECUTION='__INVALID__'
# Currently executing test case name.
POSIX_TEST__TEST_CASE__RUNTIME__TEST_UNDER_EXECUTION='__INVALID__'

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
# Get all test cases from a given test file. Test cases are matched against the
# predefined test case prefix configuration variable.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CONFIG__MANDATORY__TEST_CASE_PREFIX
# Arguments:
#   [1] test_file_path - Path of the given test file the test cases should be
#       collected from.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Test cases matched in the given test file.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
posix_test__test_case__get_test_cases_from_test_file() {
  ___test_file_path="$1"

  ___prefix="$POSIX_TEST__CONFIG__MANDATORY__TEST_CASE_PREFIX"

  posix_test__debug 'posix_test__test_case__get_test_cases_from_test_file' \
    "$( \
      posix_adapter__printf '%s' 'gathering test cases in test file '; \
      posix_adapter__echo "'${___test_file_path}' based on prefix '${___prefix}'" \
    )"

  if ___test_cases="$( \
    posix_adapter__grep --extended --match-only \
      "^${___prefix}[^\(]+" \
      "$___test_file_path" \
  )"
  then
    posix_test__debug_list 'posix_test__test_case__get_test_cases_from_test_file' \
      'test cases found:' \
      "$___test_cases"

    if posix_test__config__should_sort_test_cases
    then

      posix_test__debug 'posix_test__test_case__get_test_cases_from_test_file' \
        'sorting test case list to be able to execute in alphabetical order'

      posix_adapter__echo "$___test_cases" | posix_adapter__sort --dictionary-order
    else
      posix_adapter__echo "$___test_cases"
    fi
  else
    posix_test__debug 'posix_test__test_case__get_test_cases_from_test_file' \
      'no matching test cases were found'
  fi
}

#==============================================================================
# Triggers the execution of the given test cases from a test file.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] test_cases - List of test cases that are present in the test file.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
posix_test__test_case__execute_test_cases() {
  ___test_cases="$1"

  posix_test__debug_list 'posix_test__test_case__execute_test_cases' \
    'executing test cases' \
    "$___test_cases"

  for ___test_case in $___test_cases
  do
    posix_test__cache__init_test_directory__test_case_level
    _posix_test__execute_test_case "$___test_case"
  done

  posix_test__debug 'posix_test__test_case__execute_test_cases' \
    'test cases were executed'
}

#==============================================================================
# Setting the current test file path into a global variable that can be accessed
# later on. It removes the first dot from the path that is relative to the test
# runner script.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__TEST_CASE__RUNTIME__FILE_UNDER_EXECUTION
# Arguments:
#   [1] test_file_path - Name of the currently executing test file.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   POSIX_TEST__TEST_CASE__RUNTIME__FILE_UNDER_EXECUTION
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
posix_test__test_case__set_current_test_file() {
  ___test_file_path="$1"

  POSIX_TEST__TEST_CASE__RUNTIME__FILE_UNDER_EXECUTION="$( \
    posix_adapter__echo "$___test_file_path" | \
    posix_adapter__cut --delimiter '/' --fields '2-' \
  )"

  posix_test__debug 'posix_test__test_case__set_current_test_file' \
    "current test file: '${POSIX_TEST__TEST_CASE__RUNTIME__FILE_UNDER_EXECUTION}'"
}

#==============================================================================
# Setting the current test case name into a global variable that can be accessed
# later on.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__TEST_CASE__RUNTIME__TEST_UNDER_EXECUTION
# Arguments:
#   [1] test_case - Name of the test case function that should be executed.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   POSIX_TEST__TEST_CASE__RUNTIME__TEST_UNDER_EXECUTION
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
posix_test__test_case__set_current_test_case() {
  ___test_case="$1"

  POSIX_TEST__TEST_CASE__RUNTIME__TEST_UNDER_EXECUTION="$___test_case"

  posix_test__debug 'posix_test__test_case__set_current_test_case' \
    "current test case: '${POSIX_TEST__TEST_CASE__RUNTIME__TEST_UNDER_EXECUTION}'"
}

#==============================================================================
# Prints out the currently executing test case identifier which is the test
# file name followed by the test case function name. This will be used during
# the execution to print out the name of the currently executing test and also
# it will be used during assertion error reporting.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__TEST_CASE__RUNTIME__FILE_UNDER_EXECUTION
#   POSIX_TEST__TEST_CASE__RUNTIME__TEST_UNDER_EXECUTION
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Currently executing test case identifier.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
posix_test__test_case__get_current_test_case_identifier() {
  posix_adapter__printf '%s' "$POSIX_TEST__TEST_CASE__RUNTIME__FILE_UNDER_EXECUTION"
  posix_adapter__printf '%s' ' - '
  posix_adapter__echo "$POSIX_TEST__TEST_CASE__RUNTIME__TEST_UNDER_EXECUTION"
}

#==============================================================================
# Prints out the colorized test identifier.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__TEST_CASE__RUNTIME__FILE_UNDER_EXECUTION
#   POSIX_TEST__TEST_CASE__RUNTIME__TEST_UNDER_EXECUTION
#   BOLD
#   RESET
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Currently executing test case identifier.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
posix_test__test_case__get_current_colorized_test_case_identifier() {
  posix_adapter__printf '%s' "${RESET}"
  posix_adapter__printf '%s' "${POSIX_TEST__TEST_CASE__RUNTIME__FILE_UNDER_EXECUTION}"
  posix_adapter__printf '%s' ' - '
  posix_adapter__printf '%s' "${BOLD}"
  posix_adapter__echo "${POSIX_TEST__TEST_CASE__RUNTIME__TEST_UNDER_EXECUTION}${RESET}"
}

#==============================================================================
#  ____       _            _         _          _
# |  _ \ _ __(_)_   ____ _| |_ ___  | |__   ___| |_ __   ___ _ __ ___
# | |_) | '__| \ \ / / _` | __/ _ \ | '_ \ / _ \ | '_ \ / _ \ '__/ __|
# |  __/| |  | |\ V / (_| | ||  __/ | | | |  __/ | |_) |  __/ |  \__ \
# |_|   |_|  |_| \_/ \__,_|\__\___| |_| |_|\___|_| .__/ \___|_|  |___/
#================================================|_|===========================
# PRIVATE HELPERS
#==============================================================================

#==============================================================================
# Execution of the given test case in the currently executing test file. This
# function is responsible for providing the necessary global environment
# variables for the assertion functions used in the test case. After the
# execution the test case is printed to the output and the optional captured
# output also.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] test_case - Name of the test case function that should be executed.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Test case identifier and its optional output.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected. Failing test case is handled.
#==============================================================================
_posix_test__execute_test_case() {
  ___test_case="$1"

  posix_test__debug '_posix_test__execute_test_case' \
    ">>> executing test case '${___test_case}'"

  posix_test__test_case__set_current_test_case "$___test_case"
  posix_test__cache__test_result__init
  _posix_test__print_test_case_identifier

  if _posix_test__run_test_case "$___test_case"
  then
    if posix_test__config__should_display_captured_outputs_on_success
    then
      ___output="$(posix_test__capture__get_captured_outputs)"
    else
      ___output=''
    fi
  else
    ___output="$(posix_test__capture__get_captured_outputs)"
  fi

  _posix_test__print_test_case_result
  _posix_test__update_global_counters

  posix_test__utils__print_output_if_has_content "$___output"
}

#==============================================================================
# Function that executes the given test case defined in the global execution
# environment. It executes the test case in a separate subshell to provide each
# test case a unique sandboxing environment.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] test_case - Name of the executable test case that is already sourced to
#       the environment ready to be called.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Combined stdout, stderr and fd3 output if the test case failed.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_posix_test__run_test_case() {
  ___test_case="$1"

  posix_test__debug '_posix_test__run_test_case' \
    "preparing to run test case '${___test_case}'"

  # Capture system initialization has to be done in the subshell level where
  # the evaluation will be happen because of the global runtime variables it
  # uses internally would be lost if they were created in a subshell.
  posix_test__capture__init

  # Running in a subshell to be able to exit from the test case execution any
  # time. This is most probably will happen due to an error during the setup
  # hook execution.
  if ( _posix_test__run_test_case_in_a_subshell "${___test_case}" )
  then
    ___status="$?"
  else
    ___status="$?"
  fi

  posix_test__debug '_posix_test__run_test_case' \
    "test case execution finished with status '${___status}'"

  if _posix_test__evaluate_test_case_result "$___status"
  then
    posix_test__debug '_posix_test__run_test_case' \
      'test case succeeded'

  else
    posix_test__cache__test_result__mark_as_failed
    return 1
  fi
}

#==============================================================================
# Evaluates the test case result based on the passed status and the error
# output of the test case.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] status - Status of the test case execution.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Merged and sorted output of the failed test case. If the test case succeeds
#   there won't be any output.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_posix_test__evaluate_test_case_result() {
  ___status="$1"

  posix_test__debug '_posix_test__evaluate_test_case_result' \
    'evaluating test case result..'

  # If the status is nonzero or there is any standard error content, the
  # test case is considered as failed.

  if [ "$___status" -ne '0' ]
  then
    posix_test__debug '_posix_test__evaluate_test_case_result' \
      '[!] status was nonzero => test case failed'
    ___result=1

  elif posix_test__capture__was_standard_error_captured
  then
    posix_test__debug '_posix_test__evaluate_test_case_result' \
      '[!] there were standard error output => test case failed'
    posix_test__capture__append_to_standard_error \
      'standard error output present => test case failed automatically'
    ___result=1

  else
    posix_test__debug '_posix_test__evaluate_test_case_result' \
      '[ok] zero status + no standard error output => test case succeeded'
    ___result=0
  fi

  return "$___result"
}

#==============================================================================
# Runs the test case in a subshell to not to poison the execution environment
# for the next test cases and to be able to exit the execution from the
# internal helper functions if needed.
#
# It runs the setup and teardown hook before and after the test case. The test
# case result is considered as a success if both three statuses executed without
# an error.
#
# The actual test case execution will happen in another subshell in order to be
# able abort it's execution in case of a failed assertion and have the teardown
# hook to run. Without this extra subshell, the teardown hook couldn't be run
# if the test case exits from execution. This subshell also has a drawback: the
# teardown hook only can access the environment the setup hook is created. It
# has no access to the test case environment changes. Most of the use cases
# won't need that access.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] test_case - Test case that needs to be executed in a subshell.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Test case execution succeeded.
#   1 - Test case execution failed.
#==============================================================================
_posix_test__run_test_case_in_a_subshell() {
  ___test_case="$1"

  posix_test__debug '_posix_test__run_test_case_in_a_subshell' \
    '-------------------< test case level subshell start >-------------------'

  # Statuses will be captured into output variables:
  #  ___status__setup
  #  ___status__test_case
  #  ___status__teardown
  # This has to be done in this way, because variables created in the setup
  # hook needs to be accessed from the test case, and the regular function
  # execution in a captured subshell would prevent it.
  _posix_test__execute_and_capture__setup_hook
  _posix_test__execute_and_capture__test_case "$___test_case"
  _posix_test__execute_and_capture__teardown_hook

  # Result evaluation
  if [ "$___status__setup" -eq '0' ] \
       && [ "$___status__test_case" -eq '0' ] \
       && [ "$___status__teardown" -eq '0' ]
  then
    ___exit_status='0'
  else
    ___exit_status='1'
  fi

  posix_test__debug '_posix_test__run_test_case_in_a_subshell' \
    '-------------------< test case level subshell stop >-------------------'

  exit "$___exit_status"
}

#==============================================================================
# Optionally runs the setup hook while captures the outputs with the capture
# system. If the setup hook fails to run, exists the test case execution. The
# status is returned in an output variable.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CAPTURE__CONSTANT__EXECUTE_COMMAND_DIRECTLY
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   ___status__setup
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_posix_test__execute_and_capture__setup_hook() {
  if posix_test__hooks__is_hook_available__setup
  then
    posix_test__debug '_posix_test__execute_and_capture__setup_hook' \
      'running setup hook'

    # Running the setup hook triggering directly in this shell to be able to
    # affect the environment.
    if posix_test__capture__run_and_capture \
      "$POSIX_TEST__CAPTURE__CONSTANT__EXECUTE_COMMAND_DIRECTLY" \
      'posix_test__hooks__trigger_hook__setup'
    then
      ___status__setup="$?"
    else
      ___status__setup="$?"

      posix_test__debug '_posix_test__execute_and_capture__setup_hook' \
        '[!] setup hook failed, no point to execute test case, exiting..'

      exit "$___status__setup"
    fi
  else
    ___status__setup='0'
  fi

  posix_test__debug '_posix_test__execute_and_capture__setup_hook' \
    "setup hook status: ${___status__setup}"
}

#==============================================================================
# Runs the given test case while capturing its outputs.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CAPTURE__CONSTANT__EXECUTE_COMMAND_IN_SUBSHELL
#   POSIX_TEST__CACHE__RUNTIME__TEST_DIR__TEST_SUITE
#   POSIX_TEST__CACHE__RUNTIME__TEST_DIR__TEST_FILE
#   POSIX_TEST__CACHE__RUNTIME__TEST_DIR__TEST_CASE
# Arguments:
#   [1] test_case - Test case that needs to be run.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   ___status__test_case
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_posix_test__execute_and_capture__test_case() {
  ___test_case="$1"

  posix_test__debug '_posix_test__execute_and_capture__test_case' \
    'running test case function in a separate subshell'

  # Gathering the test directories that will be injected into the test case
  # functions as positional parameters!
  ___dir_suite="$POSIX_TEST__CACHE__RUNTIME__TEST_DIR__TEST_SUITE"
  ___dir_file="$POSIX_TEST__CACHE__RUNTIME__TEST_DIR__TEST_FILE"
  ___dir_case="$POSIX_TEST__CACHE__RUNTIME__TEST_DIR__TEST_CASE"

  # Running the test case function in an additional subshell to make the exit
  # call due to a failed assertion isolated from the currently executing shell
  # to be able to finish capturing all of the outputs.
  if posix_test__capture__run_and_capture \
    "$POSIX_TEST__CAPTURE__CONSTANT__EXECUTE_COMMAND_IN_SUBSHELL" \
    "$___test_case" "${___dir_suite}" "${___dir_file}" "${___dir_case}"
  then
    ___status__test_case="$?"
  else
    ___status__test_case="$?"
  fi

  posix_test__debug '_posix_test__execute_and_capture__test_case' \
    "test case status: ${___status__test_case}"
}

#==============================================================================
# Optionally runs the setup hook while captures the outputs with the capture
# system. The status is returned in an output variable.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CAPTURE__CONSTANT__EXECUTE_COMMAND_DIRECTLY
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   ___status__teardown
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_posix_test__execute_and_capture__teardown_hook() {
  if posix_test__hooks__is_hook_available__teardown
  then
    posix_test__debug '_posix_test__execute_and_capture__teardown_hook' \
      'running teardown hook'

    # Running the teardown hook triggering directly in this shell to be able to
    # affect the environment.
    if posix_test__capture__run_and_capture \
      "$POSIX_TEST__CAPTURE__CONSTANT__EXECUTE_COMMAND_DIRECTLY" \
      'posix_test__hooks__trigger_hook__teardown'
    then
      ___status__teardown="$?"
    else
      ___status__teardown="$?"
    fi
  else
    ___status__teardown='0'
  fi

  posix_test__debug '_posix_test__execute_and_capture__teardown_hook' \
    "teardown hook status: ${___status__teardown}"
}

#==============================================================================
# Printing out the about to be executed test case identifier without a newline
# in normal execution but with a newline in case of debug mode to have a better
# debug output.
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
#   Identifier of the executable test case.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_posix_test__print_test_case_identifier() {
  posix_test__debug '_posix_test__print_test_case_identifier' \
    'displaying test case identifier..'

  ___identifier="$( \
    posix_test__test_case__get_current_colorized_test_case_identifier \
  )"

  if posix_test__config__debug_is_enabled
  then
    posix_adapter__echo "$___identifier"
  else
    posix_adapter__printf '%s' "$___identifier"
  fi
}

#==============================================================================
# Print out the result of the test case with some front padding.
#------------------------------------------------------------------------------
# Globals:
# - GREEN
# - RED
# - BOLD
# - RESET
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Result of the test case.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_posix_test__print_test_case_result() {
  posix_test__debug '_posix_test__print_test_case_result' \
    'printing test case result..'

  if posix_test__cache__test_result__was_success
  then
    posix_adapter__echo "  ${BOLD}${GREEN}ok${RESET}"
  else
    posix_adapter__echo "  ${BOLD}${RED}NOT OK${RESET}"
  fi
}

#==============================================================================
# Increase the global counters according to the test case result.
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
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_posix_test__update_global_counters() {
  posix_test__debug '_posix_test__update_global_counters' \
    'updating global counters..'

  posix_test__cache__global_count__increment

  posix_test__debug '_posix_test__update_global_counters' \
    'incrementing global failure count if test case failed..'
  if ! posix_test__cache__test_result__was_success
  then
    posix_test__cache__global_failure__increment
  fi
}
