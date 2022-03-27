#!/bin/sh
#==============================================================================
#   _    _ _   _ _ _ _   _
#  | |  | | | (_) (_) | (_)
#  | |  | | |_ _| |_| |_ _  ___  ___
#  | |  | | __| | | | __| |/ _ \/ __|
#  | |__| | |_| | | | |_| |  __/\__ \
#   \____/ \__|_|_|_|\__|_|\___||___/
#
#==============================================================================
# TEST UTILITIES
#==============================================================================

#==============================================================================
# This file contains the common utilities and test helpers that will be used by
# the specific assertion functions.
#==============================================================================

#==============================================================================
# Utility function to get the N-th line of the output while validating the given
# one-based index. If the index is invalid, it will behave as a failed
# assertion. This function can be used in the test cases as a helper function to
# access specific lines in the captured output.
#
# This function is intended to be used in the test cases if needed, hence the
# missing assert naming scope.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] line_index - One-based line index.
#   [2] buffer - Buffer file path that contains the output lines.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Indexed line if the index is valid.
# STDERR:
#   None
# Status:
#   0 - Line extraction succeeded.
#   1 - Line extraction failed.
#==============================================================================
dm_test__get_line_from_output_buffer_by_index() {
  ___line_index="$1"
  ___buffer="$2"

  dm_test__debug_list 'dm_test__get_line_from_output_buffer_by_index' \
    "getting line for index '${___line_index}' from output:" \
    "$(posix_adapter__cat "$___buffer")"

  ___line_count="$(posix_adapter__wc --lines < "$___buffer")"
  ___char_count="$(posix_adapter__wc --chars < "$___buffer")"

  if [ "$___line_count" -eq '0' ] && [ "$___char_count" -eq '0' ]
  then
    dm_test__debug 'dm_test__get_line_from_buffer_output_by_index' \
      'no output was captured in the target buffer!'

    ___subject='No output to index'
    ___reason='No output was captured in the target buffer, nothing to compare!'
    ___assertion='utils__get_line_from_output_by_index'
    _dm_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
  fi

  if [ "$___line_count" -eq '0' ] && [ "$___char_count" -gt '0' ]
  then
    dm_test__debug 'dm_test__get_line_from_buffer_output_by_index' \
      'correcting line count to 1 as no newline character is present in buffer'
    ___line_count='1'
  fi

  if [ "$___line_index" -gt "$___line_count" ] || [ "$___line_index" -lt '1' ]
  then
    dm_test__debug 'dm_test__get_line_from_buffer_output_by_index' \
      "invalid line index! should be inside the range of [1-${___line_count}]"

    ___subject='Line index is out of range'
    ___reason="$( \
      posix_adapter__echo "index should be in range: [1-${___line_count}]"; \
      posix_adapter__echo "given index: '${___line_index}'" \
    )"
    ___assertion='utils__get_line_from_output_by_index'
    _dm_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
  fi

  # Getting the indexed line.
  ___line="$(posix_adapter__sed --expression "${___line_index}q;d" "$___buffer")"

  dm_test__debug_list 'dm_test__get_line_from_output_buffer_by_index' \
    'line selected:' "$___line"

  posix_adapter__echo "$___line"
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
# Common failure reporting helper function. It sets the test case to failed,
# generates the error report, appends it to the global error list, then exits
# the test case. There is no point to check further assertions.
#------------------------------------------------------------------------------
# Globals:
#   RED
#   BOLD
#   RESET
# Arguments:
#   [1] subject - Subject of the failure.
#   [2] reason - Reason of the failure.
#   [3] assertion - Assertion function name that produced that failed.
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
#==============================================================================
_dm_test__assert__report_failure() {
  ___subject="$1"
  ___reason="$2"
  ___assertion="$3"

  dm_test__debug '_dm_test__assert__report_failure' \
    'reporting failure and exiting from test case..'

  dm_test__cache__test_result__mark_as_failed

  ___test_case_identifier="$( \
    dm_test__test_case__get_current_test_case_identifier \
  )"
  # Appending the current error report to the error cache file.
  {
    posix_adapter__echo "${RED}${BOLD}${___test_case_identifier}${RESET}";
    posix_adapter__printf '%s' "  ${RED}${___subject}: ";
    posix_adapter__echo "[${BOLD}${___assertion}${RESET}${RED}]${RESET}";
    # We want to use printf here to display the inline line newlines, so using
    # only the template parameter, shellcheck can be disabled.
    # shellcheck disable=SC2059
    posix_adapter__printf "${RED}${___reason}${RESET}\n" | \
      posix_adapter__sed --expression 's/^/    /';
    posix_adapter__echo "";
  } | dm_test__cache__global_errors__write_errors

  # Report the concise error report to the standard error.
  >&2 posix_adapter__printf '%s' "${___assertion} | "
  >&2 posix_adapter__printf '%s' 'Aborting due to failed assertion: '
  >&2 posix_adapter__echo "${BOLD}${___subject}${RESET}."

  # Only the first  assertion error should be reported, the latter ones could
  # be the direct result of the first one, so they have minimal new information
  # content. Explicitly exiting after the first report. This should end the
  # test case subprocess inside the test file subprocess.
  exit 1
}
