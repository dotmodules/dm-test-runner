#!/bin/sh
#==============================================================================
#   _______        _      _____       _ _
#  |__   __|      | |    / ____|     (_) |
#     | | ___  ___| |_  | (___  _   _ _| |_ ___
#     | |/ _ \/ __| __|  \___ \| | | | | __/ _ \
#     | |  __/\__ \ |_   ____) | |_| | | ||  __/
#     |_|\___||___/\__| |_____/ \__,_|_|\__\___|
#
#==============================================================================
# TEST SUITE
#==============================================================================

#==============================================================================
# Test suite and test files related functionality.
#==============================================================================

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
# Main test suite entry function.
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
posix_test__test_suite__main() {
  posix_test__debug 'posix_test__test_suite__main' 'test suite execution started..'

  _posix_test__test_suite__init
  _posix_test__test_suite__execute_test_files
  _posix_test__test_suite__set_result_output_variables
  _posix_test__test_suite__print_report

  posix_test__debug 'posix_test__test_suite__main' 'test suite execution finished'
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
# Initializes all subsystems and prints out the header.
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
_posix_test__test_suite__init() {
  posix_test__debug '_posix_test__test_suite__init' 'initializing..'

  posix_test__config__validate_mandatory_config
  posix_test__cache__init
  posix_test__cache__init_test_directory__test_suite_level
  posix_test__store__init
  posix_test__test_suite__print_header

  posix_test__debug '_posix_test__test_suite__init' 'initializing finished'
}

#==============================================================================
# Execute all of the test files found in the test root directory that matches
# to the test file prefix pattern.
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
_posix_test__test_suite__execute_test_files() {
  posix_test__debug '_posix_test__test_suite__execute_test_files' \
    'executing test files..'

  ___test_files="$(_posix_test__test_suite__get_test_files)"

  if [ -z "$___test_files" ]
  then
    posix_test__debug '_posix_test__test_suite__execute_test_files' \
      'WARNING: no matching test files were found, cannot continue..'
    return
  fi

  # Using a named pipe here to be able to safely iterate over the file names.
  # See more at shellcheck SC2044.
  ___tmp_pipe="$(posix_test__cache__create_temp_path)"
  posix_adapter__mkfifo "$___tmp_pipe"
  echo "$___test_files" > "$___tmp_pipe" &

  while IFS= read -r ___test_file_path
  do
    _posix_test__test_suite__execute_test_file "$___test_file_path"
  done < "$___tmp_pipe"

  posix_test__debug '_posix_test__test_suite__execute_test_files' \
    'test files were executed'
}

#==============================================================================
# Getting all the test files located in the predefined test cases root
# directory. Test files are matched based on the predefined test file prefix
# config variable.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CONFIG__MANDATORY__TEST_FILES_ROOT
#   POSIX_TEST__CONFIG__MANDATORY__TEST_FILE_PREFIX
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Test files found the the test cases root directory. One file path per line.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_posix_test__test_suite__get_test_files() {
  posix_test__debug '_posix_test__test_suite__get_test_files' \
    'gathering test files..'

  # Pre checking if there would be matches.
  if ! ___find_output="$( \
    posix_adapter__find \
      "$POSIX_TEST__CONFIG__MANDATORY__TEST_FILES_ROOT" \
      --type 'f' \
      --name "${POSIX_TEST__CONFIG__MANDATORY__TEST_FILE_PREFIX}*" \
      2>&1 \
  )";
  then
    posix_test__report_error_and_exit \
      'Unexpected error during execution!' \
      'Test file loading failed!' \
      "$___find_output"
  fi

  ___test_files="$( \
    posix_adapter__find \
      "$POSIX_TEST__CONFIG__MANDATORY__TEST_FILES_ROOT" \
      --type 'f' \
      --name "${POSIX_TEST__CONFIG__MANDATORY__TEST_FILE_PREFIX}*" \
      --print0 | \
      posix_adapter__sort --zero-terminated --dictionary-order | \
      posix_adapter__xargs --null --max-args '1' \
  )"
  posix_test__debug_list '_posix_test__test_suite__get_test_files' \
    'test files found:' \
    "$___test_files"

  echo "$___test_files"
}

#==============================================================================
# Execute the given test file by gathering all the test cases in the file and
# triggering the file level hook functions if needed. The actual test file will
# be executed in a separate subshell in order to not to spoil the global test
# suite environment.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] test_file_path - Path of the currently executable test file.
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
_posix_test__test_suite__execute_test_file() {
  ___test_file_path="$1"
  posix_test__debug '_posix_test__test_suite__execute_test_file' \
    "preparing for executing test file '${___test_file_path}'.."

  # Creating the test file level test directory.
  posix_test__cache__init_test_directory__test_file_level

  # Have to collect the test cases before the path change otherwise we have to
  # transform the test file path.
  ___test_cases="$( \
    posix_test__test_case__get_test_cases_from_test_file "$___test_file_path" \
  )"

  if [ -z "$___test_cases" ]
  then
    posix_test__debug '_posix_test__test_suite__execute_test_file' \
      'WARNING: no matching test cases found, skipping file execution..'
    return
  fi

  posix_test__debug '_posix_test__test_suite__execute_test_file' \
    ">> running test file '${___test_file_path}' in a separate subshell.."

  # Executing the test file in a subshell to avoid poisoning the test runner
  # environment.
  (
    _posix_test__test_suite__execute_test_file_in_a_subshell \
      "$___test_file_path" \
      "$___test_cases"
  )
}

#==============================================================================
# Test file execution that should be executed in a subshell. It will trigger
# the setup file hook and execute the test cases then executes the teardown
# file hook.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] test_file_path - Path of the currently executable test file.
#   [2] test_cases - List of test cases that are present in the test file.
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
_posix_test__test_suite__execute_test_file_in_a_subshell() {
  ___test_file_path="$1"
  ___test_cases="$2"

  posix_test__debug '_posix_test__test_suite__execute_test_file_in_a_subshell' \
    '===================[ test file level subshell start ]==================='

  posix_test__test_case__set_current_test_file "$___test_file_path"
  posix_test__hooks__init_hooks_for_test_file "$___test_file_path"

  posix_test__debug '_posix_test__test_suite__execute_test_file_in_a_subshell' \
    'changing path to the test file path for test case level relative imports'

  # Navigating to the directory of the test case to be able to use relative
  # imports there. After this, the '___test_file_path' variable won't be
  # usable directly as a path.
  cd "$(posix_adapter__dirname "$___test_file_path")" || exit

  posix_test__debug '_posix_test__test_suite__execute_test_file_in_a_subshell' \
    'sourcing test file..'

  # Sourcing the test file to get access to the test cases defined inside.
  # Disabling shellcheck error SC1090 here as the test files are
  # dynamically loaded here, and we cannot know the exact source path of
  # them before running the test suite.
  # shellcheck disable=SC1090
  . "./$(posix_adapter__basename "$___test_file_path")"

  if _posix_test__test_suite__run_and_capture_setup_file_hook
  then
    posix_test__debug '_posix_test__test_suite__execute_test_file_in_a_subshell' \
      "executing test cases from test file '${___test_file_path}'.."

    posix_test__test_case__execute_test_cases "$___test_cases"

    _posix_test__test_suite__run_and_capture_teardown_file_hook
  fi

  posix_test__debug '_posix_test__test_suite__execute_test_file_in_a_subshell' \
    'test file execution finished'

  posix_test__debug '_posix_test__test_suite__execute_test_file_in_a_subshell' \
    '====================[ test file level subshell stop ]===================='
}

#==============================================================================
# Executes the setup file hook while capturing the outputs.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CAPTURE__CONSTANT__EXECUTE_COMMAND_DIRECTLY
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
_posix_test__test_suite__run_and_capture_setup_file_hook() {
  if ! posix_test__hooks__is_hook_available__setup_file
  then
    posix_test__debug '_posix_test__test_suite__run_and_capture_setup_file_hook' \
      'setup file hook is not available, returning..'
    return
  fi

  posix_test__debug '_posix_test__test_suite__run_and_capture_setup_file_hook' \
    'executing and capture setup file hook..'

  posix_test__capture__init

  # Running the setup file hook triggering directly in this shell to be able to
  # affect the environment.
  if posix_test__capture__run_and_capture \
    "$POSIX_TEST__CAPTURE__CONSTANT__EXECUTE_COMMAND_DIRECTLY" \
    'posix_test__hooks__trigger_hook__setup_file'
  then
    ___status="$?"
  else
    ___status="$?"
  fi

  if [ "$___status" -ne '0' ] || posix_test__capture__was_standard_error_captured
  then
    posix_test__capture__append_to_standard_error \
      "[!!] Setup file hook failed for test file '${___test_file_path}'."
    posix_test__capture__append_to_standard_error \
      '     Test file execution and teardown hook has been aborted.'
    posix_test__capture__append_to_standard_error \
      '     Continuing with the next test file..'

    if posix_test__config__should_only_display_file_level_hook_output_on_failure
    then
      posix_test__capture__get_captured_outputs
    fi

    # The existence of standard error output is enough to make the setup file
    # hook to fail!
    ___status='1'
  fi

  if posix_test__config__should_always_display_file_level_hook_output
  then
    posix_test__capture__get_captured_outputs
  fi

  posix_test__debug '_posix_test__test_suite__run_and_capture_setup_file_hook' \
    'setup file hook executed'
  return "$___status"
}

#==============================================================================
# Executes the teardown file hook while capturing the outputs.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CAPTURE__CONSTANT__EXECUTE_COMMAND_DIRECTLY
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
_posix_test__test_suite__run_and_capture_teardown_file_hook() {
  if ! posix_test__hooks__is_hook_available__teardown_file
  then
    posix_test__debug '_posix_test__test_suite__run_and_capture_teardown_file_hook' \
      'teardown file hook is not available, returning..'
    return
  fi

  posix_test__debug '_posix_test__test_suite__run_and_capture_teardown_file_hook' \
    'executing and capture teardown file hook..'

  posix_test__capture__init

  # Running the teardown file hook triggering directly in this shell to be able
  # to affect the environment.
  if posix_test__capture__run_and_capture \
    "$POSIX_TEST__CAPTURE__CONSTANT__EXECUTE_COMMAND_DIRECTLY" \
    'posix_test__hooks__trigger_hook__teardown_file'
  then
    :
  else
    posix_test__capture__append_to_standard_error \
      "[!!] Teardown file hook failed for test file '${___test_file_path}'."
    posix_test__capture__append_to_standard_error \
      "     Further execution won't be interrupted because of this."

    if posix_test__config__should_only_display_file_level_hook_output_on_failure
    then
      posix_test__capture__get_captured_outputs
    fi
  fi

  if posix_test__config__should_always_display_file_level_hook_output
  then
    posix_test__capture__get_captured_outputs
  fi

  posix_test__debug '_posix_test__test_suite__run_and_capture_teardown_file_hook' \
    'teardown file hook executed'

  # Ignoring teardown file hook status, as it won't be used and won't effect
  # the further execution.
  return 0
}

#==============================================================================
# Sets output variables about the result of the test execution.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__RESULT__TEST_CASE_COUNT
#   POSIX_TEST__RESULT__FAILURE_COUNT
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   POSIX_TEST__RESULT__TEST_CASE_COUNT
#   POSIX_TEST__RESULT__FAILURE_COUNT
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_posix_test__test_suite__set_result_output_variables() {
  posix_test__debug '_posix_test__test_suite__set_result_output_variables' \
    'setting output variables..'

  # Disabling shellcheck warning because the output variables won't be used
  # here.
  # shellcheck disable=SC2034
  POSIX_TEST__RESULT__TEST_CASE_COUNT="$(posix_test__cache__global_count__get)"
  # shellcheck disable=SC2034
  POSIX_TEST__RESULT__FAILURE_COUNT="$(posix_test__cache__global_failure__get)"

  posix_test__debug '_posix_test__test_suite__set_result_output_variables' \
    'output variables were set'
  posix_test__debug '_posix_test__test_suite__set_result_output_variables' \
    "- POSIX_TEST__RESULT__TEST_CASE_COUNT: ${POSIX_TEST__RESULT__TEST_CASE_COUNT}"
  posix_test__debug '_posix_test__test_suite__set_result_output_variables' \
    "- POSIX_TEST__RESULT__FAILURE_COUNT: ${POSIX_TEST__RESULT__FAILURE_COUNT}"
}

#==============================================================================
# Test suite runner header with configuration and system information.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX
#   POSIX_TEST__CONFIG__MANDATORY__TEST_FILES_ROOT
#   POSIX_TEST__CONFIG__MANDATORY__TEST_FILE_PREFIX
#   POSIX_TEST__CONFIG__MANDATORY__TEST_CASE_PREFIX
#   POSIX_TEST__CONFIG__OPTIONAL__CACHE_PARENT_DIRECTORY
#   POSIX_TEST__CONFIG__OPTIONAL__EXIT_ON_FAILURE
#   POSIX_TEST__CONFIG__OPTIONAL__EXIT_STATUS_ON_FAILURE
#   POSIX_TEST__CONFIG__OPTIONAL__ALWAYS_DISPLAY_FILE_LEVEL_HOOK_OUTPUT
#   POSIX_TEST__CONFIG__OPTIONAL__DISPLAY_CAPTURED_OUTPUT_ON_SUCCESS
#   POSIX_TEST__CONFIG__OPTIONAL__DEBUG_ENABLED
#   DIM
#   RESET
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Multiline header with config and system information.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
posix_test__test_suite__print_header() {
  posix_test__debug 'posix_test__test_suite__print_header' 'printing suite header..'

  #============================================================================
  # TITLE
  #============================================================================
  echo "${DIM}-------------------------------------------------------------------------------"
  echo '>> POSIX-TEST <<'

  #============================================================================
  # CONFIG SECTION
  #============================================================================
  echo "-------------------------------------------------------------------------------${RESET}"

  # Mandatory config variables
  _posix_test__test_suite__print_header__print_config \
    'POSIX_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX' \
    "$POSIX_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX"

  _posix_test__test_suite__print_header__print_config \
    'POSIX_TEST__CONFIG__MANDATORY__TEST_FILES_ROOT' \
    "$POSIX_TEST__CONFIG__MANDATORY__TEST_FILES_ROOT"

  _posix_test__test_suite__print_header__print_config \
    'POSIX_TEST__CONFIG__MANDATORY__TEST_FILE_PREFIX' \
    "$POSIX_TEST__CONFIG__MANDATORY__TEST_FILE_PREFIX"

  _posix_test__test_suite__print_header__print_config \
    'POSIX_TEST__CONFIG__MANDATORY__TEST_CASE_PREFIX' \
    "$POSIX_TEST__CONFIG__MANDATORY__TEST_CASE_PREFIX"

  # Optional config variables
  _posix_test__test_suite__print_header__print_config \
    'POSIX_TEST__CONFIG__OPTIONAL__CACHE_PARENT_DIRECTORY' \
    "$POSIX_TEST__CONFIG__OPTIONAL__CACHE_PARENT_DIRECTORY"

  _posix_test__test_suite__print_header__print_config \
    'POSIX_TEST__CONFIG__OPTIONAL__EXIT_ON_FAILURE' \
    "$POSIX_TEST__CONFIG__OPTIONAL__EXIT_ON_FAILURE"

  _posix_test__test_suite__print_header__print_config \
    'POSIX_TEST__CONFIG__OPTIONAL__EXIT_STATUS_ON_FAILURE' \
    "$POSIX_TEST__CONFIG__OPTIONAL__EXIT_STATUS_ON_FAILURE"

  _posix_test__test_suite__print_header__print_config \
    'POSIX_TEST__CONFIG__OPTIONAL__ALWAYS_DISPLAY_FILE_LEVEL_HOOK_OUTPUT' \
    "$POSIX_TEST__CONFIG__OPTIONAL__ALWAYS_DISPLAY_FILE_LEVEL_HOOK_OUTPUT"

  _posix_test__test_suite__print_header__print_config \
    'POSIX_TEST__CONFIG__OPTIONAL__DISPLAY_CAPTURED_OUTPUT_ON_SUCCESS' \
    "$POSIX_TEST__CONFIG__OPTIONAL__DISPLAY_CAPTURED_OUTPUT_ON_SUCCESS"

  _posix_test__test_suite__print_header__print_config \
    'POSIX_TEST__CONFIG__OPTIONAL__DEBUG_ENABLED' \
    "$POSIX_TEST__CONFIG__OPTIONAL__DEBUG_ENABLED"

  printf '%s' "$DIM"
  #============================================================================
  # SYSTEM INFO SECTION
  #============================================================================
  echo '-------------------------------------------------------------------------------'
  echo '$ uname --kernel-name --kernel-release --machine'
  posix_adapter__uname --kernel-name --kernel-release --machine

  #============================================================================
  # SHELL INFO SECTION
  #============================================================================
  echo '-------------------------------------------------------------------------------'
  echo '$ command -v sh'
  command -v sh

  #============================================================================
  # FOOTER SECTION
  #============================================================================
  echo "-------------------------------------------------------------------------------${RESET}"
}

#==============================================================================
# Provides a fancy way to print out a variable and its value.
#------------------------------------------------------------------------------
# Globals:
#   DIM
#   RESET
# Arguments:
#   [1] variable_name - Name of the variable you want to print out.
#   [2] variable_value - Value that needs to be printed.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Single padded line that contains the variable and the variable value.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_posix_test__test_suite__print_header__print_config() {
  ___name="$1"
  ___value="$2"

  posix_test__debug '_posix_test__test_suite__print_header__print_config' \
    'printing configuration line for name and value:'
  posix_test__debug '_posix_test__test_suite__print_header__print_config' \
    "- '${___name}'"
  posix_test__debug '_posix_test__test_suite__print_header__print_config' \
    "- '${___value}'"

  # Space padding after the name and before the value.
  ___name="${___name} "
  ___value=" ${___value}"

  ___name_length="$( \
    printf '%s' "$___name" | posix_adapter__wc --chars \
  )"
  ___value_length="$( \
    printf '%s' "$___value" | posix_adapter__wc --chars \
  )"

  ___pad_length='79'
  ___pad='............................................................'  # 60
  ___pad="${___pad}..................."  # 19

  ___pad_length="$(( ___pad_length - ___name_length - ___value_length ))"

  # Start the printout.
  printf '%s' "$DIM"
  printf '%s' "$___name"

  # Print the padding if there is paddable space left.
  if [ "$___pad_length" -gt '0' ]
  then
    printf '%*.*s' 0 "$___pad_length" "$___pad"
  fi

  printf '%s\n' "${___value}${RESET}"
}

