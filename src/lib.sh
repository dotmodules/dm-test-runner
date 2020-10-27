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
# Prints the header for the test suite with executing environment information
# in it.
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
# - Execution header.
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__print_header() {
  echo -n "$DIM"
  echo "---------------------------------------------------------------------------------"
  echo ">> DM TEST <<"
  echo "---------------------------------------------------------------------------------"
  echo "\$ dm.test.sh --config"
  echo "DM_TEST__SUBMODULE_PATH_PREFIX='${DM_TEST__SUBMODULE_PATH_PREFIX}'"
  echo "DM_TEST__TEST_CASES_ROOT='${DM_TEST__TEST_CASES_ROOT}'"
  echo "DM_TEST__TEST_FILE_PREFIX='${DM_TEST__TEST_FILE_PREFIX}'"
  echo "DM_TEST__TEST_CASE_PREFIX='${DM_TEST__TEST_CASE_PREFIX}'"
  echo "---------------------------------------------------------------------------------"
  echo "\$ uname --kernel-name --kernel-release --machine --operating-system"
  echo "$(uname --kernel-name --kernel-release --machine --operating-system)"
  echo "---------------------------------------------------------------------------------"
  echo "\$ /bin/sh --version"
  echo "$(/bin/sh --version)"
  echo "---------------------------------------------------------------------------------"
  echo -n "$RESET"
}

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
  ___test_file_path="$1"
  grep -E --only-matching \
    "^${DM_TEST__TEST_CASE_PREFIX}[^\(]+" \
    "$___test_file_path"
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
# - DM_TEST__CACHE__ERRORS
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
  echo ""
  echo "${BOLD}$(cat "$DM_TEST__CACHE__GLOBAL_COUNT") tests, $(cat "$DM_TEST__CACHE__GLOBAL_RESULT") failed"

  if ! grep --silent "$DM_TEST__TEST_RESULT__SUCCESS" "$DM_TEST__CACHE__GLOBAL_RESULT"
  then
    echo "${BOLD}Result: ${RED}FAILURE${RESET}"
    echo ""
    if [ -s "$DM_TEST__CACHE__ERRORS" ]
    then
      cat "$DM_TEST__CACHE__ERRORS"
    fi
    exit 1
  else
    echo "${BOLD}Result: ${GREEN}SUCCESS${RESET}"
    echo ""
  fi
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
  ___pattern="$1"
  ___test_file_path="$2"
  grep --count "$___pattern" "$___test_file_path" || true
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
  ___flag="$1"
  ___hook="$2"
  if [ "$___flag" -ne '0' ]
  then
    "$___hook"
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
  ___test_file_path="$1"
  ___test_case="$2"

  _dm_test__initialize_test_case_environment "$___test_file_path" "$___test_case"
  _dm_test__initialize_test_result
  _dm_test__print_test_case_identifier

  ___output="$(_dm_test__run_test_case)"

  _dm_test__print_test_case_result
  _dm_test__print_if_has_content "$___output"
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
  ___test_file_path="$1"
  ___test_case="$2"

  # Setting up global variables for the error reporting.
  DM_TEST__FILE_UNDER_EXECUTION="$(basename "$___test_file_path" | cut -d '.' -f 1)"
  DM_TEST__TEST_UNDER_EXECUTION="$___test_case"
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
  ___tmp_error_file="$(dm_test__cache__create_temp_file)"

  # Color used for printing out the optional output and the error messages
  # collected from the standard error.
  ___color=""

  # We are doing three things here while executing the test case:
  # 1. Capturing the standard output to the ___output variable.
  # 2. Deciding if the test case succeeded or not based on the status code.
  # 3. Capturing the standard error into a temporary file.
  if ___output="$("$DM_TEST__TEST_UNDER_EXECUTION" 2>"${___tmp_error_file}")"
  then
    # The test casse succeeded, no error based on the status, but that means,
    # that none of the assertions were failed. There could be failed commands
    # that not altering the status code, but print on the standard error. In
    # that case we are considering the test case as failed.
    if [ -s "$___tmp_error_file" ]
    then
      _dm_test__set_test_case_failed
      ___color="$RED"
    fi
  else
    # Test case failed with a nonzero status code.
    _dm_test__set_test_case_failed
    ___color="$RED"
  fi

  # Print out the output if needed with the predefined color.
  if [ -n "$___output" ]
  then
    echo "${___color}${___output}${RESET}"
  fi

  # Print out the error messages if needed with the predefined color.
  if [ -s "$___tmp_error_file" ]
  then
    echo "${___color}$(cat "$___tmp_error_file")${RESET}"
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
# - DM_TEST__CACHE__TEST_RESULT
# - DM_TEST__TEST_RESULT__SUCCESS
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
  echo "$DM_TEST__TEST_RESULT__SUCCESS" > "$DM_TEST__CACHE__TEST_RESULT"
}

#==============================================================================
# Function that sets the currently executing test case result as a failure.
# This operation is permanent.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__CACHE__TEST_RESULT
# - DM_TEST__TEST_RESULT__FAILURE
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
  echo "$DM_TEST__TEST_RESULT__FAILURE" > "$DM_TEST__CACHE__TEST_RESULT"
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
# - DM_TEST__CACHE__TEST_RESULT
# - DM_TEST__TEST_RESULT__SUCCESS
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
  if grep --silent "$DM_TEST__TEST_RESULT__SUCCESS" "$DM_TEST__CACHE__TEST_RESULT"
  then
    echo "  ${BOLD}${GREEN}ok${RESET}"
  else
    echo "  ${BOLD}${RED}NOT OK${RESET}"
    _dm_test__increase_file_content "$DM_TEST__CACHE__GLOBAL_RESULT"
  fi
  _dm_test__increase_file_content "$DM_TEST__CACHE__GLOBAL_COUNT"
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
  ___content="$1"
  if [ -n "$___content" ]
  then
    echo "$___content"
  fi
}

#==============================================================================
# Increases the content number of the given file by one. It expects a file with
# only a single number in it.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
# Arguments
# - file_path - File that content needs to be increased.
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
# - Errors during execution.
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__increase_file_content() {
  ___file_path="$1"
  if [ -s "$___file_path" ]
  then
    ___content="$(cat "$___file_path")"
    ___content=$(( ___content + 1 ))
    echo "$___content" > "$___file_path"
  fi
}
