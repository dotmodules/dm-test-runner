#==============================================================================
#   _______        _      _____                          _____ _____
#  |__   __|      | |    / ____|                   /\   |  __ \_   _|
#     | | ___  ___| |_  | |     __ _ ___  ___     /  \  | |__) || |
#     | |/ _ \/ __| __| | |    / _` / __|/ _ \   / /\ \ |  ___/ | |
#     | |  __/\__ \ |_  | |___| (_| \__ \  __/  / ____ \| |    _| |_
#     |_|\___||___/\__|  \_____\__,_|___/\___| /_/    \_\_|   |_____|
#
#==============================================================================

#==============================================================================
# This file contains the API functions that the test cases can use to test
# their functionality. Most of the assertion functions require the usage of the
# provided `run` function to run the testable function with in order to capture
# the output and status of the testable function.
#==============================================================================

#==============================================================================
# TARGET FUNCTION RUNNER
#==============================================================================
#   ____
#  |  _ \ _   _ _ __
#  | |_) | | | | '_ \
#  |  _ <| |_| | | | |
#  |_| \_\\__,_|_| |_|
#
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
#               paremeter list.
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
  if ___output="$("$@")"
  then
    ___status="$?"
  else
    ___status="$?"
  fi
}

#==============================================================================
# ASSERTION FUNCTIONS
#==============================================================================
#      _                      _
#     / \   ___ ___  ___ _ __| |_
#    / _ \ / __/ __|/ _ \ '__| __|
#   / ___ \\__ \__ \  __/ |  | |_
#  /_/   \_\___/___/\___|_|   \__|
#
#==============================================================================

#==============================================================================
# Simple assertion helper function that expects a list of parameters that will
# be interpreted as a test command. Based on that evaluation the assertion
# result will be decided. It is common to use the 'test' command to write
# simple assertions, but in general anything can be used. This assertion
# function that does not require a prior call to the 'run' command to have the
# test output variables set.
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
  if $___commands
  then
    :
  else
    ___subject="Assertion failed"
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
#   None
#==============================================================================
assert_file() {
  ___file_path="$1"

  if [ -f "$___file_path" ]
  then
    :
  else
    ___subject="Invalid file path"
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
#   None
#==============================================================================
assert_output() {
  ___expected="$1"
  ___result="$___output"

  if [ "$___result" = "$___expected" ]
  then
    :
  else
    ___subject="Output comparison failed"
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
#   echo wc
#==============================================================================
assert_output_line_count() {
  ___expected="$1"
  ___result="$(echo "$___output" | wc --lines)"
  if [ "$___result" -eq "$___expected" ]
  then
    :
  else
    ___subject="Output line count mismatch"
    ___reason="expected: '${___expected}'\n  actual: '${___result}'"
    _dm_test__report_failure "$___subject" "$___reason"
  fi
}

#==============================================================================
# Advanced assertion function that compares the output line indexed by the index
# parameter with the expected parameter.
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
#   None
#==============================================================================
assert_line_at_index() {
  ___index="$1"
  ___expected="$2"

  ___line="$(dm_test__utils__get_line_from_output_by_index "$___index" "$___output")"

  if [ "$___line" = "$___expected" ]
  then
    :
  else
    ___subject="Line at index '${___index}' differs from expected'"
    ___reason="expected: '${___expected}'\n  actual: '${___line}'"
    _dm_test__report_failure "$___subject" "$___reason"
  fi
}

#==============================================================================
# Advanced assertion function that compares the output line indexed by the index
# parameter with the expected parameter. The line has to partially match only.
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

  ___line="$(dm_test__utils__get_line_from_output_by_index "$___index" "$___output")"

  if echo "$___line" | grep --silent "$___expected"
  then
    :
  else
    ___subject="Line at index '${___index}' differs from expected'"
    ___reason="expected: '${___expected}'\n  actual: '${___line}'"
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
#   None
#==============================================================================
assert_status() {
  ___expected="$1"
  ___result="$___status"

  if [ "$___result" = "$___expected" ]
  then
    :
  else
    ___subject="Status comparison failed"
    ___reason="expected: ${___expected}\n  actual: ${___result}"
    _dm_test__report_failure "$___subject" "$___reason"
  fi
}

#==============================================================================
# TEST UTILITIES
#==============================================================================
#   _   _ _   _ _ _ _   _
#  | | | | |_(_) (_) |_(_) ___  ___
#  | | | | __| | | | __| |/ _ \/ __|
#  | |_| | |_| | | | |_| |  __/\__ \
#   \___/ \__|_|_|_|\__|_|\___||___/
#
#==============================================================================

#==============================================================================
# Utility function to get the Nth line of the output while validating the given
# one-based index. If the index is invalid, it will behave as a failed
# assertion. This function can be used in the test cases as a helper function
# to access specific lines in the output.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] line_index - One-based line index.
#   [2] lines - Multiline string the line should be selected from.
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
#   echo wc sed
#==============================================================================
dm_test__utils__get_line_from_output_by_index() {
  ___line_index="$1"
  ___lines="$2"

  ___line_count="$(echo "$___lines" | wc --lines)"
  if [ "$___line_index" -gt "$___line_count" ]
  then
    ___subject="Line index is out of range"
    ___reason="max line index: '${___line_count}'\n   given index: '${___line_index}'"
    _dm_test__report_failure "$___subject" "$___reason"
  fi

  # Getting the indexed line.
  echo "$___lines" | sed "${___line_index}q;d"
}

#==============================================================================
# PRIVATE HELPERS
#==============================================================================
#   ____       _            _         _          _
#  |  _ \ _ __(_)_   ____ _| |_ ___  | |__   ___| |_ __   ___ _ __ ___
#  | |_) | '__| \ \ / / _` | __/ _ \ | '_ \ / _ \ | '_ \ / _ \ '__/ __|
#  |  __/| |  | |\ V / (_| | ||  __/ | | | |  __/ | |_) |  __/ |  \__ \
#  |_|   |_|  |_| \_/ \__,_|\__\___| |_| |_|\___|_| .__/ \___|_|  |___/
#                                                 |_|
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

  dm_test__cache__set_test_case_failed

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
  } | dm_test__cache__errors__write_errors

  # Report the concise error report to the standard error.
  >&2 echo "Aborting due to failed assertion: '${___subject}'"

  # Only the first  assertion error should be reported, the latter ones could
  # be the direct result of the first one, so they have minimal new information
  # content. Explicitly exiting after the first report. This should end the
  # testcase subprocess inside the test file subprocess.
  exit 1
}
