#==============================================================================
#    ____ _       _           _   _____     _ _
#   / ___| | ___ | |__   __ _| | |  ___|_ _(_) |_   _ _ __ ___  ___
#  | |  _| |/ _ \| '_ \ / _` | | | |_ / _` | | | | | | '__/ _ \/ __|
#  | |_| | | (_) | |_) | (_| | | |  _| (_| | | | |_| | | |  __/\__ \
#   \____|_|\___/|_.__/ \__,_|_| |_|  \__,_|_|_|\__,_|_|  \___||___/
#
#==============================================================================
# GLOBAL FAILURES
#==============================================================================

#==============================================================================
# Global cache file that holds the count of all failed test cases.
#==============================================================================

# Variable thar holds the runtime path of the global test case failure count
# file.
DM_TEST__CACHE__GLOBAL_FAILURES="__INVALID__"

#==============================================================================
# Inner function to create and initialize the global result file. Writing an
# initial zero to it. In case of a failed test case this number will be
# increased.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__GLOBAL_FAILURES
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__CACHE__GLOBAL_FAILURES
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   echo
#==============================================================================
_dm_test__cache__global_failures__init() {
  DM_TEST__CACHE__GLOBAL_FAILURES="$(dm_test__cache__create_temp_file)"
  echo '0' > "$DM_TEST__CACHE__GLOBAL_FAILURES"

  dm_test__debug \
    '_dm_test__cache__global_failures__init' \
    "global failure count file created: '${DM_TEST__CACHE__GLOBAL_FAILURES}'"
}

#==============================================================================
# Function to increase the global failure cache file's content.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__GLOBAL_FAILURES
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
#   None
#==============================================================================
dm_test__cache__global_failure__increment() {
  _dm_test__increment_file_content "$DM_TEST__CACHE__GLOBAL_FAILURES"

  dm_test__debug \
    'dm_test__cache__global_failure__increment' \
    'global failure count incremented'
}

#==============================================================================
# Function to get the global failures cache file's content.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__GLOBAL_FAILURES
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
# Tools:
#   cat
#==============================================================================
dm_test__cache__global_failure__get() {
  ___count="$(cat "$DM_TEST__CACHE__GLOBAL_FAILURES")"
  echo "$___count"

  dm_test__debug \
    'dm_test__cache__global_failure__get' \
    "global failure count value returned: '${___count}'"
}

#==============================================================================
# Function to get the global failures cache file's content.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__GLOBAL_FAILURES
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
#   0 - Global failures count is nonzero.
#   1 - Global failures count is zero.
# Tools:
#   grep
#==============================================================================
dm_test__cache__global_failure__failures_happened() {
  dm_test__debug \
    'dm_test__cache__global_failure__failures_happened' \
    'checking if there were failures..'

  grep --silent --invert-match '^0$' "$DM_TEST__CACHE__GLOBAL_FAILURES"
}
