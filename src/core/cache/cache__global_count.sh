#!/bin/sh
#==============================================================================
#    _____ _       _           _    _____                  _
#   / ____| |     | |         | |  / ____|                | |
#  | |  __| | ___ | |__   __ _| | | |     ___  _   _ _ __ | |_
#  | | |_ | |/ _ \| '_ \ / _` | | | |    / _ \| | | | '_ \| __|
#  | |__| | | (_) | |_) | (_| | | | |___| (_) | |_| | | | | |_
#   \_____|_|\___/|_.__/ \__,_|_|  \_____\___/ \__,_|_| |_|\__|
#
#==============================================================================
# GLOBAL COUNT
#==============================================================================

#==============================================================================
# Global cache file that holds the count of all executed test cases.
#==============================================================================

# Variable thar holds the runtime path of the global test case count file.
POSIX_TEST__CACHE__RUNTIME__GLOBAL_COUNT='__INVALID__'

#==============================================================================
# Inner function to create and initialize the global count file. Writing an
# initial zero value to it. This number will be increased during each test case
# execution.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CACHE__RUNTIME__GLOBAL_COUNT
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   POSIX_TEST__CACHE__RUNTIME__GLOBAL_COUNT
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_posix_test__cache__global_count__init() {
  POSIX_TEST__CACHE__RUNTIME__GLOBAL_COUNT="$(posix_test__cache__create_temp_file)"
  posix_adapter__echo '0' > "$POSIX_TEST__CACHE__RUNTIME__GLOBAL_COUNT"

  posix_test__debug '_posix_test__cache__global_count__init' \
    "global count file initialized: '${POSIX_TEST__CACHE__RUNTIME__GLOBAL_COUNT}'"
}

#==============================================================================
# Function to increase the global count cache file's content.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CACHE__RUNTIME__GLOBAL_COUNT
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
posix_test__cache__global_count__increment() {
  _posix_test__utils__increment_file_content \
    "$POSIX_TEST__CACHE__RUNTIME__GLOBAL_COUNT"

  posix_test__debug 'posix_test__cache__global_count__increment' \
    'global count file incremented'
}

#==============================================================================
# Function to get the global count cache file's content.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CACHE__RUNTIME__GLOBAL_COUNT
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
posix_test__cache__global_count__get() {
  ___count="$(posix_adapter__cat "$POSIX_TEST__CACHE__RUNTIME__GLOBAL_COUNT")"
  posix_adapter__echo "$___count"

  posix_test__debug 'posix_test__cache__global_count__get' \
    "global count value returned: '${___count}'"
}
