#==============================================================================
#   _______        _      _____
#  |__   __|      | |    / ____|
#     | | ___  ___| |_  | |     __ _ ___  ___
#     | |/ _ \/ __| __| | |    / _` / __|/ _ \
#     | |  __/\__ \ |_  | |___| (_| \__ \  __/
#     |_|\___||___/\__|  \_____\__,_|___/\___|
#
#==============================================================================

#==============================================================================
# Getting all the test files located in the predefined test cases root
# directory. Test files are matched based on the predefined test file prefix
# config variable.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CONFIG__TEST_CASES_ROOT
#   DM_TEST__CONFIG__TEST_FILE_PREFIX
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
# Tools:
#   find
#==============================================================================
dm_test__get_test_files() {
  dm_test__debug \
    'dm_test__get_test_files' \
    'gathering test files..'

  ___test_files="$( \
    find \
    "$DM_TEST__CONFIG__TEST_CASES_ROOT" \
    -type f \
    -name "${DM_TEST__CONFIG__TEST_FILE_PREFIX}*" \
  )"

  dm_test__debug_list \
    'dm_test__get_test_files' \
    'test files found:' \
    "$___test_files"

  echo "$___test_files"
}

#==============================================================================
# Get all test cases from a given test file. Test cases are matched against the
# predefined test case prefix configuration variable.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CONFIG__TEST_CASE_PREFIX
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
# Tools:
#   grep true
#==============================================================================
dm_test__get_test_cases() {
  ___test_file_path="$1"

  dm_test__debug \
    'dm_test__get_test_cases' \
    "gathering test cases in test file '${___test_file_path}'.."

  ___test_cases="$( \
    grep -E --only-matching \
      "^${DM_TEST__CONFIG__TEST_CASE_PREFIX}[^\(]+" \
      "$___test_file_path" \
    || true
  )"

  dm_test__debug_list \
    'dm_test__get_test_cases' \
    'test cases found:' \
    "$___test_cases"

  echo "$___test_cases"
}

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
#   [1] test_file_path - Path of the currently executing test file.
#   [2] test_case - Name of the test case function that should be executed.
#   [3] flag_setup - Integer flag that is non zero if the setup hook should be
#       run.
#   [4] flag_teardown - Integer flag that is non zero if the teardown hook
#       should be run.
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
# Tools:
#   None
#==============================================================================
dm_test__execute_test_case() {
  ___test_file_path="$1"
  ___test_case="$2"
  ___flag__setup="$3"
  ___flag__teardown="$4"

  dm_test__debug \
    'dm_test__execute_test_case' \
    ">>> executing test case '${___test_case}'"

  _dm_test__initialize_test_case_environment "$___test_file_path" "$___test_case"
  dm_test__cache__test_result__init
  _dm_test__print_test_case_identifier

  ___output="$( \
    _dm_test__run_test_case \
      "$___test_case" \
      "$___flag__setup" \
      "$___flag__teardown" \
  )"

  _dm_test__print_test_case_result
  _dm_test__update_global_counters
  dm_test__print_output_if_has_content "$___output"
}

#==============================================================================
# The assertion based checking function needs global variables for they
# operation and error reporting and this is the function that is providing
# those variables.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] test_file_path - Path of the currently executing test file.
#   [2] test_case - Name of the test case function that should be executed.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__FILE_UNDER_EXECUTION
#   DM_TEST__TEST_UNDER_EXECUTION
# STDOUT:
#   None
# STDERR:
# - None
# Status:
#   0 - Other status is not expected.
# Tools:
#   basename cut
#==============================================================================
_dm_test__initialize_test_case_environment() {
  ___test_file_path="$1"
  ___test_case="$2"

  # Setting up global variables for the error reporting.
  DM_TEST__FILE_UNDER_EXECUTION="$(basename "$___test_file_path" | cut -d '.' -f 1)"
  DM_TEST__TEST_UNDER_EXECUTION="$___test_case"

  dm_test__debug '_dm_test__initialize_test_case_environment' \
    'test case environment initialized:'
  dm_test__debug '_dm_test__initialize_test_case_environment' \
    "- DM_TEST__FILE_UNDER_EXECUTION='${DM_TEST__FILE_UNDER_EXECUTION}'"
  dm_test__debug '_dm_test__initialize_test_case_environment' \
    "- DM_TEST__TEST_UNDER_EXECUTION='${DM_TEST__TEST_UNDER_EXECUTION}'"
}

