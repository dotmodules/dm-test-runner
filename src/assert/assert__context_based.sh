#!/bin/sh
#==============================================================================
#    _____            _            _     _                        _
#   / ____|          | |          | |   | |                      | |
#  | |     ___  _ __ | |_ _____  _| |_  | |__   __ _ ___  ___  __| |
#  | |    / _ \| '_ \| __/ _ \ \/ / __| | '_ \ / _` / __|/ _ \/ _` |
#  | |___| (_) | | | | ||  __/>  <| |_  | |_) | (_| \__ \  __/ (_| |
#   \_____\___/|_| |_|\__\___/_/\_\\__| |_.__/ \__,_|___/\___|\__,_|
#
#==============================================================================
# CONTEXT BASED ASSERTIONS
#==============================================================================

#==============================================================================
# Context based assertions - as the name implies - needs a predefined context
# to be able to run. This context is provided by the 'run' function. To be able
# to use context based assertions you need to run the testable funtion or
# command with the 'run' function. This will save the output and the status of
# the runned function or command into the global assertion context, and you can
# call assertions to test this context. In this way you can check if a function
# or command provided the expected status code and output without running it
# multiple times for each assertions.
#==============================================================================

# Global variables that hold the last execution results of the tested function
# or command.
DM_TEST__ASSERT__RUNTIME__LAST_STATUS='__INVALID__'
DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1='__INVALID__'
DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2='__INVALID__'

#==============================================================================
#  ____
# |  _ \ _   _ _ __  _ __   ___ _ __
# | |_) | | | | '_ \| '_ \ / _ \ '__|
# |  _ <| |_| | | | | | | |  __/ |
# |_| \_\\__,_|_| |_|_| |_|\___|_|
#==============================================================================
# RUNNER FUNCTION
#==============================================================================

#==============================================================================
# Function under test capturer API function. It excepts a list of parameters
# that will be executed while the standar output, standard error and the status
# will be captured and will be put into test case level buffer files. Calling
# the testable function in this way is necessary if we want to use the advanced
# context based assertion functions, as those are working on the output
# variables of this function.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [..] command - Commands and parameters that needs to be executed.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__ASSERT__RUNTIME__LAST_STATUS
#   DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1
#   DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected, as the status of the given command is
#       captured.
#==============================================================================
run() {
  dm_test__debug 'run' "running command: '$*'"

  # Creating temporary files to store the standard output and standard error
  # contents of the executed function.
  DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1="$( \
    dm_test__cache__create_temp_path \
  )"
  DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2="$( \
    dm_test__cache__create_temp_path \
  )"

  # Storing the passed command as a variable is not an option here, because it
  # would be re-splitted on execution.
  if "$@" \
    1>"$DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1" \
    2>"$DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2"
  then
    DM_TEST__ASSERT__RUNTIME__LAST_STATUS="$?"
  else
    DM_TEST__ASSERT__RUNTIME__LAST_STATUS="$?"
  fi

  dm_test__debug_list 'run' 'captured standard output:' \
    "$(dm_tools__cat "$DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1")"
  dm_test__debug_list 'run' 'captured standard error:' \
    "$(dm_tools__cat "$DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2")"

  dm_test__debug 'run' "$( \
    dm_tools__printf '%s' 'captured status: '; \
    dm_tools__echo "'${DM_TEST__ASSERT__RUNTIME__LAST_STATUS}'" \
  )"
}

#==============================================================================
#  ____  _        _
# / ___|| |_ __ _| |_ _   _ ___
# \___ \| __/ _` | __| | | / __|
#  ___) | || (_| | |_| |_| \__ \
# |____/ \__\__,_|\__|\__,_|___/
#==============================================================================
# STATUS ASSERTION
#==============================================================================

