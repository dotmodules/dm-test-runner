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
#   DM_TEST__TEST_CASES_ROOT
#   DM_TEST__TEST_FILE_PREFIX
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
  find \
    "$DM_TEST__TEST_CASES_ROOT" \
    -type f \
    -name "${DM_TEST__TEST_FILE_PREFIX}*"
}

#==============================================================================
# Get all test cases from a given test file. Test cases are matched against the
# predefined test case prefix configuration variable.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__TEST_CASE_PREFIX
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
#   grep
#==============================================================================
dm_test__get_test_cases() {
  ___test_file_path="$1"

  grep -E --only-matching \
    "^${DM_TEST__TEST_CASE_PREFIX}[^\(]+" \
    "$___test_file_path"
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

  _dm_test__initialize_test_case_environment "$___test_file_path" "$___test_case"
  dm_test__cache__initialize_test_result
  _dm_test__print_test_case_identifier

  ___output="$( \
    _dm_test__run_test_case \
      "$___test_case" \
      "$___flag__setup" \
      "$___flag__teardown" \
  )"

  _dm_test__print_test_case_result
  _dm_test__update_global_counters
  dm_test__print_if_has_content "$___output"
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
}

#==============================================================================
# Function that executes the given test case defined in the global execution
# environment. It executes the testcase in a separate subshell to provide each
# test case a unique sandboxing environment. While executing the test case, it
# captures separately the standard output, standard error and file descriptor 3
# as an optional debug output. Before and after it executes the testcase it
# runs also the optional setup and teardown hooks.
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
#   mkfifo wait cat sort sed
#==============================================================================
_dm_test__run_test_case() {
  ___test_case="$1"
  ___flag__setup="$2"
  ___flag__teardown="$3"

  # Creating the temporary file names in the cache that will hold the processed
  # output contents.
  ___tmp_file__fd1="$(dm_test__cache__create_temp_file)"
  ___tmp_file__fd2="$(dm_test__cache__create_temp_file)"
  ___tmp_file__fd3="$(dm_test__cache__create_temp_file)"

  # Creating the temporary fifo names in the cache that will be used for the
  # output processing to connect the processor functions to the executing test
  # case.
  ___tmp_fifo__fd1="$(dm_test__cache__create_temp_file)"
  ___tmp_fifo__fd2="$(dm_test__cache__create_temp_file)"
  ___tmp_fifo__fd3="$(dm_test__cache__create_temp_file)"

  mkfifo "$___tmp_fifo__fd1"
  mkfifo "$___tmp_fifo__fd2"
  mkfifo "$___tmp_fifo__fd3"

  # Starting the processor functions in the background and storing they pids to
  # be able to wait for them later on.

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
  _dm_test__process_output "stdout" "$BLUE" <"$___tmp_fifo__fd1" >>"$___tmp_file__fd1" &
  ___pid__fd1="$!"
  _dm_test__process_output "stderr" "$RED" <"$___tmp_fifo__fd2" >>"$___tmp_file__fd2" &
  ___pid__fd2="$!"
  _dm_test__process_output "debug " "$DIM" <"$___tmp_fifo__fd3" >>"$___tmp_file__fd3" &
  ___pid__fd3="$!"

  # We are doing four things here while executing the test case:
  # 1. Blocking the terminate on error global setting by executing the test
  #    case in an if statement while capturing the status code.
  # 2. Capturing the standard output to a temporary file.
  # 3. Capturing the standard error to a temporary file.
  # 4. Capturing the optional file descriptor 3 assuming it is the debugger
  #    output.
  # And we also run the optional setup ad teardown hooks in the same subshell
  # as the test case, to capture the outputs as well and to separate each
  # testcase environments.
  if ( \
    dm_test__run_hook "$___flag__setup" 'setup'; \
    $___test_case; \
    dm_test__run_hook "$___flag__teardown" 'teardown'; \
  ) 1>"${___tmp_fifo__fd1}" 2>"${___tmp_fifo__fd2}" 3>"${___tmp_fifo__fd3}"
  then
    ___status="$?"
  else
    ___status="$?"
  fi

  # Waiting for the output processor background processes to finish. After
  # this, the outputs are available in the temporary files.
  wait "$___pid__fd1" "$___pid__fd2" "$___pid__fd3"

  # If the status is nonzero or there is any standard error content, the
  # testcase is considered as failed.
  if [ "$___status" -ne "0" ] || [ -s "$___tmp_file__fd2" ]
  then
    dm_test__cache__set_test_case_failed

    # In this case, printing all the collected output information, that could
    # help the debugging. Using the timestamps preceding every line, then
    # removing it.
    {
      cat "$___tmp_file__fd1"
      cat "$___tmp_file__fd2"
      cat "$___tmp_file__fd3"
    } | sort | sed -E 's/^[[:digit:]]+\s//'
  fi
}

#==============================================================================
# Printing out the about to be executed test case identifier without a newline.
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
#   printf
#==============================================================================
_dm_test__print_test_case_identifier() {
  # We are using printf to print without a line break, variables are expected
  # in the string.
  # shellcheck disable=SC2059
  printf "${BOLD}${DM_TEST__FILE_UNDER_EXECUTION}.${DM_TEST__TEST_UNDER_EXECUTION}${RESET}"
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
  if dm_test__cache__is_test_case_succeeded
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
  dm_test__cache__increment_global_count
  if ! dm_test__cache__is_test_case_succeeded
  then
    dm_test__cache__increment_global_failure
  fi
}
