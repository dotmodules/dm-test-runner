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
#  |  \/  |               | |     | |
#  | \  / | __ _ _ __   __| | __ _| |_ ___  _ __ _   _
#  | |\/| |/ _` | '_ \ / _` |/ _` | __/ _ \| '__| | | |
#  | |  | | (_| | | | | (_| | (_| | || (_) | |  | |_| |
#  |_|  |_|\__,_|_| |_|\__,_|\__,_|\__\___/|_|   \__, |
#                                                 __/ |
#================================================|___/=========================
# MANDATORY CONFIGURATION VARIABLES
#==============================================================================

#==============================================================================
#  ____       _   _                       __ _
# |  _ \ __ _| |_| |__    _ __  _ __ ___ / _(_)_  __
# | |_) / _` | __| '_ \  | '_ \| '__/ _ \ |_| \ \/ /
# |  __/ (_| | |_| | | | | |_) | | |  __/  _| |>  <
# |_|   \__,_|\__|_| |_| | .__/|_|  \___|_| |_/_/\_\
#========================|_|===================================================
# SUBMODULE PATH PREFIX
#==============================================================================
# For better readability dm.test.sh is composed of smaller scripts that are
# sourced into it dynamically. As dm.test.sh is imported to the user codebase
# by sourcing, the conventional path determination cannot be used. The '$0'
# variable contains the the host script's path dm.test.sh is sourced from. The
# relative path to the root of the dm-test-runner subrepo has to be defined
# explicitly to the internal sourcing could be executed.
DM_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX=\
"${DM_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX:=__INVALID__}"

#==============================================================================
#  _____         _                                          _
# |_   _|__  ___| |_    ___ __ _ ___  ___   _ __ ___   ___ | |_
#   | |/ _ \/ __| __|  / __/ _` / __|/ _ \ | '__/ _ \ / _ \| __|
#   | |  __/\__ \ |_  | (_| (_| \__ \  __/ | | | (_) | (_) | |_
#   |_|\___||___/\__|  \___\__,_|___/\___| |_|  \___/ \___/ \__|
#==============================================================================
# TEST CASE ROOT
#==============================================================================
# Test cases root directory relative to the runner script dm.test.sh is sourced
# to.
DM_TEST__CONFIG__MANDATORY__TEST_FILES_ROOT=\
"${DM_TEST__CONFIG__MANDATORY__TEST_FILES_ROOT:=__INVALID__}"

#==============================================================================
#  _____         _      __ _ _                        __ _
# |_   _|__  ___| |_   / _(_) | ___   _ __  _ __ ___ / _(_)_  __
#   | |/ _ \/ __| __| | |_| | |/ _ \ | '_ \| '__/ _ \ |_| \ \/ /
#   | |  __/\__ \ |_  |  _| | |  __/ | |_) | | |  __/  _| |>  <
#   |_|\___||___/\__| |_| |_|_|\___| | .__/|_|  \___|_| |_/_/\_\
#====================================|_|=======================================
# TEST FILE PREFIX
#==============================================================================
# Test files are recognized by this prefix in the test case root directory.
DM_TEST__CONFIG__MANDATORY__TEST_FILE_PREFIX=\
"${DM_TEST__CONFIG__MANDATORY__TEST_FILE_PREFIX:=__INVALID__}"

#==============================================================================
#  _____         _                                          __ _
# |_   _|__  ___| |_    ___ __ _ ___  ___   _ __  _ __ ___ / _(_)_  __
#   | |/ _ \/ __| __|  / __/ _` / __|/ _ \ | '_ \| '__/ _ \ |_| \ \/ /
#   | |  __/\__ \ |_  | (_| (_| \__ \  __/ | |_) | | |  __/  _| |>  <
#   |_|\___||___/\__|  \___\__,_|___/\___| | .__/|_|  \___|_| |_/_/\_\
#==========================================|_|=================================
# TEST CASE PREFIX
#==============================================================================
# Test cases are recognized by this prefix in the test files.
DM_TEST__CONFIG__MANDATORY__TEST_CASE_PREFIX=\
"${DM_TEST__CONFIG__MANDATORY__TEST_CASE_PREFIX:=__INVALID__}"


