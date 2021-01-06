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
#------------------------------------------------------------------------------
# Tools:
#   None
#==============================================================================
dm_test__test_suite__main() {
  dm_test__debug 'dm_test__test_suite__main' 'test suite execution started..'

  _dm_test__test_suite__init
  _dm_test__test_suite__execute_test_files
  _dm_test__test_suite__set_result_output_variables
  _dm_test__test_suite__print_report

  dm_test__debug 'dm_test__test_suite__main' 'test suite execution finished'
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
#------------------------------------------------------------------------------
# Tools:
#   None
#==============================================================================
_dm_test__test_suite__init() {
  dm_test__debug '_dm_test__test_suite__init' 'initializing..'

  dm_test__config__validate_mandatory_config
  dm_test__cache__init
  dm_test__cache__init_test_directory__test_suite_level
  dm_test__test_suite__print_header

  dm_test__debug '_dm_test__test_suite__init' 'initializing finished'
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
#------------------------------------------------------------------------------
# Tools:
#   mkfifo
#==============================================================================
_dm_test__test_suite__execute_test_files() {
  dm_test__debug '_dm_test__test_suite__execute_test_files' \
    'executing test files..'

  # Using a named pipe here to be able to safely iterate over the file names.
  # See more at shellcheck SC2044.
  ___tmp_pipe="$(dm_test__cache__create_temp_file)"
  mkfifo "$___tmp_pipe"
  _dm_test__test_suite__get_test_files > "$___tmp_pipe" &

  while IFS= read -r ___test_file_path
  do
    _dm_test__test_suite__execute_test_file "$___test_file_path"
  done < "$___tmp_pipe"

  dm_test__debug '_dm_test__test_suite__execute_test_files' \
    'test files were executed'
}

#==============================================================================
# Getting all the test files located in the predefined test cases root
# directory. Test files are matched based on the predefined test file prefix
# config variable.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CONFIG__MANDATORY__TEST_CASES_ROOT
#   DM_TEST__CONFIG__MANDATORY__TEST_FILE_PREFIX
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Test files found the the test cases root direcotry. One file path per line.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#------------------------------------------------------------------------------
# Tools:
#   find sort xargs echo
#==============================================================================
_dm_test__test_suite__get_test_files() {
  dm_test__debug '_dm_test__test_suite__get_test_files' \
    'gathering test files..'

  ___test_files="$( \
    find \
      "$DM_TEST__CONFIG__MANDATORY__TEST_CASES_ROOT" \
      -type f \
      -name "${DM_TEST__CONFIG__MANDATORY__TEST_FILE_PREFIX}*" \
      -print0 | \
    sort --zero-terminated --dictionary-order | \
    xargs --null --max-args=1 --no-run-if-empty \
  )"

  dm_test__debug_list '_dm_test__test_suite__get_test_files' \
    'test files found:' \
    "$___test_files"

  echo "$___test_files"
}

#==============================================================================
# Execute the given test file by gathering all the test cases in the file and
# triggering the file level hook functions if needed. The actual test file will
# be executed in a separate subshell in order to not to spoil the global test
# suite environemnt.
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
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
_dm_test__test_suite__execute_test_file() {
  ___test_file_path="$1"
  dm_test__debug '_dm_test__test_suite__execute_test_file' \
    "preparing for executing test file '${___test_file_path}'.."

  # Creating the test file level test directory.
  dm_test__cache__init_test_directory__test_file_level

  # Have to collect the test cases before the path change.
  ___test_cases="$( \
    dm_test__test_case__get_test_cases_from_test_file "$___test_file_path" \
  )"

  if [ -z "$___test_cases" ]
  then
    dm_test__debug '_dm_test__test_suite__execute_test_file' \
      '[warn] no matching test cases found, skipping file execution..'
    return
  fi

  dm_test__debug '_dm_test__test_suite__execute_test_file' \
    ">> running test file '${___test_file_path}' in a separate subshell.."

  # Executing the test file in a subshell to avoid poisoning the test runner
  # environemnt.
  (
    _dm_test__test_suite__execute_test_file_in_a_subshell \
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
#------------------------------------------------------------------------------
# Tools:
#   cd dirname basename echo test
#==============================================================================
_dm_test__test_suite__execute_test_file_in_a_subshell() {
  ___test_file_path="$1"
  ___test_cases="$2"

  dm_test__debug '_dm_test__test_suite__execute_test_file_in_a_subshell' \
    '===================[ test file level subshell start ]==================='

  dm_test__test_case__set_current_test_file "$___test_file_path"
  dm_test__hooks__init_hooks_for_test_file "$___test_file_path"

  dm_test__debug '_dm_test__test_suite__execute_test_file_in_a_subshell' \
    'changing path to the test file path for test case level relative imports'

  # Navigating to the directory of the testcase to be able to use relative
  # imports there. After this, the '___test_file_path' variable won't be
  # usable directly as a path.
  cd "$(dirname "$___test_file_path")" || exit

  dm_test__debug '_dm_test__test_suite__execute_test_file_in_a_subshell' \
    'sourcing test file..'

  # Sourcing the test file to get access to the test cases defined inside.
  # Disabling shellcheck error SC1090 here as the test files are
  # dynamically loaded here, and we cannot know the exact source path of
  # them before running the test suite.
  # shellcheck disable=SC1090
  . "./$(basename "$___test_file_path")"

  if _dm_test__test_suite__run_and_capture_setup_file_hook
  then
    dm_test__debug '_dm_test__test_suite__execute_test_file_in_a_subshell' \
      "executing test cases from test file '${___test_file_path}'.."

    dm_test__test_case__execute_test_cases "$___test_cases"

    _dm_test__test_suite__run_and_capture_teardown_file_hook
  fi

  dm_test__debug '_dm_test__test_suite__execute_test_file_in_a_subshell' \
    'test file execution finished'

  dm_test__debug '_dm_test__test_suite__execute_test_file_in_a_subshell' \
    '====================[ test file level subshell stop ]===================='
}

#==============================================================================
# Executes the setup file hook while capturing the outputs.
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
_dm_test__test_suite__run_and_capture_setup_file_hook() {
  dm_test__debug '_dm_test__test_suite__run_and_capture_setup_file_hook' \
    'executing and capture setup file hook..'

  dm_test__capture__init

  if dm_test__capture__run_and_capture \
    'dm_test__hooks__trigger_hook__setup_file'
  then
    ___status="$?"
  else
    ___status="$?"

    dm_test__capture__append_to_standard_error \
      "[!!] Setup file hook failed for test file '${___test_file_path}'."
    dm_test__capture__append_to_standard_error \
      '     Test file execution and teardown hook has been aborted.'
    dm_test__capture__append_to_standard_error \
      '     Continuing with the next test file..'

    if dm_test__config__should_only_display_file_level_hook_output_on_failure
    then
      dm_test__capture__get_captured_outputs
    fi
  fi

  if dm_test__config__should_always_display_file_level_hook_output
  then
    dm_test__capture__get_captured_outputs
  fi

  dm_test__debug '_dm_test__test_suite__run_and_capture_setup_file_hook' \
    'setup file hook executed'
  return "$___status"
}

#==============================================================================
# Executes the teardown file hook while capturing the outputs.
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
_dm_test__test_suite__run_and_capture_teardown_file_hook() {
  dm_test__debug '_dm_test__test_suite__run_and_capture_teardown_file_hook' \
    'executing and capture teardown file hook..'

  dm_test__capture__init

  if dm_test__capture__run_and_capture \
    'dm_test__hooks__trigger_hook__teardown_file'
  then
    :
  else
    dm_test__capture__append_to_standard_error \
      "[!!] Teardown file hook failed for test file '${___test_file_path}'."
    dm_test__capture__append_to_standard_error \
      "     Further execution won't be interrupted because of this."

    if dm_test__config__should_only_display_file_level_hook_output_on_failure
    then
      dm_test__capture__get_captured_outputs
    fi
  fi

  if dm_test__config__should_always_display_file_level_hook_output
  then
    dm_test__capture__get_captured_outputs
  fi

  dm_test__debug '_dm_test__test_suite__run_and_capture_teardown_file_hook' \
    'teardown file hook executed'

  # Ignoring teardown file hook status, as it won't be used and won't effect
  # the further execution.
  return 0
}

#==============================================================================
# Sets output variables about the result of the test execution.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__RESULT__TEST_CASE_COUNT
#   DM_TEST__RESULT__FAILURE_COUNT
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__RESULT__TEST_CASE_COUNT
#   DM_TEST__RESULT__FAILURE_COUNT
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
_dm_test__test_suite__set_result_output_variables() {
  dm_test__debug '_dm_test__test_suite__set_result_output_variables' \
    'setting output variables..'

  # Disabling shellcheck warning because the output variables won't be used
  # here.
  # shellcheck disable=SC2034
  DM_TEST__RESULT__TEST_CASE_COUNT="$(dm_test__cache__global_count__get)"
  # shellcheck disable=SC2034
  DM_TEST__RESULT__FAILURE_COUNT="$(dm_test__cache__global_failure__get)"

  dm_test__debug '_dm_test__test_suite__set_result_output_variables' \
    'output variables were set'
  dm_test__debug '_dm_test__test_suite__set_result_output_variables' \
    "- DM_TEST__RESULT__TEST_CASE_COUNT: ${DM_TEST__RESULT__TEST_CASE_COUNT}"
  dm_test__debug '_dm_test__test_suite__set_result_output_variables' \
    "- DM_TEST__RESULT__FAILURE_COUNT: ${DM_TEST__RESULT__FAILURE_COUNT}"
}

#==============================================================================
# Test suite runner header with configuration and system information.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX
#   DM_TEST__CONFIG__MANDATORY__TEST_CASES_ROOT
#   DM_TEST__CONFIG__MANDATORY__TEST_FILE_PREFIX
#   DM_TEST__CONFIG__MANDATORY__TEST_CASE_PREFIX
#   DM_TEST__CONFIG__OPTIONAL__EXIT_ON_FAILURE
#   DM_TEST__CONFIG__OPTIONAL__EXIT_STATUS_ON_FAILURE
#   DM_TEST__CONFIG__OPTIONAL__ALWAYS_DISPLAY_FILE_LEVEL_HOOK_OUTPUT
#   DM_TEST__CONFIG__OPTIONAL__DEBUG_ENABLED
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
#------------------------------------------------------------------------------
# Tools:
#   echo uname command
#==============================================================================
dm_test__test_suite__print_header() {
  dm_test__debug 'dm_test__test_suite__print_header' 'printing suite header..'

  #============================================================================
  # TITLE
  #============================================================================
  echo -n "$DIM"
  echo -n '-------------------------------------------------------------------'
  echo '------------'
  echo '>> DM TEST <<'

  #============================================================================
  # CONFIG SECTION
  #============================================================================
  echo -n '-------------------------------------------------------------------'
  echo '------------'
  echo '$ dm.test.sh --config'

  # Mandatory config variables
  echo -n 'DM_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX='
  echo "'${DM_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX}'"

  echo -n 'DM_TEST__CONFIG__MANDATORY__TEST_CASES_ROOT='
  echo "'${DM_TEST__CONFIG__MANDATORY__TEST_CASES_ROOT}'"

  echo -n 'DM_TEST__CONFIG__MANDATORY__TEST_FILE_PREFIX='
  echo "'${DM_TEST__CONFIG__MANDATORY__TEST_FILE_PREFIX}'"

  echo -n 'DM_TEST__CONFIG__MANDATORY__TEST_CASE_PREFIX='
  echo "'${DM_TEST__CONFIG__MANDATORY__TEST_CASE_PREFIX}'"

  # Optional config variables
  echo -n 'DM_TEST__CONFIG__OPTIONAL__EXIT_ON_FAILURE='
  echo "'${DM_TEST__CONFIG__OPTIONAL__EXIT_ON_FAILURE}'"

  echo -n 'DM_TEST__CONFIG__OPTIONAL__EXIT_STATUS_ON_FAILURE='
  echo "'${DM_TEST__CONFIG__OPTIONAL__EXIT_STATUS_ON_FAILURE}'"

  echo -n 'DM_TEST__CONFIG__OPTIONAL__ALWAYS_DISPLAY_FILE_LEVEL_HOOK_OUTPUT='
  echo "'${DM_TEST__CONFIG__OPTIONAL__ALWAYS_DISPLAY_FILE_LEVEL_HOOK_OUTPUT}'"

  echo -n 'DM_TEST__CONFIG__OPTIONAL__DEBUG_ENABLED='
  echo "'${DM_TEST__CONFIG__OPTIONAL__DEBUG_ENABLED}'"

  #============================================================================
  # SYSTEM INFO SECTION
  #============================================================================
  echo -n '-------------------------------------------------------------------'
  echo '------------'
  echo '$ uname --kernel-name --kernel-release --machine --operating-system'
  uname --kernel-name --kernel-release --machine --operating-system

  #============================================================================
  # SHELL INFO SECTION
  #============================================================================
  echo -n '-------------------------------------------------------------------'
  echo '------------'
  echo '$ command -v sh'
  command -v sh

  #============================================================================
  # FOOTER SECTION
  #============================================================================
  echo -n '-------------------------------------------------------------------'
  echo '------------'
  echo -n "$RESET"
}

#==============================================================================
# Function that prints out the results of the test suite. It provides a total
# and failed count, a overall test suite result (success or failure), and an
# optional error summary if there was an assertion error during execution. If
# the test suite fails this function will terminate the execution.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CONFIG__OPTIONAL__STATUS_ON_FAILURE
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
#------------------------------------------------------------------------------
# Tools:
#   echo test
#==============================================================================
_dm_test__test_suite__print_report() {
  dm_test__debug '_dm_test__test_suite__print_report' \
    'printing test suite report..'

  ___global_count="$(dm_test__cache__global_count__get)"
  ___failure_count="$(dm_test__cache__global_failure__get)"

  echo ''
  echo "${BOLD}${___global_count} tests, ${___failure_count} failed${RESET}"

  if dm_test__cache__global_failure__failures_happened
  then
    echo "${BOLD}Result: ${RED}FAILURE${RESET}"
    echo ''
    if dm_test__cache__global_errors__has_errors
    then
      dm_test__cache__global_errors__print_errors
    fi

    # The exiting behavior of the test suite on failure is fully configurable.
    # The exit call and the exit call status can be configured on demand.
    if dm_test__config__should_exit_on_failure
    then
      dm_test__debug '_dm_test__test_suite__print_report' \
        'test suite failed: exiting'
      exit "${DM_TEST__CONFIG__OPTIONAL__STATUS_ON_FAILURE}"
    else
      dm_test__debug '_dm_test__test_suite__print_report' \
        'test suite failed: ignoring exiting because of config override'
    fi

  else
    echo "${BOLD}Result: ${GREEN}SUCCESS${RESET}"
    echo ''
  fi
}
