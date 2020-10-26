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
# MANDATORY CONFIGURATION VARIABLES
#==============================================================================

# For better readability dm.test.sh is composed of smaller scripts that are
# sourced into it dynamically. As dm.test.sh is imported to the user codebase
# by sourcing, the conventional path determination cannot be used. The '$0'
# variable contains the the host script dm.test.sh is sourced from. The
# relative path to the root of the dm-test-runner subrepo has to be defined
# explicitly to the internal sourcing could be executed.
DM_TEST__SUBMODULE_PATH_PREFIX="${DM_TEST__SUBMODULE_PATH_PREFIX:=__unconfigured__}"

# Test cases root directory relative to the runner script dm.test.sh is sourced
# to.
DM_TEST__TEST_CASES_ROOT="${DM_TEST__TEST_CASES_ROOT:=__unconfigured__}"

# Test files are recognized by this prefix in the test case root directory.
DM_TEST__TEST_FILE_PREFIX="${DM_TEST__TEST_FILE_PREFIX:=__unconfigured__}"

# Test cases are recognized by this prefix in the test files.
DM_TEST__TEST_CASE_PREFIX="${DM_TEST__TEST_CASE_PREFIX:=__unconfigured__}"

#==============================================================================
# CONFIGURATION VALIDATION
#==============================================================================

# Configuration variables are mandatory, therefore a check need to be executed
# to ensure that the configuration is complete.
validate_config() {
  if [ "$DM_TEST__SUBMODULE_PATH_PREFIX" = "__unconfigured__" ]
  then
    report_configuration_error "DM_TEST__SUBMODULE_PATH_PREFIX"
  fi

  if [ "$DM_TEST__TEST_CASES_ROOT" = "__unconfigured__" ]
  then
    report_configuration_error "DM_TEST__TEST_CASES_ROOT"
  fi

  if [ "$DM_TEST__TEST_FILE_PREFIX" = "__unconfigured__" ]
  then
    report_configuration_error "DM_TEST__TEST_FILE_PREFIX"
  fi

  if [ "$DM_TEST__TEST_CASE_PREFIX" = "__unconfigured__" ]
  then
    report_configuration_error "DM_TEST__TEST_CASE_PREFIX"
  fi
}

report_configuration_error() {
  ___variable="$1"
  echo "ERROR: Mandatory configuration variable was not configured: '${___variable}'!"
  exit 1
}

#==============================================================================
# VALIDATION ENTRY POINT
#==============================================================================

validate_config
