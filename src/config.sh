#==============================================================================
#   _____             __ _                       _   _
#  / ____|           / _(_)                     | | (_)
# | |     ___  _ __ | |_ _  __ _ _   _ _ __ __ _| |_ _  ___  _ __
# | |    / _ \| '_ \|  _| |/ _` | | | | '__/ _` | __| |/ _ \| '_ \
# | |___| (_) | | | | | | | (_| | |_| | | | (_| | |_| | (_) | | | |
#  \_____\___/|_| |_|_| |_|\__, |\__,_|_|  \__,_|\__|_|\___/|_| |_|
#                           __/ |
#==========================|___/===============================================


#==============================================================================
#   __  __                 _       _
#  |  \/  | __ _ _ __   __| | __ _| |_ ___  _ __ _   _
#  | |\/| |/ _` | '_ \ / _` |/ _` | __/ _ \| '__| | | |
#  | |  | | (_| | | | | (_| | (_| | || (_) | |  | |_| |
#  |_|  |_|\__,_|_| |_|\__,_|\__,_|\__\___/|_|   \__, |
#                                                |___/
#==============================================================================
# MANDATORY CONFIGURATION VARIABLES
#==============================================================================

# For better readability dm.test.sh is composed of smaller scripts that are
# sourced into it dynamically. As dm.test.sh is imported to the user codebase
# by sourcing, the conventional path determination cannot be used. The '$0'
# variable contains the the host script's path dm.test.sh is sourced from. The
# relative path to the root of the dm-test-runner subrepo has to be defined
# explicitly to the internal sourcing could be executed.
DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX="${DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX:=__INVALID__}"

# Test cases root directory relative to the runner script dm.test.sh is sourced
# to.
DM_TEST__CONFIG__TEST_CASES_ROOT="${DM_TEST__CONFIG__TEST_CASES_ROOT:=__INVALID__}"

# Test files are recognized by this prefix in the test case root directory.
DM_TEST__CONFIG__TEST_FILE_PREFIX="${DM_TEST__CONFIG__TEST_FILE_PREFIX:=__INVALID__}"

# Test cases are recognized by this prefix in the test files.
DM_TEST__CONFIG__TEST_CASE_PREFIX="${DM_TEST__CONFIG__TEST_CASE_PREFIX:=__INVALID__}"

#==============================================================================
#    ___        _   _                   _
#   / _ \ _ __ | |_(_) ___  _ __   __ _| |
#  | | | | '_ \| __| |/ _ \| '_ \ / _` | |
#  | |_| | |_) | |_| | (_) | | | | (_| | |
#   \___/| .__/ \__|_|\___/|_| |_|\__,_|_|
#        |_|
#==============================================================================
# OPTIONAL CONFIGURATION VARIABLES
#==============================================================================

# Debug mode enabled or not..
DM_TEST__CONFIG__DEBUG_ENABLED="${DM_TEST__CONFIG__DEBUG_ENABLED:=0}"

#==============================================================================
# __     __    _ _     _       _   _
# \ \   / /_ _| (_) __| | __ _| |_(_) ___  _ __
#  \ \ / / _` | | |/ _` |/ _` | __| |/ _ \| '_ \
#   \ V / (_| | | | (_| | (_| | |_| | (_) | | | |
#    \_/ \__,_|_|_|\__,_|\__,_|\__|_|\___/|_| |_|
#
#==============================================================================
# CONFIGURATION VALIDATION
#==============================================================================

#==============================================================================
# Configuration variables are mandatory, therefore a check need to be executed
# to ensure that the configuration is complete.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX
#   DM_TEST__CONFIG__TEST_CASES_ROOT
#   DM_TEST__CONFIG__TEST_FILE_PREFIX
#   DM_TEST__CONFIG__TEST_CASE_PREFIX
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
#   test
#==============================================================================
dm_test__config__validate_mandatory_config() {
  dm_test__debug \
    'dm_test__config__validate_mandatory_config' \
    'validating mandatory configuration variables..'

  if [ "$DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX" = "__INVALID__" ]
  then
    _report_configuration_error "DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX"
  fi

  if [ "$DM_TEST__CONFIG__TEST_CASES_ROOT" = "__INVALID__" ]
  then
    _report_configuration_error "DM_TEST__CONFIG__TEST_CASES_ROOT"
  fi

  if [ "$DM_TEST__CONFIG__TEST_FILE_PREFIX" = "__INVALID__" ]
  then
    _report_configuration_error "DM_TEST__CONFIG__TEST_FILE_PREFIX"
  fi

  if [ "$DM_TEST__CONFIG__TEST_CASE_PREFIX" = "__INVALID__" ]
  then
    _report_configuration_error "DM_TEST__CONFIG__TEST_CASE_PREFIX"
  fi

  dm_test__debug \
    'dm_test__config__validate_mandatory_config' \
    'configuration is complete'
}

#==============================================================================
# Error reporting helper function. Prints out the error message, then exits
# with error.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] variable - Missing variable name.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   Error message about the missing configuration variable.
# Status:
#   1 - Exiting with error after printed out the issue.
# Tools:
#   echo
#==============================================================================
_dm_test__report_configuration_error() {
  ___variable="$1"
  >&2 echo "ERROR: Mandatory configuration variable was not configured: '${___variable}'!"
  exit 1
}
