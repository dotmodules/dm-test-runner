#!/bin/sh
#==============================================================================
# OUTPUT CAPTURING
#==============================================================================

#==============================================================================
# During test case execution the test runner captures the standard output,
# standard error and the file descriptor 3 as an optional debugger ouput. The
# captured content will be only visible if the test case fails. Having captured
# standard error content makes the test case automatically fail.
#
# Note that the captured outputs might not be printed in the exact order as the
# test case executes them. This is due to the way the test runner captures the
# outputs with processing commands running as a background command, having no
# control over the timings.
#==============================================================================

test__captured_output_is_hidden_on_success() {
  dm_tools__echo "this message won't be visible"
  >&3 dm_tools__echo "this debug message won't be visible"
}

test__captured_output_is_visible_on_failure() {
  dm_tools__echo 'this message is visible'
  >&3 dm_tools__echo 'this debug message is visible'
  assert false
}

test__standard_error_makes_the_testcase_fail() {
  dm_tools__echo 'this message is visible'
  >&2 dm_tools__echo 'standard error -> test case will fail'
  >&3 dm_tools__echo 'this debug message is visible'
}

test__standard_error_makes_the_testcase_fail__command() {
  dm_tools__echo 'this message is visible'
  >&3 dm_tools__echo 'this debug message is visible'
  dm_tools__cat 'nonexistent_file'
}