#==============================================================================
# Context based assertion function that will evaluate the previously set
# 'status' variable by the 'run' function.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__ASSERT__RUNTIME__LAST_STATUS
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
#   1 - Assertion failed.
#==============================================================================
assert_status() {
  ___expected="$1"
  ___result="$DM_TEST__ASSERT__RUNTIME__LAST_STATUS"

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
    ___assertion='assert_status'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
#  ____  _      _               _               _
# / ___|| |_ __| |   ___  _   _| |_ _ __  _   _| |_
# \___ \| __/ _` |  / _ \| | | | __| '_ \| | | | __|
#  ___) | || (_| | | (_) | |_| | |_| |_) | |_| | |_
# |____/ \__\__,_|  \___/ \__,_|\__| .__/ \__,_|\__|
#==================================|_|=========================================
# STANDARD OUTPUT ASSERTIONS
#==============================================================================

#==============================================================================
# Context based assertion function that will compare the standard output of the
# tested function with the given value.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1
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
#   1 - Assertion failed.
#==============================================================================
assert_output() {
  ___expected="$1"
  ___target_buffer="$DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1"
  ___assertion_name="assert_output"

  _dm_test__assert__assert_output \
    "$___expected" \
    "$___target_buffer" \
    "$___assertion_name"

  ___result="$?"

  if [ "$___result" -eq '2' ]
  then
    dm_test__debug 'assert_output' '=> assertion failed'

    ___subject='Inappropriate assertion function'
    ___reason="$( \
      dm_tools__printf '%s' 'Multiline output should be asserted with '; \
      dm_tools__printf '%s' "assert_output_line_at_index' or "; \
      dm_tools__echo "'assert_output_line_partially_at_index'." \
    )"
    ___assertion='assert_output'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Context based assertion function to check the line count of the command
# output runned with the 'run' function.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1
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
#   1 - Assertion failed.
#==============================================================================
assert_output_line_count() {
  ___expected="$1"
  ___target_buffer="$DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1"
  ___assertion_name="assert_output_line_count"

  _dm_test__assert__assert_line_count \
    "$___expected" \
    "$___target_buffer" \
    "$___assertion_name"
}

#==============================================================================
# Context based assertion function that compares the output line indexed by the
# index parameter with the expected parameter.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1
# Arguments:
#   [1] line_index - One-based line index.
#   [2] expected - Expected content of the given line without the new line
#       character.
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
#   1 - Assertion failed.
#==============================================================================
assert_output_line_at_index() {
  ___line_index="$1"
  ___expected="$2"
  ___target_buffer="$DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1"
  ___assertion_name="assert_output_line_at_index"

  _dm_test__assert__assert_line_at_index \
    "$___line_index" \
    "$___expected" \
    "$___target_buffer" \
    "$___assertion_name"
}

#==============================================================================
# Context based assertion function that compares the output line indexed by the
# index parameter with the expected parameter. The line has to partially match
# only, should be a part of the whole output line.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1
# Arguments:
#   [1] line_index - One-based line index.
#   [2] expected - Expected content of the given line without the new line
#       character.
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
#   1 - Assertion failed.
#==============================================================================
assert_output_line_partially_at_index() {
  ___line_index="$1"
  ___expected="$2"
  ___target_buffer="$DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD1"
  ___assertion_name="assert_output_line_partially_at_index"

  _dm_test__assert__assert_line_partially_at_index \
    "$___line_index" \
    "$___expected" \
    "$___target_buffer" \
    "$___assertion_name"
}

#==============================================================================
#  ____  _      _
# / ___|| |_ __| |   ___ _ __ _ __ ___  _ __
# \___ \| __/ _` |  / _ \ '__| '__/ _ \| '__|
#  ___) | || (_| | |  __/ |  | | | (_) | |
# |____/ \__\__,_|  \___|_|  |_|  \___/|_|
#==============================================================================
# STANDARD ERROR ASSERTIONS
#==============================================================================

#==============================================================================
# Context based assertion function that will fail if there are any standard
# error captured output.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2
# Arguments:
#   None
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
#   1 - Assertion failed.
#==============================================================================
assert_no_error() {
  ___target_buffer="$DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2"

  if [ -s "$___target_buffer" ]
  then
    dm_test__debug 'assert_no_error' '=> assertion failed'

    ___subject='Standard output was captured.'
    ___reason="$( \
      dm_tools__printf '%s' 'The tested functionality should not have '; \
      dm_tools__echo 'emitted content to the standard error output: '; \
      dm_tools__echo '"""'; \
      dm_tools__cat "$___target_buffer"; \
      dm_tools__echo '"""'; \
    )"
    ___assertion='assert_no_error'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}
#==============================================================================
# Context based assertion function that will compare the standard error output
# of the tested function with the given value.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2
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
#   1 - Assertion failed.
#==============================================================================
assert_error() {
  ___expected="$1"
  ___target_buffer="$DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2"
  ___assertion_name="assert_error"

  _dm_test__assert__assert_output \
    "$___expected" \
    "$___target_buffer" \
    "$___assertion_name"

  ___result="$?"

  if [ "$___result" -eq '2' ]
  then
    dm_test__debug 'assert_error' '=> assertion failed'

    ___subject='Inappropriate assertion function'
    ___reason="$( \
      dm_tools__printf '%s' 'Multiline output should be asserted with '; \
      dm_tools__printf '%s' "'assert_error_line_at_index' or "; \
      dm_tools__echo "'assert_error_line_partially_at_index'." \
    )"
    ___assertion='assert_error'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Context based assertion function to check the line count of the command
# error output runned with the 'run' function.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2
# Arguments:
#   [1] expected_line_count - Expected error output line count.
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
#   1 - Assertion failed.
#==============================================================================
assert_error_line_count() {
  ___expected="$1"
  ___target_buffer="$DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2"
  ___assertion_name="assert_error_line_count"

  _dm_test__assert__assert_line_count \
    "$___expected" \
    "$___target_buffer" \
    "$___assertion_name"
}

#==============================================================================
# Context based assertion function that compares the error output line indexed
# by the index parameter with the expected parameter.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2
# Arguments:
#   [1] line_index - One-based line index.
#   [2] expected - Expected content of the given line without the new line
#       character.
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
#   1 - Assertion failed.
#==============================================================================
assert_error_line_at_index() {
  ___line_index="$1"
  ___expected="$2"
  ___target_buffer="$DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2"
  ___assertion_name="assert_error_line_at_index"

  _dm_test__assert__assert_line_at_index \
    "$___line_index" \
    "$___expected" \
    "$___target_buffer" \
    "$___assertion_name"
}

#==============================================================================
# Context based assertion function that compares the error output line indexed
# by the index parameter with the expected parameter. The line has to partially
# match only, should be a part of the whole error output line.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2
# Arguments:
#   [1] line_index - One-based line index.
#   [2] expected - Expected content of the given line without the new line
#       character.
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
#   1 - Assertion failed.
#==============================================================================
assert_error_line_partially_at_index() {
  ___line_index="$1"
  ___expected="$2"
  ___target_buffer="$DM_TEST__ASSERT__RUNTIME__OUTPUT_BUFFER__FD2"
  ___assertion_name="assert_error_line_partially_at_index"

  _dm_test__assert__assert_line_partially_at_index \
    "$___line_index" \
    "$___expected" \
    "$___target_buffer" \
    "$___assertion_name"
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
# Common function to compare context based outputs.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] expected_output - Expected output of the previously run function.
#   [2] target_buffer - Target buffer that should be used.
#   [3] assertion_name - Name of the original assertion.
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
#   1 - Assertion failed.
#   2 - Inappropriate assertion function.
#==============================================================================
_dm_test__assert__assert_output() {
  ___expected="$1"
  ___target_buffer="$2"
  ___assertion_name="$3"

  ___result="$(dm_tools__cat "$___target_buffer")"
  ___count="$(dm_tools__wc --lines < "$___target_buffer")"

  if [ "$___count" -gt '1' ]
  then
    return 2
  fi

  dm_test__debug '_dm_test__assert__assert_output' \
    'asserting output:'
  dm_test__debug '_dm_test__assert__assert_output' \
    "- expected: '${___expected}'"
  dm_test__debug '_dm_test__assert__assert_output' \
    "- result:   '${___result}'"

  if [ "$___result" = "$___expected" ]
  then
    dm_test__debug '_dm_test__assert__assert_output' \
      '=> assertion succeeded'
  else
    dm_test__debug '_dm_test__assert__assert_output' \
      '=> assertion failed'

    ___subject='Output comparison failed'
    ___reason="expected: '${___expected}'\n  actual: '${___result}'"
    ___assertion="$___assertion_name"
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Common function to check line counts for the context based captured outputs.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] expected_line_count - Expected output line count.
#   [2] target_buffer - Target buffer that should be used.
#   [3] assertion_name - Name of the original assertion.
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
#   1 - Assertion failed.
#==============================================================================
_dm_test__assert__assert_line_count() {
  ___expected="$1"
  ___target_buffer="$2"
  ___assertion_name="$3"

  ___result="$(dm_tools__wc --lines < "$___target_buffer")"

  dm_test__debug '_dm_test__assert__assert_line_count' \
    'asserting output line count:'
  dm_test__debug '_dm_test__assert__assert_line_count' \
    "- expected: '${___expected}'"
  dm_test__debug '_dm_test__assert__assert_line_count' \
    "- result:   '${___result}'"

  if [ "$___result" -eq "$___expected" ]
  then
    dm_test__debug '_dm_test__assert__assert_line_count' \
      '=> assertion succeeded'
  else
    dm_test__debug '_dm_test__assert__assert_line_count' \
      '=> assertion failed'

    ___subject='Output line count mismatch'
    ___reason="expected: '${___expected}'\n  actual: '${___result}'"
    ___assertion="$___assertion_name"
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Common context based assertion function that compares the output line indexed
# by the index parameter with the expected parameter.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] line_index - One-based line index.
#   [2] expected - Expected content of the given line without the new line
#       character.
#   [3] target_buffer - Target buffer that should be used.
#   [4] assertion_name - Name of the original assertion.
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
#   1 - Assertion failed.
#==============================================================================
_dm_test__assert__assert_line_at_index() {
  ___index="$1"
  ___expected="$2"
  ___target_buffer="$3"
  ___assertion_name="$4"

  if ___result="$( \
    dm_test__get_line_from_output_buffer_by_index \
      "$___index" \
      "$___target_buffer" \
  )"
  then
    # Line extraction succeeded, the '__result' variable contains the extracted
    # line.
    :
  else
    # As the line extraction function returned a nonzero status, the line
    # extraction failed, and the error was already reported. Since it is
    # happened in a subshell to obtain the output from it, the execution won't
    # stopped here, so we should simply return from here.
    return
  fi

  dm_test__debug '_dm_test__assert__assert_line_at_index' \
    'asserting output line at index:'
  dm_test__debug '_dm_test__assert__assert_line_at_index' \
    "- expected: '${___expected}'"
  dm_test__debug '_dm_test__assert__assert_line_at_index' \
    "- result:   '${___result}'"

  if [ "$___result" = "$___expected" ]
  then
    dm_test__debug '_dm_test__assert__assert_line_at_index' \
      '=> assertion succeeded'
  else
    dm_test__debug '_dm_test__assert__assert_line_at_index' \
      '=> assertion failed'

    ___subject="Line at index '${___index}' differs from expected"
    ___reason="expected: '${___expected}'\n  actual: '${___result}'"
    ___assertion="$___assertion_name"
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Common context based assertion function that compares the output line indexed
# by the index parameter with the expected parameter. The line has to partially
# match only, should be a part of the whole output line.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] line_index - One-based line index.
#   [2] expected - Expected content of the given line without the new line
#       character.
#   [3] target_buffer - Target buffer that should be used.
#   [4] assertion_name - Name of the original assertion.
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
#   1 - Assertion failed.
#==============================================================================
_dm_test__assert__assert_line_partially_at_index() {
  ___index="$1"
  ___expected="$2"
  ___target_buffer="$3"
  ___assertion_name="$4"

  if ___result="$( \
    dm_test__get_line_from_output_buffer_by_index \
      "$___index" \
      "$___target_buffer" \
  )"
  then
    # Line extraction succeeded, the '__result' variable contains the extracted
    # line.
    :
  else
    # As the line extraction function returned a nonzero status, the line
    # extraction failed, and the error was already reported. Since it is
    # happened in a subshell to obtain the output from it, the execution won't
    # stopped here, so we should simply return from here.
    return
  fi

  dm_test__debug '_dm_test__assert__assert_line_partially_at_index' \
    'asserting output line at index partially:'
  dm_test__debug '_dm_test__assert__assert_line_partially_at_index' \
    "- pattern: '${___expected}'"
  dm_test__debug '_dm_test__assert__assert_line_partially_at_index' \
    "- target:   '${___result}'"

  if dm_tools__echo "$___result" | dm_tools__grep --silent "$___expected"
  then
    dm_test__debug '_dm_test__assert__assert_line_partially_at_index' \
      '=> assertion succeeded'
  else
    dm_test__debug '_dm_test__assert__assert_line_partially_at_index' \
      '=> assertion failed'

    ___subject="Line at index '${___index}' differs from expected'"
    ___reason="expected: '${___expected}'\n  actual: '${___result}'"
    ___assertion="$___assertion_name"
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}
