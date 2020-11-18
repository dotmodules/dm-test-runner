#==============================================================================
#                              _   _                        _____ _____
#      /\                     | | (_)                 /\   |  __ \_   _|
#     /  \   ___ ___  ___ _ __| |_ _  ___  _ __      /  \  | |__) || |
#    / /\ \ / __/ __|/ _ \ '__| __| |/ _ \| '_ \    / /\ \ |  ___/ | |
#   / ____ \\__ \__ \  __/ |  | |_| | (_) | | | |  / ____ \| |    _| |_
#  /_/    \_\___/___/\___|_|   \__|_|\___/|_| |_| /_/    \_\_|   |_____|
#
#==============================================================================

#==============================================================================
# This file contains the API functions that the test cases can use to test
# their functionality. Most of the assertion functions require the usage of the
# provided `run` function to run the testable function with in order to capture
# the output and status of the testable function.
#==============================================================================

#==============================================================================
#   ____
#  |  _ \ _   _ _ __
#  | |_) | | | | '_ \
#  |  _ <| |_| | | | |
#  |_| \_\\__,_|_| |_|
#
#==============================================================================
# TARGET FUNCTION RUNNER
#==============================================================================

#==============================================================================
# Function under test capturer API function. It excepts a list of parameters
# that will be executed while the output and the status will be captured and
# will be put into test case level global output variables. Calling the
# testable function in this way is necessary if we want to use the advanced
# assertion functions, as those are working on the output variables of this
# function.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   Expects a list of arguments that will be evaluated.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   ___output - Captured output of the evaluated command passed in as a
#               parameter list.
#   ___status - Captured status of the evaluated command.
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected, as the status of the given command is
#       captured.
# Tools:
#   None
#==============================================================================
run() {
  dm_test__debug \
    'run' \
    "running command: '$*'"

  if ___output="$("$@")"
  then
    ___status="$?"
  else
    ___status="$?"
  fi

  dm_test__debug_list \
    'run' \
    'captured output:' \
    "$___output"

  dm_test__debug \
    'run' \
    "captured status: '${___status}'"
}

#==============================================================================
#      _                      _
#     / \   ___ ___  ___ _ __| |_
#    / _ \ / __/ __|/ _ \ '__| __|
#   / ___ \\__ \__ \  __/ |  | |_
#  /_/   \_\___/___/\___|_|   \__|
#
#==============================================================================
# ASSERTION FUNCTIONS
#==============================================================================

#==============================================================================
# Simple assertion helper function that expects a list of parameters that will
# be interpreted as a test command. Based on that evaluation the assertion
# result will be decided. It is common to use the 'test' command to write
# simple assertions, but in general anything can be used. This assertion
# function does not require a prior call to the 'run' command to have the test
# output variables set.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   Expects a list of arguments that will be evaluated.
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
#   0 - Assertion succeeded.
#  !0 - Assertion failed.
# Tools:
#   None
#==============================================================================
assert() {
  # Disabling SC2124 here as we won't modify the assigned 'commands' variable.
  # shellcheck disable=SC2124
  ___commands="$@"

  dm_test__debug \
    'assert' \
    "running assertion: '${___commands}'"

  if $___commands
  then
    dm_test__debug 'assert' '=> assertion succeeded'
  else
    dm_test__debug 'assert' '=> assertion failed'

    ___subject='Assertion failed'
    ___reason="$___commands"
    _dm_test__report_failure "$___subject" "$___reason"
  fi
}

#==============================================================================
# Simple assertion that checks if the given file path is valid and there is a
# file behind. This assertion function that does not require a prior call to
# the 'run' command to have the test output variables set.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] file_path - Path that needs to be tested in this function.
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
#   0 - Assertion succeeded.
#  !0 - Assertion failed.
# Tools:
#   test
#==============================================================================
assert_file() {
  ___file_path="$1"

  dm_test__debug \
    'assert_file' \
    "asserting file existence: '${___file_path}'"

  if [ -f "$___file_path" ]
  then
    dm_test__debug 'assert_file' '=> assertion succeeded'
  else
    dm_test__debug 'assert_file' '=> assertion failed'

    ___subject='Invalid file path'
    ___reason="${___file_path}"
    _dm_test__report_failure "$___subject" "$___reason"
  fi
}

#==============================================================================
# Advanced assertion function that will evaluate the previously set output
# variables by the 'run' function.
#------------------------------------------------------------------------------
# Globals:
#   ___output
# Arguments:
#   [1] expected_output - Expected output of the previously run function.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
# - None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#  !0 - Assertion failed.
# Tools:
#   test
#==============================================================================
assert_output() {
  ___expected="$1"
  ___result="$___output"

  dm_test__debug 'assert_output' 'asserting output:'
  dm_test__debug 'assert_output' "- expected: '${___expected}'"
  dm_test__debug 'assert_output' "- result:   '${___result}'"

  if [ "$___result" = "$___expected" ]
  then
    dm_test__debug 'assert_output' '=> assertion succeeded'
  else
    dm_test__debug 'assert_output' '=> assertion failed'

    ___subject='Output comparison failed'
    ___reason="expected: '${___expected}'\n  actual: '${___result}'"
    _dm_test__report_failure "$___subject" "$___reason"
  fi
}

