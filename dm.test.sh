#!/bin/sh
#==============================================================================
#      _            _            _         _
#     | |          | |          | |       | |
#   __| |_ __ ___  | |_ ___  ___| |_   ___| |__
#  / _` | '_ ` _ \ | __/ _ \/ __| __| / __| '_ \
# | (_| | | | | | || ||  __/\__ \ |_ _\__ \ | | |
#  \__,_|_| |_| |_(_)__\___||___/\__(_)___/_| |_|
#
#==============================================================================

#==============================================================================
# SANE ENVIRONMENT
#==============================================================================

set -e  # exit on error
set -u  # prevent unset variable expansion

#==============================================================================
# SOURCING SUB-SCRIPTS
#==============================================================================

# shellcheck source=./src/config.sh
. "${DM_TEST__SUBMODULE_PATH_PREFIX}/src/config.sh"
# shellcheck source=./src/variables.sh
. "${DM_TEST__SUBMODULE_PATH_PREFIX}/src/variables.sh"
# shellcheck source=./src/api.sh
. "${DM_TEST__SUBMODULE_PATH_PREFIX}/src/api.sh"
# shellcheck source=./src/lib.sh
. "${DM_TEST__SUBMODULE_PATH_PREFIX}/src/lib.sh"

#==============================================================================
# API FUNCTIONS
#==============================================================================

#==============================================================================
# Only API function for the dm.test test runner. It looks for the test files in
# the predefined test root directory and executes the test cases one by one.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - None
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Execution results.
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_test__run_suite() {
  _dm_test__clean_up

  # Using a named pipe here to be able to safely iterate over the file names.
  # See more at shellcheck SC2044.
  rm -f temp_pipe
  mkfifo temp_pipe
  _dm_test__get_test_files > temp_pipe &

  while IFS= read -r test_file_path
  do
    # Executing the test file in a subshell to avoid poisoning the test runner
    # environemnt.
    (
      # Have to collect the test cases before the path change.
      test_cases="$(_dm_test__get_test_cases "$test_file_path")"

      # Getting the test runner hook flags if a specific hook needs to be runned
      # or not. Have to collect the flags before the path change.
      flag__setup="$(_dm_test__get_hook_flag "^setup()" "$test_file_path")"
      flag__teardown="$(_dm_test__get_hook_flag "^teardown()" "$test_file_path")"
      flag__setup_file="$(_dm_test__get_hook_flag "^setup_file()" "$test_file_path")"
      flag__teardown_file="$(_dm_test__get_hook_flag "^teardown_file()" "$test_file_path")"

      # In the subshell, navigating to the directory of the testcase to be able
      # to use relative imports there.
      cd "$(dirname "$test_file_path")"

      # Sourcing the test file to get access to the test cases defined inside.
      # Disabling shellcheck error SC1090 here as the test files are
      # dynamically loaded here, and we cannot know the exact source path of
      # them before running the test suite.
      # shellcheck disable=SC1090
      . "./$(basename "$test_file_path")"

      _dm_test__create_tmp_directory
      _dm_test__run_hook "$flag__setup_file" 'setup_file'

      for test_case in $test_cases
      do
        _dm_test__run_hook "$flag__setup" 'setup'
        _dm_test__execute_test_case "$test_file_path" "$test_case"
        _dm_test__run_hook "$flag__teardown" 'teardown'
      done

      _dm_test__run_hook "$flag__teardown_file" 'teardown_file'
      _dm_test__cleanup_tmp_directory
    )

  done < temp_pipe
  rm -f temp_pipe

  _dm_test__print_report
}