#==============================================================================
# Function that executes the given test case defined in the global execution
# environment. It executes the testcase in a separate subshell to provide each
# test case a unique sandboxing environment. In this separate environment it
# executes the optional setup and teardown hooks, before and after the test
# case. The actual test case execution will happen in another subshell in order
# to be able abort it's execution in case of a failed assertion and have the
# teardown hook to run. Withouth this extra subshell, the teardown hook
# couldn't be run if the test case exits from execution. This subshell also has
# a drawback: the teardown hook only can access the environment the setup hook
# is created. It has no access to the test case environment changes. Most of
# the use cases won't need that access.
#------------------------------------------------------------------------------
# Globals:
#   BLUE
#   RED
#   DIM
# Arguments:
#   [1] test_case - Name of the executable test case that is already sourced to
#       the environment ready to be called.
#   [2] flag_setup - Integer flag that is non zero if the setup hook should be
#       run.
#   [3] flag_teardown - Integer flag that is non zero if the teardown hook
#       should be run.
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
# Tools:
#   echo
#==============================================================================
_dm_test__run_test_case() {
  ___test_case="$1"
  ___flag__setup="$2"
  ___flag__teardown="$3"

  dm_test__debug \
    '_dm_test__run_test_case' \
    "preparing to run test case '${___test_case}'"

  dm_test__debug \
    '_dm_test__run_test_case' \
    'creating temporary files to capture file descriptors..'

  # Creating the temporary file names in the cache that will hold the processed
  # output contents.
  ___tmp_file__fd1="$(dm_test__cache__create_temp_file)"
  ___tmp_file__fd2="$(dm_test__cache__create_temp_file)"
  ___tmp_file__fd3="$(dm_test__cache__create_temp_file)"

  dm_test__debug \
    '_dm_test__run_test_case' \
    'creating temporary fifos to redirect file descriptors..'

  # Creating the temporary fifo names in the cache that will be used for the
  # output processing to connect the processor functions to the executing test
  # case.
  ___tmp_fifo__fd1="$(_dm_test__create_temp_fifo)"
  ___tmp_fifo__fd2="$(_dm_test__create_temp_fifo)"
  ___tmp_fifo__fd3="$(_dm_test__create_temp_fifo)"

  if (  # test case level subshell start
    dm_test__debug \
      '_dm_test__run_test_case' \
      '------------------------< test case level subshell start >------------------------'

    #==============================================================================
    # SETUP HOOK EXECUTION
    #==============================================================================
    if [ "$___flag__setup" -ne '0' ]
    then
      dm_test__debug \
        '_dm_test__run_test_case' \
        'running setup hook'
      if _dm_test__run_and_capture \
          "$___tmp_fifo__fd1" \
          "$___tmp_fifo__fd2" \
          "$___tmp_fifo__fd3" \
          "$___tmp_file__fd1" \
          "$___tmp_file__fd2" \
          "$___tmp_file__fd3" \
          'dm_test__run_hook' "$___flag__setup" 'setup'
      then
        ___status_setup="$?"
      else
        ___status_setup="$?"

        dm_test__debug \
          '_dm_test__run_test_case' \
          '[!] setup hook failed, no point to continue with the test case, exiting..'

        exit "$___status_setup"
      fi
    else
      ___status_setup='0'
    fi

    dm_test__debug \
      '_dm_test__run_test_case' \
      "setup hook status: ${___status_setup}"

    #==============================================================================
    # TEST CASE EXECUTION
    #==============================================================================
    dm_test__debug \
      '_dm_test__run_test_case' \
      'running test case function in a separate subshell'
    if ( _dm_test__run_and_capture \
        "$___tmp_fifo__fd1" \
        "$___tmp_fifo__fd2" \
        "$___tmp_fifo__fd3" \
        "$___tmp_file__fd1" \
        "$___tmp_file__fd2" \
        "$___tmp_file__fd3" \
        "$___test_case" )
    then
      ___status_test_case="$?"
    else
      ___status_test_case="$?"
    fi

    dm_test__debug \
      '_dm_test__run_test_case' \
      "test case status: ${___status_test_case}"

    #==============================================================================
    # TEARDOWN HOOK EXECUTION
    #==============================================================================
    if [ "$___flag__teardown" -ne '0' ]
    then
      dm_test__debug \
        '_dm_test__run_test_case' \
        'running teardown hook if needed'
      if _dm_test__run_and_capture \
          "$___tmp_fifo__fd1" \
          "$___tmp_fifo__fd2" \
          "$___tmp_fifo__fd3" \
          "$___tmp_file__fd1" \
          "$___tmp_file__fd2" \
          "$___tmp_file__fd3" \
          'dm_test__run_hook' "$___flag__teardown" 'teardown'
      then
        ___status_teardown="$?"
      else
        ___status_teardown="$?"
      fi
    else
      ___status_teardown='0'
    fi

    dm_test__debug \
      '_dm_test__run_test_case' \
      "teardown hook status: ${___status_teardown}"

    dm_test__debug \
      '_dm_test__run_test_case' \
      '------------------------< test case level subshell stop >------------------------'

    if [ "$___status_setup" -eq '0' ] \
         && [ "$___status_test_case" -eq '0' ] \
         && [ "$___status_teardown" -eq '0' ]
    then
      return 0
    else
      return 1
    fi
  )  # test case level subshell end
  then
    ___status="$?"
  else
    ___status="$?"
  fi

  # If the status is nonzero or there is any standard error content, the
  # testcase is considered as failed.
  if [ "$___status" -ne '0' ]
  then
    dm_test__debug \
      '_dm_test__run_test_case' \
      '[!] status was nonzero => test case failed'
    ___result=1
  elif [ -s "$___tmp_file__fd2" ]
  then
    dm_test__debug \
      '_dm_test__run_test_case' \
      '[!] there were uncaptured standard error output => test case failed'
    echo "${RED}stderr | test_runner | standard error output present => test case fails automatically${RESET}" >> "$___tmp_file__fd2"
    ___result=1
  else
    dm_test__debug \
      '_dm_test__run_test_case' \
      '[ok] zero status + no uncaptured standard error output => test case succeeded'
    ___result=0
  fi

  if [ "$___result" -ne '0' ]
  then
    dm_test__cache__test_result__mark_as_failed

    ___output="$( \
      _dm_test__merge_and_sort_outputs \
        "$___tmp_file__fd1" \
        "$___tmp_file__fd2" \
        "$___tmp_file__fd3" \
    )"

    dm_test__debug \
      '_dm_test__run_test_case' \
      'outputs prepared to display'

    echo "$___output"
  fi
}