#==============================================================================
# Advanced assertion function to check the line count of the command output
# runned with the 'run' function.
#------------------------------------------------------------------------------
# Globals:
#   ___output
# Arguments:
#   [1] expected_line_count - Expected output line count.
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
#   0 - Assertion succeeded.
#  !0 - Assertion failed.
# Tools:
#   echo wc test
#==============================================================================
assert_output_line_count() {
  ___expected="$1"
  ___result="$(echo "$___output" | wc --lines)"

  dm_test__debug 'assert_output_line_count' 'asserting output line count:'
  dm_test__debug 'assert_output_line_count' "- expected: '${___expected}'"
  dm_test__debug 'assert_output_line_count' "- result:   '${___result}'"

  if [ "$___result" -eq "$___expected" ]
  then
    dm_test__debug 'assert_output_line_count' '=> assertion succeeded'
  else
    dm_test__debug 'assert_output_line_count' '=> assertion failed'

    ___subject='Output line count mismatch'
    ___reason="expected: '${___expected}'\n  actual: '${___result}'"
    _dm_test__report_failure "$___subject" "$___reason"
  fi
}

#==============================================================================
# Advanced assertion function that compares the output line indexed by the
# index parameter with the expected parameter.
#------------------------------------------------------------------------------
# Globals:
#   ___output
# Arguments:
#   [1] line_index - One-based line index.
#   [2] expected - Expected content of the given line without the new line
#                  character.
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
#   0 - Assertion succeeded.
#  !0 - Assertion failed.
# Tools:
#   test
#==============================================================================
assert_line_at_index() {
  ___index="$1"
  ___expected="$2"

  ___result="$(dm_test__utils__get_line_from_output_by_index "$___index" "$___output")"

  dm_test__debug 'assert_line_at_index' 'asserting output line at index:'
  dm_test__debug 'assert_line_at_index' "- expected: '${___expected}'"
  dm_test__debug 'assert_line_at_index' "- result:   '${___result}'"

  if [ "$___result" = "$___expected" ]
  then
    dm_test__debug 'assert_line_at_index' '=> assertion succeeded'
  else
    dm_test__debug 'assert_line_at_index' '=> assertion failed'

    ___subject="Line at index '${___index}' differs from expected'"
    ___reason="expected: '${___expected}'\n  actual: '${___result}'"
    _dm_test__report_failure "$___subject" "$___reason"
  fi
}

#==============================================================================
# Advanced assertion function that compares the output line indexed by the
# index parameter with the expected parameter. The line has to partially match
# only.
#------------------------------------------------------------------------------
# Globals:
#   ___output
# Arguments:
#   [1] line_index - One-based line index.
#   [2] expected - Expected content of the given line without the new line
#                  character.
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
#   0 - Assertion succeeded.
#  !0 - Assertion failed.
# Tools:
#   echo grep
#==============================================================================
assert_line_partially_at_index() {
  ___index="$1"
  ___expected="$2"

  ___result="$(dm_test__utils__get_line_from_output_by_index "$___index" "$___output")"

  dm_test__debug 'assert_line_partially_at_index' 'asserting output line at index partially:'
  dm_test__debug 'assert_line_partially_at_index' "- pattern: '${___expected}'"
  dm_test__debug 'assert_line_partially_at_index' "- target:   '${___result}'"

  if echo "$___result" | grep --silent "$___expected"
  then
    dm_test__debug 'assert_line_partially_at_index' '=> assertion succeeded'
  else
    dm_test__debug 'assert_line_partially_at_index' '=> assertion failed'

    ___subject="Line at index '${___index}' differs from expected'"
    ___reason="expected: '${___expected}'\n  actual: '${___result}'"
    _dm_test__report_failure "$___subject" "$___reason"
  fi
}

#==============================================================================
# Advanced assertion function that will evaluate the previously set 'status'
# variable by the 'run' function.
#------------------------------------------------------------------------------
# Globals:
#   ___status
# Arguments:
#   [1] expected_status - Expected status of the previously run function.
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
#   0 - Assertion succeeded.
#  !0 - Assertion failed.
# Tools:
#   test
#==============================================================================
assert_status() {
  ___expected="$1"
  ___result="$___status"

  dm_test__debug 'assert_status' 'asserting status:'
  dm_test__debug 'assert_status' "- expected: '${___expected}'"
  dm_test__debug 'assert_status' "- result:   '${___result}'"

  if [ "$___result" = "$___expected" ]
  then
    dm_test__debug 'assert_status' '=> assertion succeeded'
  else
    dm_test__debug 'assert_status' '=> assertion failed'

    ___subject='Status comparison failed'
    ___reason="expected: ${___expected}\n  actual: ${___result}"
    _dm_test__report_failure "$___subject" "$___reason"
  fi
}

