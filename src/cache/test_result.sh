#==============================================================================
#  _____         _     ____                 _ _
# |_   _|__  ___| |_  |  _ \ ___  ___ _   _| | |_
#   | |/ _ \/ __| __| | |_) / _ \/ __| | | | | __|
#   | |  __/\__ \ |_  |  _ <  __/\__ \ |_| | | |_
#   |_|\___||___/\__| |_| \_\___||___/\__,_|_|\__|
#
#==============================================================================
# TEST RESULT CACHE
#==============================================================================

#==============================================================================
# Individual test cases are executed in a subshell of a subshell. Errors
# happening there should change the test case result from success to error, and
# the most trivial way to do that is this test result cache file. Before each
# test case run, this file wil be initialized to success. If an assertion
# fails, it should set this file content to failed via the provided API
# function. Further API function are available to examine the test result file
# content.
#==============================================================================

# Variable thar holds the runtime path of the test result cache file.
DM_TEST__CACHE__TEST_RESULT="__INVALID__"

#==============================================================================
# Inner function to create and initialize the test result file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__TEST_RESULT
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__CACHE__TEST_RESULT
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   touch echo
#==============================================================================
_dm_test__cache__test_result__init() {
  DM_TEST__CACHE__TEST_RESULT="$(dm_test__cache__create_temp_file)"
  touch "$DM_TEST__CACHE__TEST_RESULT"

  dm_test__debug \
    '_dm_test__cache__test_result__init' \
    "test result temp file created: '${DM_TEST__CACHE__TEST_RESULT}'"
}

#==============================================================================
# Function that initializes the test result cache file with the success
# content. After this only failure content would be written to this file by the
# test case assertions.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__TEST_RESULT
#   DM_TEST__CONSTANT__TEST_RESULT__SUCCESS
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
#   echo
#==============================================================================
dm_test__cache__test_result__init() {
  echo "$DM_TEST__CONSTANT__TEST_RESULT__SUCCESS" > "$DM_TEST__CACHE__TEST_RESULT"

  dm_test__debug \
    'dm_test__cache__test_result__init' \
    'test case initialized to SUCCESS'
}

#==============================================================================
# Function that sets the currently executing test case result as a failure.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__TEST_RESULT
#   DM_TEST__CONSTANT__TEST_RESULT__FAILURE
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
#   echo
#==============================================================================
dm_test__cache__test_result__mark_as_failed() {
  echo "$DM_TEST__CONSTANT__TEST_RESULT__FAILURE" > "$DM_TEST__CACHE__TEST_RESULT"

  dm_test__debug \
    'dm_test__cache__test_result__mark_as_failed' \
    'test case marked as FAILED'
}

#==============================================================================
# Function that evaulates the test case result cache file content.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__TEST_RESULT
#   DM_TEST__CONSTANT__TEST_RESULT__SUCCESS
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
#   0 - Test case was succeeded.
#   1 - Test case was failed.
# Tools:
#   grep
#==============================================================================
dm_test__cache__test_result__was_success() {
  if grep --silent "$DM_TEST__CONSTANT__TEST_RESULT__SUCCESS" "$DM_TEST__CACHE__TEST_RESULT"
  then
    dm_test__debug \
      'dm_test__cache__test_result__was_success' \
      'test result cache file content: SUCCESS'
    return 0
  else
    dm_test__debug \
      'dm_test__cache__test_result__was_success' \
      'test result cache file content: FAILURE'
    return 1
  fi
}
