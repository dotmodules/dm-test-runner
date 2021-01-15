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
  echo 'Expected [assert] failure.'
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
  echo 'Expected [assert_success] failure.'
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
  echo 'Expected [assert_failure] failure.'
  assert_failure true
}