#==============================================================================
#   _   _ _   _ _ _ _   _
#  | | | | |_(_) (_) |_(_) ___  ___
#  | | | | __| | | | __| |/ _ \/ __|
#  | |_| | |_| | | | |_| |  __/\__ \
#   \___/ \__|_|_|_|\__|_|\___||___/
#
#==============================================================================
# TEST UTILITIES
#==============================================================================

#==============================================================================
# Utility function to get the Nth line of the output while validating the given
# one-based index. If the index is invalid, it will behave as a failed
# assertion. This function can be used in the test cases as a helper function
# to access specific lines in the output.
#------------------------------------------------------------------------------
# Globals:
#   ___output
# Arguments:
#   [1] line_index - One-based line index.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Indexed line from the globally captured output.
# STDERR:
#   None
# Status:
#   0 - Line extraction succeeded.
#  !0 - Line extraction failed.
# Tools:
#   echo wc sed test
#==============================================================================
dm_test__utils__get_line_from_output_by_index() {
  ___line_index="$1"
  ___lines="$___output"

  dm_test__debug_list \
    'dm_test__utils__get_line_from_output_by_index' \
    "getting line for index '${___line_index}' from output:" \
    "$___output"

  ___line_count="$(echo "$___lines" | wc --lines)"
  if [ "$___line_index" -gt "$___line_count" ]
  then
    dm_test__debug_list \
      'dm_test__utils__get_line_from_output_by_index' \
      "invalid line index! index should be insite the range of [1-${___line_count}]"

    ___subject='Line index is out of range'
    ___reason="max line index: '${___line_count}'\n   given index: '${___line_index}'"
    _dm_test__report_failure "$___subject" "$___reason"
  fi

  # Getting the indexed line.
  ___line="$(echo "$___lines" | sed "${___line_index}q;d")"

  dm_test__debug_list \
    'dm_test__utils__get_line_from_output_by_index' \
    'line selected:' \
    "$___line"

  echo "$___line"
}

#==============================================================================
#   ____       _            _         _          _
#  |  _ \ _ __(_)_   ____ _| |_ ___  | |__   ___| |_ __   ___ _ __ ___
#  | |_) | '__| \ \ / / _` | __/ _ \ | '_ \ / _ \ | '_ \ / _ \ '__/ __|
#  |  __/| |  | |\ V / (_| | ||  __/ | | | |  __/ | |_) |  __/ |  \__ \
#  |_|   |_|  |_| \_/ \__,_|\__\___| |_| |_|\___|_| .__/ \___|_|  |___/
#                                                 |_|
#==============================================================================
# PRIVATE HELPERS
#==============================================================================

#==============================================================================
# Common failure reporting helper function. It sets the test case to failed,
# generates the error report, appends it to the global error list, then exits
# the test case. There is no point to check further assertions.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__FILE_UNDER_EXECUTION
#   DM_TEST__TEST_UNDER_EXECUTION
#   RED
#   RESET
# Arguments:
#   [1] subject - Subject of the failure.
#   [2] reason - Reason of the failure.
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
#   1 - This function will exit the caller process with status 1.
# Tools:
#   echo printf sed
#==============================================================================
_dm_test__report_failure() {
  ___subject="$1"
  ___reason="$2"

  dm_test__debug \
    '_dm_test__report_failure' \
    'reporting failure and exiting from test case..'

  dm_test__cache__test_result__mark_as_failed

  # Appending the current error report to the error cache file.
  ___test_case="${DM_TEST__FILE_UNDER_EXECUTION}.${DM_TEST__TEST_UNDER_EXECUTION}"
  {
    echo "${RED}${BOLD}${___test_case}${RESET}";
    echo "  ${RED}${___subject}${RESET}:";
    # We want to use printf here to display the inline line newlines, so using
    # only the template parameter, shellcheck can be disabled.
    # shellcheck disable=SC2059
    printf "${RED}${___reason}${RESET}\n" | sed 's/^/    /';
    echo "";
  } | dm_test__cache__global_errors__write_errors

  # Report the concise error report to the standard error.
  >&2 echo "Aborting due to failed assertion: '${___subject}'"

  # Only the first  assertion error should be reported, the latter ones could
  # be the direct result of the first one, so they have minimal new information
  # content. Explicitly exiting after the first report. This should end the
  # testcase subprocess inside the test file subprocess.
  exit 1
}