#==============================================================================
# Function that prints out the results of the test suite. It provides a total
# and failed count, an overall test suite result (success or failure), and an
# optional error summary if there was an assertion error during execution. If
# the test suite fails this function will terminate the execution.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CONFIG__OPTIONAL__STATUS_ON_FAILURE
#   RED
#   GREEN
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
#   Test suite summary and optional error report.
# STDERR:
#   None
# Status:
#   0 - test suite passed
#   1 - test suite failed, process termination
#==============================================================================
_posix_test__test_suite__print_report() {
  posix_test__debug '_posix_test__test_suite__print_report' \
    'printing test suite report..'

  ___global_count="$(posix_test__cache__global_count__get)"
  ___failure_count="$(posix_test__cache__global_failure__get)"

  echo ''
  echo "${BOLD}${___global_count} tests, ${___failure_count} failed${RESET}"

  if posix_test__cache__global_failure__failures_happened
  then
    echo "${BOLD}Result: ${RED}FAILURE${RESET}"
    echo ''
    if posix_test__cache__global_errors__has_errors
    then
      posix_test__cache__global_errors__print_errors
    fi

    # The exiting behavior of the test suite on failure is fully configurable.
    # The exit call and the exit call status can be configured on demand.
    if posix_test__config__should_exit_on_failure
    then
      posix_test__debug '_posix_test__test_suite__print_report' \
        'test suite failed: exiting'
      exit "${POSIX_TEST__CONFIG__OPTIONAL__STATUS_ON_FAILURE}"
    else
      posix_test__debug '_posix_test__test_suite__print_report' \
        'test suite failed: ignoring exiting because of config override'
    fi

  else
    echo "${BOLD}Result: ${GREEN}SUCCESS${RESET}"
    echo ''
  fi
}