#==============================================================================
#    ____        _   _                   _
#   / __ \      | | (_)                 | |
#  | |  | |_ __ | |_ _  ___  _ __   __ _| |
#  | |  | | '_ \| __| |/ _ \| '_ \ / _` | |
#  | |__| | |_) | |_| | (_) | | | | (_| | |
#   \____/| .__/ \__|_|\___/|_| |_|\__,_|_|
#         | |
#=========|_|==================================================================
# OPTIONAL CONFIGURATION VARIABLES
#==============================================================================

#==============================================================================
#   ____           _                                       _         _ _
#  / ___|__ _  ___| |__   ___   _ __   __ _ _ __ ___ _ __ | |_    __| (_)_ __
# | |   / _` |/ __| '_ \ / _ \ | '_ \ / _` | '__/ _ \ '_ \| __|  / _` | | '__|
# | |__| (_| | (__| | | |  __/ | |_) | (_| | | |  __/ | | | |_  | (_| | | |
#  \____\__,_|\___|_| |_|\___| | .__/ \__,_|_|  \___|_| |_|\__|  \__,_|_|_|
#==============================|_|=============================================
# CACHE PARENT DIRECTORY
#==============================================================================
# Directory where the cache system will create the cache directories. It
# defaults to the '/tmp' directory. The cache directories will be created
# inside this parent directory. If the default are kept a cache directory might
# look like this: '/tmp/dm_test_cache.[random_string]'.
DM_TEST__CONFIG__OPTIONAL__CACHE_PARENT_DIRECTORY=\
"${DM_TEST__CONFIG__OPTIONAL__CACHE_PARENT_DIRECTORY:=/tmp}"

#==============================================================================
#  _____      _ _                    __       _ _
# | ____|_  _(_) |_    ___  _ __    / _| __ _(_) |_   _ _ __ ___
# |  _| \ \/ / | __|  / _ \| '_ \  | |_ / _` | | | | | | '__/ _ \
# | |___ >  <| | |_  | (_) | | | | |  _| (_| | | | |_| | | |  __/
# |_____/_/\_\_|\__|  \___/|_| |_| |_|  \__,_|_|_|\__,_|_|  \___|
#==============================================================================
# EXIT ON FAILURE
#==============================================================================
# Flag that indicate if the test suite should execute an exit call on failure
# or not. The exit call will be exeuted by default.
#   0 - exit call won't be executed
#   1 - exit call will be executed
DM_TEST__CONFIG__OPTIONAL__EXIT_ON_FAILURE=\
"${DM_TEST__CONFIG__OPTIONAL__EXIT_ON_FAILURE:=1}"

#==============================================================================
# Function that should be used in an if statement determines if the exit
# command sohuld be called or not on a failure.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CONFIG__OPTIONAL__EXIT_ON_FAILURE
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
#   0 - exit command should be executed on failure
#   1 - exit command should not be executed on failure
#==============================================================================
dm_test__config__should_exit_on_failure() {
  test "$DM_TEST__CONFIG__OPTIONAL__EXIT_ON_FAILURE" -eq '1'
}

#==============================================================================
#  ____  _        _                              __       _ _
# / ___|| |_ __ _| |_ _   _ ___    ___  _ __    / _| __ _(_) |_   _ _ __ ___
# \___ \| __/ _` | __| | | / __|  / _ \| '_ \  | |_ / _` | | | | | | '__/ _ \
#  ___) | || (_| | |_| |_| \__ \ | (_) | | | | |  _| (_| | | | |_| | | |  __/
# |____/ \__\__,_|\__|\__,_|___/  \___/|_| |_| |_|  \__,_|_|_|\__,_|_|  \___|
#==============================================================================
# STATUS ON FAILURE
#==============================================================================
# Status code that should be returned when the test suite has failed. The
# default value is a regular 1.
DM_TEST__CONFIG__OPTIONAL__STATUS_ON_FAILURE=\
"${DM_TEST__CONFIG__OPTIONAL__STATUS_ON_FAILURE:=1}"