#==============================================================================
# Creates a temporary file as a fifo.
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
#   Path to the generated fifo.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   mkfifo echo
#==============================================================================
_dm_test__create_temp_fifo() {
  dm_test__debug \
    '_dm_test__create_temp_fifo' \
    'creating temporary fifo..'

  ___tmp_path="$(dm_test__cache__create_temp_file)"
  mkfifo "$___tmp_path"
  echo "$___tmp_path"
}

#==============================================================================
# Running the given command and capturing all possible outputs of it. For
# capturing its outputs, the standard output, standard error and the optional
# file descriptor 3 will be attached to temporary named pipes. These pipes will
# be read from separate background processes that will prefix each received
# line with a timestamp while formatting it. The prefixed and formatted lines
# will be written to dedicated temporary files. The test case's status code
# will also be captured.
#------------------------------------------------------------------------------
# Globals:
#   BLUE
#   RED
#   DIM
# Arguments:
#   [1] tmp_fifo__fd1 - Temporary fifo for capturing descriptor 1.
#   [2] tmp_fifo__fd2 - Temporary fifo for capturing descriptor 2.
#   [3] tmp_fifo__fd3 - Temporary fifo for capturing descriptor 3.
#   [4] tmp_file__fd1 - Temporary file for the output of file descriptor 1.
#   [5] tmp_file__fd2 - Temporary file for the output of file descriptor 2.
#   [6] tmp_file__fd3 - Temporary file for the output of file descriptor 3.
#   [...] command that needs to be executed and captured
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
#   Status of the executed command.
# Tools:
#   wait
#==============================================================================
_dm_test__run_and_capture() {
  ___tmp_fifo__fd1="$1"; shift
  ___tmp_fifo__fd2="$1"; shift
  ___tmp_fifo__fd3="$1"; shift

  ___tmp_file__fd1="$1"; shift
  ___tmp_file__fd2="$1"; shift
  ___tmp_file__fd3="$1"; shift

  ___command="$*"

  # Starting the processor functions in the background and storing they pids to
  # be able to wait for them later on.
  dm_test__debug \
    '_dm_test__run_and_capture' \
    'starting file descriptor processing workers in the background..'

  # NOTE: the exact time correct ordering is unfortunately not possible with
  # this setup. If two event happens too close to each other, the real order
  # could be inverted or mixed. This is due to the fact how the OS scheduler
  # handles the fifo write events. It can be tested by echoing out a simple
  # text from the test case in sequence to all available outputs, and
  # inspecting the order in the report, ie:
  # >&1 echo 'FD1'
  # >&2 echo 'FD2'
  # >&3 echo 'FD3'
  # >&1 echo 'FD1'
  # >&2 echo 'FD2'
  # >&3 echo 'FD3'
  # Usually this is not a problem though, as between the printouts there are
  # usually some other code to execute, that allows the background processes to
  # process the outputs in the correct order.
  _dm_test__process_output 'stdout' "$BLUE" <"$___tmp_fifo__fd1" >>"$___tmp_file__fd1" &
  ___pid__fd1="$!"
  _dm_test__process_output 'stderr' "$RED" <"$___tmp_fifo__fd2" >>"$___tmp_file__fd2" &
  ___pid__fd2="$!"
  _dm_test__process_output 'debug ' "$DIM" <"$___tmp_fifo__fd3" >>"$___tmp_file__fd3" &
  ___pid__fd3="$!"

  dm_test__debug \
    '_dm_test__run_and_capture' \
    'starting test case execution..'

  # We are doing four things here while executing the test case:
  # 1. Blocking the terminate on error global setting by executing the test
  #    case in an if statement while capturing the status code.
  # 2. Capturing the standard output through a fifo.
  # 3. Capturing the standard error through a fifo.
  # 4. Capturing the optional file descriptor 3 assuming it is the debugger
  #    output through a fifo.
  if $___command \
      1>"${___tmp_fifo__fd1}" \
      2>"${___tmp_fifo__fd2}" \
      3>"${___tmp_fifo__fd3}"
  then
    ___status="$?"
  else
    ___status="$?"
  fi

  dm_test__debug \
    '_dm_test__run_and_capture' \
    'waiting for file descriptor processing workers..'

  # Waiting for the output processor background processes to finish. After
  # this, the outputs are available in the temporary files.
  wait "$___pid__fd1" "$___pid__fd2" "$___pid__fd3"

  dm_test__debug \
    '_dm_test__run_and_capture' \
    'evaluating test case results..'

  return "$___status"
}

