#!/bin/sh
#==============================================================================
#    _____ _       _           _   ______
#   / ____| |     | |         | | |  ____|
#  | |  __| | ___ | |__   __ _| | | |__   _ __ _ __ ___  _ __
#  | | |_ | |/ _ \| '_ \ / _` | | |  __| | '__| '__/ _ \| '__|
#  | |__| | | (_) | |_) | (_| | | | |____| |  | | | (_) | |
#   \_____|_|\___/|_.__/ \__,_|_| |______|_|  |_|  \___/|_|
#
#==============================================================================
# GLOBAL ERROR
#==============================================================================

#==============================================================================
# Individual test cases are executed in subshells. Errors happening in there
# should reach the top execution level. This file acts as a global buffer where
# assertion errors can be appended to. If an assertion fails it should write to
# this file via the provided API function.
#==============================================================================

# Variable thar holds the runtime path of the global error file.
DM_TEST__CACHE__RUNTIME__ERRORS='__INVALID__'

#==============================================================================
# Inner function to create and initialize the error cache file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__RUNTIME__ERRORS
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__CACHE__RUNTIME__ERRORS
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_test__cache__global_errors__init() {
  DM_TEST__CACHE__RUNTIME__ERRORS="$(dm_test__cache__create_temp_file)"

  dm_test__debug '_dm_test__cache__global_errors__init' \
    "global errors file created: '${DM_TEST__CACHE__RUNTIME__ERRORS}'"
}

#==============================================================================
# API function to check if errors are present in the global cache file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__RUNTIME__ERRORS
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
#    0 - There are errors present in the global test cache file.
#    1 - No errors in the global test cache file.
#==============================================================================
dm_test__cache__global_errors__has_errors() {
  dm_test__debug 'dm_test__cache__global_errors__has_errors' \
    'checking if there are errors..'

  test -s "$DM_TEST__CACHE__RUNTIME__ERRORS"
}

#==============================================================================
# API function to print the errors from the global error cache file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__RUNTIME__ERRORS
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Global error cache file content.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm_test__cache__global_errors__print_errors() {
  posix_adapter__cat "$DM_TEST__CACHE__RUNTIME__ERRORS"

  dm_test__debug 'dm_test__cache__global_errors__print_errors' \
    'global errors printed'
}

#==============================================================================
# API function to append to the global error cache file. It redirects its
# standard input to the global error cache file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__RUNTIME__ERRORS
# Arguments:
#   None
# STDIN:
#   Error string to be written into the global error cache file.
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
dm_test__cache__global_errors__write_errors() {
  posix_adapter__cat - >> "$DM_TEST__CACHE__RUNTIME__ERRORS"

  dm_test__debug 'dm_test__cache__global_errors__write_errors' \
    'error saved to the global errors file'
}