#==============================================================================
#  _____ _ _        _                 _                  _               _
# |  ___(_) | ___  | |__   ___   ___ | | __   ___  _   _| |_ _ __  _   _| |_
# | |_  | | |/ _ \ | '_ \ / _ \ / _ \| |/ /  / _ \| | | | __| '_ \| | | | __|
# |  _| | | |  __/ | | | | (_) | (_) |   <  | (_) | |_| | |_| |_) | |_| | |_
# |_|   |_|_|\___| |_| |_|\___/ \___/|_|\_\  \___/ \__,_|\__| .__/ \__,_|\__|
#===========================================================|_|================
# FILE LEVEL HOOK OUTPUT DISPLAY OPTIONS
#==============================================================================
# Always show file level hook's (setup and teardown file) output regardless of
# the execution status. By default, the output of those hook are only visible
# if they are failed to execute.
# Options:
#   0 - display only on failure
#   1 - always display
DM_TEST__CONFIG__OPTIONAL__ALWAYS_DISPLAY_FILE_LEVEL_HOOK_OUTPUT=\
"${DM_TEST__CONFIG__OPTIONAL__ALWAYS_DISPLAY_FILE_LEVEL_HOOK_OUTPUT:=0}"

#==============================================================================
# Function that should be used in an if statement determines if the file level
# hook's output should be always displayed or not.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CONFIG__OPTIONAL__ALWAYS_DISPLAY_FILE_LEVEL_HOOK_OUTPUT
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
#   0 - file level hook output should be always displayed
#   1 - file level hook output should be only displayed when the hook failed
#==============================================================================
dm_test__config__should_always_display_file_level_hook_output() {
  test \
    "$DM_TEST__CONFIG__OPTIONAL__ALWAYS_DISPLAY_FILE_LEVEL_HOOK_OUTPUT" -eq '1'
}

#==============================================================================
# Function that should be used in an if statement determines if the file level
# hook's output should be only displayed when the hook failed.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CONFIG__OPTIONAL__ALWAYS_DISPLAY_FILE_LEVEL_HOOK_OUTPUT
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
#   0 - file level hook output should be always displayed
#   1 - file level hook output should be only displayed when the hook failed
#==============================================================================
dm_test__config__should_only_display_file_level_hook_output_on_failure() {
  test \
    "$DM_TEST__CONFIG__OPTIONAL__ALWAYS_DISPLAY_FILE_LEVEL_HOOK_OUTPUT" -eq '0'
}

#==============================================================================
#  ____             _     _            _
# / ___|  ___  _ __| |_  | |_ ___  ___| |_    ___ __ _ ___  ___  ___
# \___ \ / _ \| '__| __| | __/ _ \/ __| __|  / __/ _` / __|/ _ \/ __|
#  ___) | (_) | |  | |_  | ||  __/\__ \ |_  | (_| (_| \__ \  __/\__ \
# |____/ \___/|_|   \__|  \__\___||___/\__|  \___\__,_|___/\___||___/
#==============================================================================
# SORT TEST CASES
#==============================================================================
# Optional flag that determines if the test cases are executed in an
# alphabetically sorted way in a test file or not. The default behavior is to
# not to sort the test cases.
# Options:
#   0 - test case execution will not be sorted inside a file
#   1 - test case execution will be sorted inside a file
DM_TEST__CONFIG__OPTIONAL__SORTED_TEST_CASE_EXECUTION=\
"${DM_TEST__CONFIG__OPTIONAL__SORTED_TEST_CASE_EXECUTION:=0}"

