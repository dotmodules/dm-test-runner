#==============================================================================
#    ____ _       _           _    ____                  _
#   / ___| | ___ | |__   __ _| |  / ___|___  _   _ _ __ | |_
#  | |  _| |/ _ \| '_ \ / _` | | | |   / _ \| | | | '_ \| __|
#  | |_| | | (_) | |_) | (_| | | | |__| (_) | |_| | | | | |_
#   \____|_|\___/|_.__/ \__,_|_|  \____\___/ \__,_|_| |_|\__|
#
#==============================================================================
# GLOBAL COUNT
#==============================================================================

#==============================================================================
# Global cache file that holds the count of all executed test cases.
#==============================================================================

# Variable thar holds the runtime path of the global test case count file. This
# variable should be used for writing or reading purposes.
DM_TEST__CACHE__GLOBAL_COUNT="__INVALID__"

#==============================================================================
# Inner function to create and initialize the global count file. Writing an
# initial zero value to it. This number will be increased during each test case
# execution.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__CACHE__GLOBAL_COUNT
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   echo
#==============================================================================
_dm_test__cache__init__global_count() {
  DM_TEST__CACHE__GLOBAL_COUNT="$(dm_test__cache__create_temp_file)"
  echo '0' > "$DM_TEST__CACHE__GLOBAL_COUNT"
}

#==============================================================================
# Function to increase the global count cache file's content.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__RUNTIME__GLOBAL_COUNT
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
dm_test__cache__increment_global_count() {
  _dm_test__increase_file_content "$DM_TEST__CACHE__GLOBAL_COUNT"
}

#==============================================================================
# Function to get the global count cache file's content.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__GLOBAL_COUNT
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
dm_test__cache__get_global_count() {
  cat "$DM_TEST__CACHE__GLOBAL_COUNT"
}
