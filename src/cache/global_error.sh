#==============================================================================
#    ____ _       _           _   _____
#   / ___| | ___ | |__   __ _| | | ____|_ __ _ __ ___  _ __
#  | |  _| |/ _ \| '_ \ / _` | | |  _| | '__| '__/ _ \| '__|
#  | |_| | | (_) | |_) | (_| | | | |___| |  | | | (_) | |
#   \____|_|\___/|_.__/ \__,_|_| |_____|_|  |_|  \___/|_|
#
#==============================================================================
# GLOBAL ERROR
#==============================================================================

#==============================================================================
# Individual test cases are executed in a subshell of a subshell. Errors
# happening in there should reach the top execution level. This file acts as a
# global buffer where assertion errors can be appended to. If an assertion
# fails it should write to this file via the provided API function.
#==============================================================================

# Variable thar holds the runtime path of the global error file. This variable
# should be used for writing or reading purposes.
DM_TEST__CACHE__ERRORS="__INVALID__"

#==============================================================================
# Inner function to create and initialize the error cache file.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__CACHE__ERRORS
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   touch echo
#==============================================================================
_dm_test__cache__init__errors() {
  DM_TEST__CACHE__ERRORS="$(dm_test__cache__create_temp_file)"
  touch "$DM_TEST__CACHE__ERRORS"
}

#==============================================================================
# API function to check if errors are present in the global cache file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__ERRORS
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
#   !0 - No errors in the global test cache file.
# Tools:
#   None
#==============================================================================
dm_test__cache__errors__has_errors() {
  test -s "$DM_TEST__CACHE__ERRORS"
}

#==============================================================================
# API function to print the errors from the global error cache file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__ERRORS
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
# Tools:
#   cat
#==============================================================================
dm_test__cache__errors__print_errors() {
  cat "$DM_TEST__CACHE__ERRORS"
}

#==============================================================================
# API function to append to the global error cache file. It redirects its
# standard input to the global error cache file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__ERRORS
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
# Tools:
#   cat
#==============================================================================
dm_test__cache__errors__write_errors() {
  cat - >> "$DM_TEST__CACHE__ERRORS"
}
