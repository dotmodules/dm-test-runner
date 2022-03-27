#!/bin/sh
#==============================================================================
#    _____ _       _           _   ______    _ _
#   / ____| |     | |         | | |  ____|  (_) |
#  | |  __| | ___ | |__   __ _| | | |__ __ _ _| |_   _ _ __ ___  ___
#  | | |_ | |/ _ \| '_ \ / _` | | |  __/ _` | | | | | | '__/ _ \/ __|
#  | |__| | | (_) | |_) | (_| | | | | | (_| | | | |_| | | |  __/\__ \
#   \_____|_|\___/|_.__/ \__,_|_| |_|  \__,_|_|_|\__,_|_|  \___||___/
#
#==============================================================================
# GLOBAL FAILURES
#==============================================================================

#==============================================================================
# Global cache file that holds the count of all failed test cases.
#==============================================================================

# Variable thar holds the runtime path of the global test case failure count
# file.
POSIX_TEST__CACHE__RUNTIME__GLOBAL_FAILURES='__INVALID__'

#==============================================================================
# Inner function to create and initialize the global result file. Writing an
# initial zero to it. In case of a failed test case this number will be
# increased.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CACHE__RUNTIME__GLOBAL_FAILURES
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   POSIX_TEST__CACHE__RUNTIME__GLOBAL_FAILURES
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_posix_test__cache__global_failures__init() {
  POSIX_TEST__CACHE__RUNTIME__GLOBAL_FAILURES="$( \
    posix_test__cache__create_temp_file \
  )"
  posix_adapter__echo '0' > "$POSIX_TEST__CACHE__RUNTIME__GLOBAL_FAILURES"

  posix_test__debug '_posix_test__cache__global_failures__init' \
    "failure count file created: '${POSIX_TEST__CACHE__RUNTIME__GLOBAL_FAILURES}'"
}

#==============================================================================
# Function to increase the global failure cache file's content.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CACHE__RUNTIME__GLOBAL_FAILURES
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
#==============================================================================
posix_test__cache__global_failure__increment() {
  _posix_test__utils__increment_file_content \
    "$POSIX_TEST__CACHE__RUNTIME__GLOBAL_FAILURES"

  posix_test__debug 'posix_test__cache__global_failure__increment' \
    'global failure count incremented'
}

#==============================================================================
# Function to get the global failures cache file's content.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CACHE__RUNTIME__GLOBAL_FAILURES
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Content of the global count cache file.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
posix_test__cache__global_failure__get() {
  ___count="$(posix_adapter__cat "$POSIX_TEST__CACHE__RUNTIME__GLOBAL_FAILURES")"
  posix_adapter__echo "$___count"

  posix_test__debug 'posix_test__cache__global_failure__get' \
    "global failure count value returned: '${___count}'"
}

#==============================================================================
# Function to decide if a failure has happened.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CACHE__RUNTIME__GLOBAL_FAILURES
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
#   0 - Global failures count is nonzero.
#   1 - Global failures count is zero.
#==============================================================================
posix_test__cache__global_failure__failures_happened() {
  posix_test__debug 'posix_test__cache__global_failure__failures_happened' \
    'checking if there were failures..'

  posix_adapter__grep \
    --silent \
    --invert-match \
    '^0$' \
    "$POSIX_TEST__CACHE__RUNTIME__GLOBAL_FAILURES"
}
