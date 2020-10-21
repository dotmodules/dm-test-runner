#==============================================================================
#   _    _      _                    __                  _   _
#  | |  | |    | |                  / _|                | | (_)
#  | |__| | ___| |_ __   ___ _ __  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
#  |  __  |/ _ \ | '_ \ / _ \ '__| |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
#  | |  | |  __/ | |_) |  __/ |    | | | |_| | | | | (__| |_| | (_) | | | \__ \
#  |_|  |_|\___|_| .__/ \___|_|    |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
#                | |
#================|_|===========================================================

#==============================================================================
# Getting all the test files located in the predefined test cases root
# directory. Test files are matched based on the predefined test file prefix
# config variable.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__TEST_CASES_ROOT
# - DM_TEST__TEST_FILE_PREFIX
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
# - Test files found the the test cases root direcotry.
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__get_test_files() {
  find \
    "$DM_TEST__TEST_CASES_ROOT" \
    -type f \
    -name "${DM_TEST__TEST_FILE_PREFIX}*"
}

#==============================================================================
# Get all test cases from a given test file. Test cases are matched against the
# predefined test case prefix configuration variable.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__TEST_CASE_PREFIX
# Arguments
# - test_file_path - Path of the given test file the test cases should be
#   collected from.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Test files matched in the given test file.
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__get_test_cases() {
  test_file_path="$1"
  grep -E --only-matching \
    "^${DM_TEST__TEST_CASE_PREFIX}[^\(]+" \
    "$test_file_path"
}

#==============================================================================
# Function that prints out the error report collected from the executed test
# cases. It uses the global error cache temporary file to do this. Printing out
# the report depends on if there are anything to print out. It cleans up the
# temporary files too after the execution.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__ERROR_CACHE
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
# - Optional report of errors.
# StdErr
# - None
# Status
# -  0 : tests are executed without an error
# -  1 : there were errors during execution - the script terminates
#==============================================================================
_dm_test__print_report() {
  if [ -s "$DM_TEST__ERROR_CACHE" ]
  then
    echo ""
    cat "$DM_TEST__ERROR_CACHE"
    echo ""
    _dm_test__clean_up
    exit 1
  fi
  _dm_test__clean_up
}

#==============================================================================
# Cleans up all potentially generated temporary files.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__ERROR_CACHE
# - DM_TEST__TEST_RESULT_CACHE
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
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__clean_up() {
  rm -f "$DM_TEST__ERROR_CACHE"
  rm -f "$DM_TEST__TEST_RESULT_CACHE"
}

#==============================================================================
# Checks if in the given test file execution hook [setup, teardown, setup_file,
# teardown_file] are present. It checks for only one given hook, and returns
# the match count.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - pattern - Grep compatible pattern that should match the presence of the
#   testable hook.
# - test_file_path - Path of the given test file the hook should be searched
#   in.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Match count for the given pattern.
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__get_hook_flag() {
  pattern="$1"
  test_file_path="$2"
  grep --count "$pattern" "$test_file_path" || true
}

#==============================================================================
# Runs the given hook that is actually an already sourced function from the
# currently executing test file. The hook name should match one of the
# following [setup, teardown, setup_file, teardown_file]. A flag also passed
# that should determine if the given hook needs to be executed or not.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - flag - Integer number that should represent the given hook occurance count
#   in the currently executing test file.
# - hook - Hook function name that is called when the flag allows it. It should
#   be one of the following names: [setup, teardown, setup_file, teardown_file]
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Optionally it can output the output of the given hook if needed.
# StdErr
# - Error that occured during operation.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__run_hook() {
  flag="$1"
  hook="$2"
  if [ "$flag" -ne '0' ]
  then
    "$hook"
  fi
}

#==============================================================================
# Execution of the given test case in the currently executing test file. This
# function is responsible for providing the necessary global environment
# variables for the assertion functions used in the test case. After the
# execution the test case is printed to the output and the optional captured
# output also.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - test_file_path - Path of the currently executing test file.
# - test_case - Name of the test case function that should be executed.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Test case identifier and its optional output.
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__execute_test_case() {
  test_file_path="$1"
  test_case="$2"

  _dm_test__initialize_test_case_environment "$test_file_path" "$test_case"
  _dm_test__initialize_test_result
  _dm_test__print_test_case_identifier

  output="$(_dm_test__run_test_case)"

  _dm_test__print_test_case_result
  _dm_test__print_if_has_content "$output"
}

