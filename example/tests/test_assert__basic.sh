#!/bin/sh
#==============================================================================
# BASIC ASSERTIONS - Don't require special setup.
#==============================================================================

#==============================================================================
# ASSERT
#------------------------------------------------------------------------------
# Assert any command or function available in the context of the test case.
# The assertion will succeed on a status code 0 and fail on every other.
#==============================================================================

test__assert() {
  assert true
}

test__assert__common_use_case() {
  # This is the most common use case fort he 'assert' function. It executes a
  # simple test to compare values.
  assert test '42' -eq '42'
}

# These tests are the failure cases picked up by another test runner. In this
# way the valid and failure cases are in one place.
should_fail__assert() {
  posix_adapter__echo 'Expected [assert] failure.'
  assert false
}

#==============================================================================
# ASSERT_SUCCESS
#------------------------------------------------------------------------------
# Same as the regular 'assert' function. Exists only to have a matching
# complementer for the 'assert_failure' function.
#==============================================================================

test__assert_success() {
  assert_success true
}

should_fail__assert_success() {
  posix_adapter__echo 'Expected [assert_success] failure.'
  assert_success false
}

#==============================================================================
# ASSERT_FAILURE
#------------------------------------------------------------------------------
# Succeeds only if the given command or function ends up with a nonzero status
# code.
#==============================================================================

test__assert_failure() {
  assert_failure false
}

should_fail__assert_failure() {
  posix_adapter__echo 'Expected [assert_failure] failure.'
  assert_failure true
}

#==============================================================================
# ASSERT_EQUAL
#------------------------------------------------------------------------------
# Succeeds only if the given two string parameters are equal.
#==============================================================================

test__assert_equal__basic_case() {
  assert_equal 'string' 'string'
}

test__assert_equal__plain_numbers() {
  assert_equal 42 42
}

test__assert_equal__no_resplitting() {
  param_1='string string  string'
  param_2='string string  string'
  assert_equal "$param_1" "$param_2"
}

should_fail__assert_equal__different_string_literal() {
  assert_equal 'one' 'two'
}

should_fail__assert_equal__different_plain_numbers() {
  assert_equal 42 43
}

should_fail__assert_equal__no_resplitting_on_error() {
  param_1='string string  string 1'
  param_2='string string  string 2'
  assert_equal "$param_1" "$param_2"
}
