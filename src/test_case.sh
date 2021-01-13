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
DM_TEST__TEST_CASE__RUNTIME__FILE_UNDER_EXECUTION='__INVALID__'
# Currently executing test case name.
DM_TEST__TEST_CASE__RUNTIME__TEST_UNDER_EXECUTION='__INVALID__'

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
#   DM_TEST__CONFIG__MANDATORY__TEST_CASE_PREFIX
# Arguments:
#   [1] test_file_path - Path of the given test file the test cases should be
#       collected from.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Test files matched in the given test file.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#------------------------------------------------------------------------------
# Tools:
#   grep echo printf test
#==============================================================================
dm_test__test_case__get_test_cases_from_test_file() {
  ___test_file_path="$1"

  ___prefix="$DM_TEST__CONFIG__MANDATORY__TEST_CASE_PREFIX"

  dm_test__debug 'dm_test__test_case__get_test_cases_from_test_file' \
    "$( \
      printf '%s' 'gathering test cases in test file '; \
      echo "'${___test_file_path}' based on prefix '${___prefix}'.." \
    )"

  if ___test_cases="$( \
    grep -E --only-matching \
      "^${___prefix}[^\(]+" \
      "$___test_file_path" \
  )"
  then
    dm_test__debug_list 'dm_test__test_case__get_test_cases_from_test_file' \
      'test cases found:' \
      "$___test_cases"

    if dm_test__config__should_sort_test_cases
    then

      dm_test__debug 'dm_test__test_case__get_test_cases_from_test_file' \
        'sorting test case list to be able to execute in alphabetical order'

      echo "$___test_cases" | sort --dictionary-order
    else
      echo "$___test_cases"
    fi
  else
    dm_test__debug 'dm_test__test_case__get_test_cases_from_test_file' \
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
#   Test files matched in the given test file.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#------------------------------------------------------------------------------
# Tools:
#   None
#==============================================================================
dm_test__test_case__execute_test_cases() {
  ___test_cases="$1"

  dm_test__debug_list 'dm_test__test_case__execute_test_cases' \
    'executing test cases' \
    "$___test_cases"

  for ___test_case in $___test_cases
  do
    dm_test__cache__init_test_directory__test_case_level
    _dm_test__execute_test_case "$___test_case"
  done

  dm_test__debug 'dm_test__test_case__execute_test_cases' \
    'test cases were executed'
}

#==============================================================================
# Setting the current test file name into a global variable that can be
# accessed later on. Only stores the filename, the extension will be ignored,
# It expects that the filename has this pattern: '<filename>.<extension>'. If
# there is a period in the filename, then the filename will be only the part
# before the first period.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__TEST_CASE__RUNTIME__FILE_UNDER_EXECUTION
# Arguments:
#   [1] test_file_path - Name of the currently executing test file.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__TEST_CASE__RUNTIME__FILE_UNDER_EXECUTION
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#------------------------------------------------------------------------------
# Tools:
#   basename cut
#==============================================================================
dm_test__test_case__set_current_test_file() {
  ___test_file_path="$1"

  DM_TEST__TEST_CASE__RUNTIME__FILE_UNDER_EXECUTION="$( \
    basename "$___test_file_path" | cut -d '.' -f 1 \
  )"

  dm_test__debug 'dm_test__test_case__set_current_test_file' \
    "current test file: '${DM_TEST__TEST_CASE__RUNTIME__FILE_UNDER_EXECUTION}'"
}

#==============================================================================
# Setting the current test case name into a global variable that can be
# accessed later on.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__TEST_CASE__RUNTIME__TEST_UNDER_EXECUTION
# Arguments:
#   [1] test_case - Name of the test case function that should be executed.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__TEST_CASE__RUNTIME__TEST_UNDER_EXECUTION
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#------------------------------------------------------------------------------
# Tools:
#   None
#==============================================================================
dm_test__test_case__set_current_test_case() {
  ___test_case="$1"

  DM_TEST__TEST_CASE__RUNTIME__TEST_UNDER_EXECUTION="$___test_case"

  dm_test__debug 'dm_test__test_case__set_current_test_case' \
    "current test case: '${DM_TEST__TEST_CASE__RUNTIME__TEST_UNDER_EXECUTION}'"
}

#==============================================================================
# Prints out the currently executing test case identifier which is the test
# file name followed by the test case function name. This will be used during
# the execution to print out the name of the currently executing test and also
# it will be used during assertion error reporting.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__TEST_CASE__RUNTIME__FILE_UNDER_EXECUTION
#   DM_TEST__TEST_CASE__RUNTIME__TEST_UNDER_EXECUTION
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
#------------------------------------------------------------------------------
# Tools:
#   echo printf
#==============================================================================
dm_test__test_case__get_current_test_case_identifier() {
  printf '%s' "$DM_TEST__TEST_CASE__RUNTIME__FILE_UNDER_EXECUTION"
  printf '%s' '.'
  echo "$DM_TEST__TEST_CASE__RUNTIME__TEST_UNDER_EXECUTION"
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
#------------------------------------------------------------------------------
# Tools:
#   None
#==============================================================================
_dm_test__execute_test_case() {
  ___test_case="$1"

  dm_test__debug '_dm_test__execute_test_case' \
    ">>> executing test case '${___test_case}'"

  dm_test__test_case__set_current_test_case "$___test_case"
  dm_test__cache__test_result__init
  _dm_test__print_test_case_identifier

  ___output="$( \
    _dm_test__run_test_case \
      "$___test_case"
  )"

  _dm_test__print_test_case_result
  _dm_test__update_global_counters
  dm_test__utils__print_output_if_has_content "$___output"
}

#==============================================================================
# Function that executes the given test case defined in the global execution
# environment. It executes the testcase in a separate subshell to provide each
# test case a unique sandboxing environment.
#------------------------------------------------------------------------------
# Globals:
#   BLUE
#   RED
#   DIM
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
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
_dm_test__run_test_case() {
  ___test_case="$1"

  dm_test__debug '_dm_test__run_test_case' \
    "preparing to run test case '${___test_case}'"

  # Capture system initialization has to be done in the subshell level where
  # the evaluation will be happen because of the global runtime variables it
  # uses internally would be lost if they were created in a subshell.
  dm_test__capture__init

  if ( _dm_test__run_test_case_in_a_subshell "$___test_case" )
  then
    ___status="$?"
  else
    ___status="$?"
  fi

  dm_test__debug '_dm_test__run_test_case' \
    "test case execution finished with status '${___status}'"

  _dm_test__evaluate_test_case_result "$___status"
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
#------------------------------------------------------------------------------
# Tools:
#   echo test
#==============================================================================
_dm_test__evaluate_test_case_result() {
  ___status="$1"

  dm_test__debug '_dm_test__evaluate_test_case_result' \
    'evaluating test case result..'

  # If the status is nonzero or there is any standard error content, the
  # testcase is considered as failed.
  if [ "$___status" -ne '0' ]
  then
    dm_test__debug '_dm_test__evaluate_test_case_result' \
      '[!] status was nonzero => test case failed'
    ___result=1
  elif dm_test__capture__was_standard_error_captured
  then
    dm_test__debug '_dm_test__evaluate_test_case_result' \
      '[!] there were standard error output => test case failed'
    dm_test__capture__append_to_standard_error \
      "standard error output present => test case failed automatically"
    ___result=1
  else
    dm_test__debug '_dm_test__evaluate_test_case_result' \
      '[ok] zero status + no standard error output => test case succeeded'
    ___result=0
  fi

  # Displaying the captured outputs on failure.
  if [ "$___result" -ne '0' ]
  then
    dm_test__cache__test_result__mark_as_failed

    ___output="$(dm_test__capture__get_captured_outputs)"

    dm_test__debug '_dm_test__evaluate_test_case_result' \
      'outputs prepared to display'

    echo "$___output"
  fi
}

#==============================================================================
# Runs the test case in a subshell to not to poison the execution environment
# for the next test cases and to be able to exit the execution from the
# internal helper functions if needed.
#
# It runs the setup and teardown hook before and after the test case. The test
# case result is considered as a success if both three status executed without
# an error.
#
# The actual test case execution will happen in another subshell in order to be
# able abort it's execution in case of a failed assertion and have the teardown
# hook to run. Withouth this extra subshell, the teardown hook couldn't be run
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
#   0 - Test case exectution succeeded.
#   1 - Test case exectution failed.
#------------------------------------------------------------------------------
# Tools:
#   test exit
#==============================================================================
_dm_test__run_test_case_in_a_subshell() {
  ___test_case="$1"

  dm_test__debug '_dm_test__run_test_case_in_a_subshell' \
    '-------------------< test case level subshell start >-------------------'

  # Statuses will be captured into output variables:
  #  ___status__setup
  #  ___status__test_case
  #  ___status__teardown
  # This has to be done in this way, because variables created in the setup
  # hook needs to be accessed from the test case, and the regular function
  # exection in a captured subshell would prevent it.
  _dm_test__execute_and_capture__setup_hook
  _dm_test__execute_and_capture__test_case "$___test_case"
  _dm_test__execute_and_capture__teardown_hook

  # Result evaluation
  if [ "$___status__setup" -eq '0' ] \
       && [ "$___status__test_case" -eq '0' ] \
       && [ "$___status__teardown" -eq '0' ]
  then
    ___exit_status='0'
  else
    ___exit_status='1'
  fi

  dm_test__debug '_dm_test__run_test_case_in_a_subshell' \
    '-------------------< test case level subshell stop >-------------------'

  exit "$___exit_status"
}

#==============================================================================
# Optionally runs the setup hook while captures the outputs with the capture
# system. If the setup hook fails to run, exists the test case execution. The
# status is returned in an output variable.
#------------------------------------------------------------------------------
# Globals:
#   None
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
#------------------------------------------------------------------------------
# Tools:
#   test exit
#==============================================================================
_dm_test__execute_and_capture__setup_hook() {
  if dm_test__hooks__is_hook_available__setup
  then
    dm_test__debug '_dm_test__execute_and_capture__setup_hook' \
      'running setup hook'

    if dm_test__capture__run_and_capture 'dm_test__hooks__trigger_hook__setup'
    then
      ___status__setup="$?"
    else
      ___status__setup="$?"

      dm_test__debug '_dm_test__execute_and_capture__setup_hook' \
        '[!] setup hook failed, no point to execute test case, exiting..'

      exit "$___status__setup"
    fi
  else
    ___status__setup='0'
  fi

  dm_test__debug '_dm_test__execute_and_capture__setup_hook' \
    "setup hook status: ${___status__setup}"
}

#==============================================================================
# Runs the given test case while capturing its outputs.
#------------------------------------------------------------------------------
# Globals:
#   None
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
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
_dm_test__execute_and_capture__test_case() {
  ___test_case="$1"

  dm_test__debug '_dm_test__execute_and_capture__test_case' \
    'running test case function in a separate subshell'

  if ( dm_test__capture__run_and_capture "$___test_case" )
  then
    ___status__test_case="$?"
  else
    ___status__test_case="$?"
  fi

  dm_test__debug '_dm_test__execute_and_capture__test_case' \
    "test case status: ${___status__test_case}"
}

#==============================================================================
# Optionally runs the setup hook while captures the outputs with the capture
# system. The status is returned in an output variable.
#------------------------------------------------------------------------------
# Globals:
#   None
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
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
_dm_test__execute_and_capture__teardown_hook() {
  if dm_test__hooks__is_hook_available__teardown
  then
    dm_test__debug '_dm_test__execute_and_capture__teardown_hook' \
      'running teardown hook'

    if dm_test__capture__run_and_capture \
      'dm_test__hooks__trigger_hook__teardown'
    then
      ___status__teardown="$?"
    else
      ___status__teardown="$?"
    fi
  else
    ___status__teardown='0'
  fi

  dm_test__debug '_dm_test__execute_and_capture__teardown_hook' \
    "teardown hook status: ${___status__teardown}"
}

#==============================================================================
# Printing out the about to be executed test case identifier without a newline
# in normal execution but with a newline in case of debug mode to have a better
# debug output.
#------------------------------------------------------------------------------
# Globals:
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
#   Identifier of the executable test case.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#------------------------------------------------------------------------------
# Tools:
#   echo test printf
#==============================================================================
_dm_test__print_test_case_identifier() {
  dm_test__debug '_dm_test__print_test_case_identifier' \
    'displaying test case identifier..'

  ___identifier="$(dm_test__test_case__get_current_test_case_identifier)"
  ___identifier="${BOLD}${___identifier}${RESET}"

  if dm_test__config__debug_is_enabled
  then
    echo "$___identifier"
  else
    printf '%s' "$___identifier"
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
#------------------------------------------------------------------------------
# Tools:
#   echo test
#==============================================================================
_dm_test__print_test_case_result() {
  dm_test__debug '_dm_test__print_test_case_result' \
    'printing test case result..'

  if dm_test__cache__test_result__was_success
  then
    echo "  ${BOLD}${GREEN}ok${RESET}"
  else
    echo "  ${BOLD}${RED}NOT OK${RESET}"
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
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
_dm_test__update_global_counters() {
  dm_test__debug '_dm_test__update_global_counters' \
    'updating global counters..'

  dm_test__cache__global_count__increment

  dm_test__debug '_dm_test__update_global_counters' \
    'incrementing global failure count if test case failed..'
  if ! dm_test__cache__test_result__was_success
  then
    dm_test__cache__global_failure__increment
  fi
}