#==============================================================================
# The assertion based checking function needs global variables for they
# operation and error reporting and this is the function that is providing
# those variables.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - test_file_path - Path of the currently executing test file.
# - test_case - Name of the test case function that should be executed.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - DM_TEST__FILE_UNDER_EXECUTION
# - DM_TEST__TEST_UNDER_EXECUTION
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__initialize_test_case_environment() {
  test_file_path="$1"
  test_case="$2"

  # Setting up global variables for the error reporting.
  DM_TEST__FILE_UNDER_EXECUTION="$(basename "$test_file_path" | cut -d '.' -f 1)"
  DM_TEST__TEST_UNDER_EXECUTION="$test_case"
}

#==============================================================================
# Function that executes the given test case defined in the global execution
# environment.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__TEST_UNDER_EXECUTION
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
# - None
# StdErr
# - Hopefully none if the test case is written properly..
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__run_test_case() {
  rm -f tmp_err
  if output="$("$DM_TEST__TEST_UNDER_EXECUTION" 2>tmp_err)"
  then
    # Test case succeded without an error status. At this point we might have
    # standard output and standard error content that needs to be displayed.

    _dm_test__print_if_has_content "$output"
    # Standard error content should indicate that an error is happened during
    # execution, regardless of the returned status code.
    if [ -s tmp_err ]
    then
      echo "${RED}$(cat tmp_err)${RESET}"
      _dm_test__set_test_case_failed
    fi
    rm -f tmp_err
  else
    # The test case failed with a non zero error status, so we are reporting an
    # error here changing the test case status. We need ot indicate it also by
    # printing with red.
    _dm_test__set_test_case_failed
    if [ -n "$output" ]
    then
      echo "${RED}${output}${RESET}"
      if [ -s tmp_err ]
      then
        echo "${RED}$(cat tmp_err)${RESET}"
      fi
    fi
    rm -f tmp_err
  fi
}

#==============================================================================
# Function that initializes the test result cache file with the success
# content. After this only failure content would be written to this file by the
# test case assertions.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__TEST_RESULT_CACHE
# - DM_TEST__TEST_RESULT_SUCCESS
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
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__initialize_test_result() {
  echo "$DM_TEST__TEST_RESULT_SUCCESS" > "$DM_TEST__TEST_RESULT_CACHE"
}

#==============================================================================
# Function that sets the currently executing test case result as a failure.
# This operation is permanent.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__TEST_RESULT_CACHE
# - DM_TEST__TEST_RESULT_FAILURE
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
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__set_test_case_failed() {
  echo "$DM_TEST__TEST_RESULT_FAILURE" > "$DM_TEST__TEST_RESULT_CACHE"
}

#==============================================================================
# Printing out the about to be executed test case identifier without a newline.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__FILE_UNDER_EXECUTION
# - DM_TEST__TEST_UNDER_EXECUTION
# - BOLD
# - RESET
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
# - Identifier of the executable test case.
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__print_test_case_identifier() {
  # We are using printf to print without a line break, variables are expected
  # in the string.
  # shellcheck disable=SC2059
  printf "${BOLD}${DM_TEST__FILE_UNDER_EXECUTION}.${DM_TEST__TEST_UNDER_EXECUTION}${RESET}"
}

#==============================================================================
# Print out the result of the test case with some front padding.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__TEST_RESULT_CACHE
# - DM_TEST__TEST_RESULT_SUCCESS
# - GREEN
# - RED
# - BOLD
# - RESET
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
# - Result of the test case.
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__print_test_case_result() {
  # Evaluating the test result cache.
  if grep --silent "$DM_TEST__TEST_RESULT_SUCCESS" "$DM_TEST__TEST_RESULT_CACHE"
  then
    echo "  ${BOLD}${GREEN}ok${RESET}"
  else
    echo "  ${BOLD}${RED}not ok${RESET}"
  fi
}

#==============================================================================
# Prints the given test content if it contains anything.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - content - Content that needs to be printed if it contains anything.
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - Content that is passed to the function.
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__print_if_has_content() {
  content="$1"
  if [ -n "$content" ]
  then
    echo "$content"
  fi
}

#==============================================================================
# Creates a temporary directory for the currently executing test file. For each
# test file a new temporary directory will be created. This test file can be
# used to generate test artifacts that are used in the file level or in the
# test case level, it depends on the user.
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
# - DM_TEST__TMP_TEST_DIR
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__create_tmp_directory() {
  DM_TEST__TMP_TEST_DIR="$(mktemp -d -t 'dm.test.XXXXXXXXXX')"
}

#==============================================================================
# Deletes the previously created temporary directory.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__TMP_TEST_DIR
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
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__cleanup_tmp_directory() {
  rm -rf "$DM_TEST__TMP_TEST_DIR"
}