#==============================================================================
# Merging and sorting the captured file descriptor outputs captured into
# temporary files.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] tmp_file__fd1 - Temporary file for the output of file descriptor 1.
#   [2] tmp_file__fd2 - Temporary file for the output of file descriptor 2.
#   [3] tmp_file__fd3 - Temporary file for the output of file descriptor 3.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Merged and sorted captured file descriptor output.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   cat sort sed
#==============================================================================
_dm_test__merge_and_sort_outputs() {
  ___tmp_file__fd1="$1"
  ___tmp_file__fd2="$2"
  ___tmp_file__fd3="$3"

  dm_test__debug \
    '_dm_test__merge_and_sort_outputs' \
    'merging and sorting captured outputs..'

  # Using the timestamps preceding every line for sorting, then removing it.
  {
    cat "$___tmp_file__fd1"
    cat "$___tmp_file__fd2"
    cat "$___tmp_file__fd3"
  } | sort | sed -E 's/^[[:digit:]]+\s//'
}

#==============================================================================
# Printing out the about to be executed test case identifier without a newline
# in normal execution but with a newline in case of debug mode to have a better
# debug output.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__FILE_UNDER_EXECUTION
#   DM_TEST__TEST_UNDER_EXECUTION
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
# Tools:
#   echo
#==============================================================================
_dm_test__print_test_case_identifier() {
  dm_test__debug \
    '_dm_test__print_test_case_identifier' \
    'displaying test case identifier..'

  if _dm_test__debug__is_enabled
  then
    echo \
      "${BOLD}${DM_TEST__FILE_UNDER_EXECUTION}.${DM_TEST__TEST_UNDER_EXECUTION}${RESET}"
  else
    echo -n \
      "${BOLD}${DM_TEST__FILE_UNDER_EXECUTION}.${DM_TEST__TEST_UNDER_EXECUTION}${RESET}"
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
# Tools:
#   echo
#==============================================================================
_dm_test__print_test_case_result() {
  dm_test__debug \
    '_dm_test__print_test_case_result' \
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
# Tools:
#   None
#==============================================================================
_dm_test__update_global_counters() {
  dm_test__debug \
    '_dm_test__update_global_counters' \
    'updating global counters..'

  dm_test__cache__global_count__increment

  dm_test__debug \
    '_dm_test__update_global_counters' \
    'incrementing global failure count if test case failed..'
  if ! dm_test__cache__test_result__was_success
  then
    dm_test__cache__global_failure__increment
  fi
}
