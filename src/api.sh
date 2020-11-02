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
# TARGET RUNNER
#==============================================================================
#   ____
#  |  _ \ _   _ _ __
#  | |_) | | | | '_ \
#  |  _ <| |_| | | | |
#  |_| \_\\__,_|_| |_|
#
#==============================================================================

#==============================================================================
# Function under test runner. It excepts a list of parameters that will be
# executed while the output and the status will be captured and will be put
# into output variables.
# Calling the testable feature in this way is necessary if we want tot use the
# advanced assertion functions.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - Expects a list of arguments that will be evaluated.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - output - Captured output of the evaluated command passedin as a paremeter
#            list.
# - status - Captured status of the evaluated command.
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
run() {
  ___output="$("$@")"
  ___status="$?"
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
# simple assertions, but in general anything can be used.
# This is the only assertion function that does not require a prior call to the
# 'run' command to have the test output variables set.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - Expects a list of arguments that will be evaluated.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
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
# Simple assertion that checks if the given file path is valid and it is for a
# file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - Expects a list of arguments that will be evaluated.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
assert_file() {
  # Disabling SC2124 here as we won't modify the assigned 'commands' variable.
  # shellcheck disable=SC2124
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
# Advanced assertion command that will evaluate the previously set 'output'
# variable by the 'run' function.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - expected_output - Expected output of the previously run function.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
assert_output() {
  ___expected="$1"
  ___result="$___output"
  if test "$___result" = "$___expected"
  then
    :
  else
    ___subject="Output comparison failed"
    ___reason="expected: '${___expected}'\n  actual: '${___result}'"
    _dm_test__report_failure "$___subject" "$___reason"
  fi
}

#==============================================================================
# Advanced assertion command to check the line count of the command output
# runned with the 'run' function.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - expected_line_count - Expected output line count.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
assert_output_line_count() {
  ___expected="$1"
  ___result="$(echo "$___output" | wc --lines)"
  if test "$___result" -eq "$___expected"
  then
    :
  else
    ___subject="Output line count mismatch"
    ___reason="expected: '${___expected}'\n  actual: '${___result}'"
    _dm_test__report_failure "$___subject" "$___reason"
  fi
}

#==============================================================================
# Advanced assertion command that compares the output line indexed by the index
# parameter with the expected parameter.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - line_index - One-based line index.
# - expected - Expected content of the given line without the new line
#              character.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
assert_line_at_index() {
  ___index="$1"
  ___expected="$2"

  ___line_count="$(echo "$___output" | wc --lines)"
  if [ "$___index" -gt "$___line_count" ]
  then
    ___subject="Line index is out of range"
    ___reason="max line index: '${___line_count}'\n   given index: '${___index}'"
    _dm_test__report_failure "$___subject" "$___reason"
  fi

  # Getting the indexed line.
  ___line="$(echo "$___output" | sed "${___index}q;d")"

  if test "$___line" = "$___expected"
  then
    :
  else
    ___subject="Line at index '${___index}' differs from expected'"
    ___reason="expected: '${___expected}'\n  actual: '${___line}'"
    _dm_test__report_failure "$___subject" "$___reason"
  fi
}

#==============================================================================
# Advanced assertion command that compares the output line indexed by the index
# parameter with the expected parameter.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - line_index - One-based line index.
# - expected - Expected content of the given line without the new line
#              character.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
assert_line_partially_at_index() {
  ___index="$1"
  ___expected="$2"

  ___line="$(dm_test__utils__get_line_from_output_by_index "$___index")"

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
# Advanced assertion command that will evaluate the previously set 'status'
# variable by the 'run' function.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - expected_status - Expected status of the previously run function.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
assert_status() {
  ___expected="$1"
  ___result="$___status"
  if test "$___result" = "$___expected"
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
# one-based index.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - line_index - One-based line index.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Indexed line from the globally captured output.
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_test__utils__get_line_from_output_by_index() {
  ___index="$1"

  ___line_count="$(echo "$___output" | wc --lines)"
  if [ "$___index" -gt "$___line_count" ]
  then
    ___subject="Line index is out of range"
    ___reason="max line index: '${___line_count}'\n   given index: '${___index}'"
    _dm_test__report_failure "$___subject" "$___reason"
  fi

  # Getting the indexed line.
  echo "$___output" | sed "${___index}q;d"
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
# Common failure reporting helper function.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__FILE_UNDER_EXECUTION
# - DM_TEST__TEST_UNDER_EXECUTION
# - DM_TEST__CACHE__ERRORS
# - RED
# - RESET
# Arguments
# - subject - Subject of the failure.
# - reason - Reason of the failure.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__report_failure() {
  ___subject="$1"
  ___reason="$2"

  _dm_test__set_test_case_failed

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
  } >> "$DM_TEST__CACHE__ERRORS"

  # Report the concise error report to the standard error.
  >&2 echo "Aborting due to failed assertion: '${___subject}'"

  # Only the first  assertion error should be reported, the latter ones could
  # be the direct result of the first one, so they have minimal new information
  # content. Explicitly exiting after the first report. This should end the
  # testcase subprocess inside the test file subprocess.
  exit 1
}