#==============================================================================
# Helper function to check if test case sorting is necessary.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CONFIG__OPTIONAL__SORTED_TEST_CASE_EXECUTION
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
#   0 - test case execution should be sorted inside a test file
#   1 - test case execution should not be sorted inside a test file
#==============================================================================
dm_test__config__should_sort_test_cases() {
  test "$DM_TEST__CONFIG__OPTIONAL__SORTED_TEST_CASE_EXECUTION" -ne '0'
}

#==============================================================================
#  ____       _                                       _
# |  _ \  ___| |__  _   _  __ _   _ __ ___   ___   __| | ___
# | | | |/ _ \ '_ \| | | |/ _` | | '_ ` _ \ / _ \ / _` |/ _ \
# | |_| |  __/ |_) | |_| | (_| | | | | | | | (_) | (_| |  __/
# |____/ \___|_.__/ \__,_|\__, | |_| |_| |_|\___/ \__,_|\___|
#=========================|___/================================================
# DEBUG MODE
#==============================================================================
# Debug mode enabled or not..
DM_TEST__CONFIG__OPTIONAL__DEBUG_ENABLED=\
"${DM_TEST__CONFIG__OPTIONAL__DEBUG_ENABLED:=0}"

#==============================================================================
# Helper function to check if debugging is enabled or not.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CONFIG__OPTIONAL__DEBUG_ENABLED
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
#   0 - debug mode is enabled
#   1 - debug mode is disabled
#==============================================================================
dm_test__config__debug_is_enabled() {
  test "$DM_TEST__CONFIG__OPTIONAL__DEBUG_ENABLED" -ne '0'
}


#==============================================================================
#  __      __   _ _     _       _   _
#  \ \    / /  | (_)   | |     | | (_)
#   \ \  / /_ _| |_  __| | __ _| |_ _  ___  _ __
#    \ \/ / _` | | |/ _` |/ _` | __| |/ _ \| '_ \
#     \  / (_| | | | (_| | (_| | |_| | (_) | | | |
#      \/ \__,_|_|_|\__,_|\__,_|\__|_|\___/|_| |_|
#
#==============================================================================
# CONFIGURATION VALIDATION
#==============================================================================

#==============================================================================
# Configuration variables are mandatory, therefore a check need to be executed
# to ensure that the configuration is complete.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX
#   DM_TEST__CONFIG__MANDATORY__TEST_FILES_ROOT
#   DM_TEST__CONFIG__MANDATORY__TEST_FILE_PREFIX
#   DM_TEST__CONFIG__MANDATORY__TEST_CASE_PREFIX
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
dm_test__config__validate_mandatory_config() {
  dm_test__debug 'dm_test__config__validate_mandatory_config' \
    'validating mandatory configuration variables..'

  if [ "$DM_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX" = '__INVALID__' ]
  then
    _dm_test__config__report_configuration_error \
      'DM_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX'
  fi

  if [ "$DM_TEST__CONFIG__MANDATORY__TEST_FILES_ROOT" = '__INVALID__' ]
  then
    _dm_test__config__report_configuration_error \
      'DM_TEST__CONFIG__MANDATORY__TEST_FILES_ROOT'
  fi

  if [ "$DM_TEST__CONFIG__MANDATORY__TEST_FILE_PREFIX" = '__INVALID__' ]
  then
    _dm_test__config__report_configuration_error \
      'DM_TEST__CONFIG__MANDATORY__TEST_FILE_PREFIX'
  fi

  if [ "$DM_TEST__CONFIG__MANDATORY__TEST_CASE_PREFIX" = '__INVALID__' ]
  then
    _dm_test__config__report_configuration_error \
      'DM_TEST__CONFIG__MANDATORY__TEST_CASE_PREFIX'
  fi

  dm_test__debug 'dm_test__config__validate_mandatory_config' \
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
#==============================================================================
_dm_test__config__report_configuration_error() {
  ___variable="$1"

  dm_test__debug '_dm_test__config__report_configuration_error' \
    'configuration error detected!'

  dm_test__report_error_and_exit \
    'Configuration validation failed!' \
    'Mandatory configuration variable was not configured:' \
    "$___variable"
}
