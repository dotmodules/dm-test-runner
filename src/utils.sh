#==============================================================================
#  _    _ _   _ _
# | |  | | | (_) |
# | |  | | |_ _| |___
# | |  | | __| | / __|
# | |__| | |_| | \__ \
#  \____/ \__|_|_|___/
#
#==============================================================================

#==============================================================================
# Test suite runner header with configuration and system information.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__SUBMODULE_PATH_PREFIX
#   DM_TEST__TEST_CASES_ROOT
#   DM_TEST__TEST_FILE_PREFIX
#   DM_TEST__TEST_CASE_PREFIX
#   DIM
#   RESET
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Multiline header with config and system information.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   echo uname command
#==============================================================================
dm_test__print_header() {
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
  uname --kernel-name --kernel-release --machine --operating-system
  echo "---------------------------------------------------------------------------------"
  echo "\$ command -v sh"
  command -v sh
  echo "---------------------------------------------------------------------------------"
  echo -n "$RESET"
}

#==============================================================================
# Function that prints out the results of the test suite. It provides a total
# and failed count, a overall test suite result (success or failure), and an
# optional error summary if there was an assertion error during execution. If
# the test suite fails this function will terminate the execution.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__TEST_RESULT__SUCCESS
#   RED
#   GREEN
#   BOLD
#   RESET
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Test suite summary and optional error report.
# STDERR:
#   None
# Status:
#   0 - test suite passed
#   1 - test suite failed, process termination
# Tools:
#   echo cat grep
#==============================================================================
dm_test__print_report() {
  echo ""
  echo "${BOLD}$(dm_test__cache__get_global_count) tests, $(dm_test__cache__get_global_failure_count) failed"

  if dm_test__cache__was_global_failure
  then
    echo "${BOLD}Result: ${RED}FAILURE${RESET}"
    echo ""
    if dm_test__cache__errors__has_errors
    then
      dm_test__cache__errors__print_errors
    fi
    exit 1
  else
    echo "${BOLD}Result: ${GREEN}SUCCESS${RESET}"
    echo ""
  fi
}

#==============================================================================
# Prints the given test content if it contains anything. The reason behind this
# function is not to print an empty line if the printable variable is empty.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] content - Content that needs to be printed if it contains anything.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Content that is passed to the function.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   echo
#==============================================================================
dm_test__print_if_has_content() {
  ___content="$1"
  if [ -n "$___content" ]
  then
    echo "$___content"
  fi
}

#==============================================================================
# Function that increments the content of a file that contains a single integer
# number. Can be used for counting something.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] file_path - File that content needs to be increased.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   Errors during execution.
# Status:
#   0 - File content incremented successfully.
#  !0 - Error during opreation.
# Tools:
#   echo cat
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

#==============================================================================
# Text line processor function that has triple duty:
# - Prepends each line with a precise timestamp that could be used for sorting
#   later on.
# - Inserts the given domain name that is passed as an argument into each line.
# - Colors each line with the given color passed as an argument.
#------------------------------------------------------------------------------
# Globals:
#   RESET
# Arguments:
#   [1] domain - Domain name the processing is happening in.
#   [2] color - The color the line should be colored with.
# STDIN:
#   Processable lines of text.
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Processed lines.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   read echo date
#==============================================================================
_dm_test__process_output() {
  ___domain="$1"
  ___color="$2"
  while read -r ___line
  do
    echo "$(date +'%s%N') ${___color}${___domain} | ${___line}${RESET}"
  done
}
