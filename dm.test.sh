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
. "${DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX}/src/config.sh"
# shellcheck source=./src/variables.sh
. "${DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX}/src/variables.sh"
# shellcheck source=./src/assert.sh
. "${DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX}/src/assert.sh"
# shellcheck source=./src/utils.sh
. "${DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX}/src/utils.sh"
# shellcheck source=./src/test_case.sh
. "${DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX}/src/test_case.sh"
# shellcheck source=./src/hooks.sh
. "${DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX}/src/hooks.sh"

# shellcheck source=./src/cache/base.sh
. "${DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX}/src/cache/base.sh"
# shellcheck source=./src/cache/global_errors.sh
. "${DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX}/src/cache/global_errors.sh"
# shellcheck source=./src/cache/test_result.sh
. "${DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX}/src/cache/test_result.sh"
# shellcheck source=./src/cache/global_count.sh
. "${DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX}/src/cache/global_count.sh"
# shellcheck source=./src/cache/global_failure.sh
. "${DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX}/src/cache/global_failure.sh"
# shellcheck source=./src/cache/test_directory.sh
. "${DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX}/src/cache/test_directory.sh"

# shellcheck source=./src/debug.sh
. "${DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX}/src/debug.sh"
# shellcheck source=./src/trap.sh
. "${DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX}/src/trap.sh"

#==============================================================================
# API FUNCTIONS
#==============================================================================

#==============================================================================
# Only API function for the dm.test test runner. It looks for the test files in
# the predefined test root directory and executes the test cases one by one.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Execution results.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   None
#==============================================================================
dm_test__run_suite() {
  dm_test__debug__wrapper '_dm_test__run_suite'
}

#==============================================================================
# Real main test suite entry function.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Execution results.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   mkfifo cd dirname basename read
#==============================================================================
_dm_test__run_suite() {
  dm_test__debug \
    '_dm_test__run_suite' \
    'initializing..'

  dm_test__config__validate_mandatory_config
  dm_test__cache__init
  dm_test__print_header

  # Using a named pipe here to be able to safely iterate over the file names.
  # See more at shellcheck SC2044.
  ___tmp_pipe="$(dm_test__cache__create_temp_file)"
  mkfifo "$___tmp_pipe"
  dm_test__get_test_files > "$___tmp_pipe" &

  while IFS= read -r ___test_file_path
  do

    dm_test__debug \
      '_dm_test__run_suite' \
      "preparing for executing test file '${___test_file_path}'.."

    # Executing the test file in a subshell to avoid poisoning the test runner
    # environemnt.
    (
      dm_test__debug \
        '_dm_test__run_suite' \
        '========================[ test file level subshell start ]========================'

      # Have to collect the test cases before the path change.
      ___test_cases="$(dm_test__get_test_cases "$___test_file_path")"

      dm_test__debug \
        '_dm_test__run_suite' \
        'checking test runner hooks in test file..'

      # Getting the test runner hook flags if a specific hook needs to be runned
      # or not. Have to collect the flags before the path change.
      ___flag__setup="$(dm_test__get_hook_flag "^setup()" "$___test_file_path")"
      ___flag__teardown="$(dm_test__get_hook_flag "^teardown()" "$___test_file_path")"
      ___flag__setup_file="$(dm_test__get_hook_flag "^setup_file()" "$___test_file_path")"
      ___flag__teardown_file="$(dm_test__get_hook_flag "^teardown_file()" "$___test_file_path")"

      dm_test__debug \
        '_dm_test__run_suite' \
        'changing directory to the path of the test file to aid relative imports in the test cases'

      # In the subshell, navigating to the directory of the testcase to be able
      # to use relative imports there.
      cd "$(dirname "$___test_file_path")"

      dm_test__debug \
        '_dm_test__run_suite' \
        'sourcing test file..'

      # Sourcing the test file to get access to the test cases defined inside.
      # Disabling shellcheck error SC1090 here as the test files are
      # dynamically loaded here, and we cannot know the exact source path of
      # them before running the test suite.
      # shellcheck disable=SC1090
      . "./$(basename "$___test_file_path")"

      dm_test__debug \
        '_dm_test__run_suite' \
        'generating execution environment..'

      dm_test__cache__test_directory__create
      dm_test__run_hook "$___flag__setup_file" 'setup_file'

      dm_test__debug \
        '_dm_test__run_suite' \
        'executing test cases from test file..'

      for ___test_case in $___test_cases
      do
        dm_test__execute_test_case \
          "$___test_file_path" \
          "$___test_case" \
          "$___flag__setup" \
          "$___flag__teardown"
      done

      dm_test__run_hook "$___flag__teardown_file" 'teardown_file'

      dm_test__debug \
        '_dm_test__run_suite' \
        'test file execution finished'

      dm_test__debug \
        '_dm_test__run_suite' \
        '========================[ test file level subshell stop ]========================'
    ) # End of the subshell.

  done < "$___tmp_pipe"

  dm_test__debug \
    '_dm_test__run_suite' \
    'test files were executed'

  dm_test__debug \
    '_dm_test__run_suite' \
    'printing final test report..'

  dm_test__print_report

  dm_test__debug \
    '_dm_test__run_suite' \
    'test suite execution finished'
}
