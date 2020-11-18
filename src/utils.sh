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
#   DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX
#   DM_TEST__CONFIG__TEST_CASES_ROOT
#   DM_TEST__CONFIG__TEST_FILE_PREFIX
#   DM_TEST__CONFIG__TEST_CASE_PREFIX
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
  dm_test__debug \
    'dm_test__print_header' \
    'printing suite header..'

  echo -n "$DIM"
  echo "---------------------------------------------------------------------------------"
  echo ">> DM TEST <<"
  echo "---------------------------------------------------------------------------------"
  echo "\$ dm.test.sh --config"
  echo "DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX='${DM_TEST__CONFIG__SUBMODULE_PATH_PREFIX}'"
  echo "DM_TEST__CONFIG__TEST_CASES_ROOT='${DM_TEST__CONFIG__TEST_CASES_ROOT}'"
  echo "DM_TEST__CONFIG__TEST_FILE_PREFIX='${DM_TEST__CONFIG__TEST_FILE_PREFIX}'"
  echo "DM_TEST__CONFIG__TEST_CASE_PREFIX='${DM_TEST__CONFIG__TEST_CASE_PREFIX}'"
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
#   echo
#==============================================================================
dm_test__print_report() {
  ___global_count="$(dm_test__cache__global_count__get)"
  ___failure_count="$(dm_test__cache__global_failure__get)"

  echo ""
  echo "${BOLD}${___global_count} tests, ${___failure_count} failed${RESET}"

  if dm_test__cache__global_failure__failures_happened
  then
    echo "${BOLD}Result: ${RED}FAILURE${RESET}"
    echo ""
    if dm_test__cache__global_errors__has_errors
    then
      dm_test__cache__global_errors__print_errors
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
#   echo test
#==============================================================================
dm_test__print_output_if_has_content() {
  ___content="$1"
  if [ -n "$___content" ]
  then
    dm_test__debug \
      'dm_test__print_output_if_has_content' \
      'displaying captured output..'

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
_dm_test__increment_file_content() {
  ___file_path="$1"

  dm_test__debug \
    '_dm_test__increment_file_content' \
    "incrementing content of file '${___file_path}'"

  if [ -s "$___file_path" ]
  then
    ___content="$(cat "$___file_path")"
    ___content=$(( ___content + 1 ))
    echo "$___content" > "$___file_path"
  fi
}

#==============================================================================
# Function that decrements the content of a file that contains a single integer
# number. Can be used for counting something.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] file_path - File that content needs to be decreased.
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
#   0 - File content decremented successfully.
#  !0 - Error during opreation.
# Tools:
#   echo cat
#==============================================================================
_dm_test__decrement_file_content() {
  ___file_path="$1"

  dm_test__debug \
    '_dm_test__decrement_file_content' \
    "decrementing content of file '${___file_path}'"

  if [ -s "$___file_path" ]
  then
    ___content="$(cat "$___file_path")"
    ___content=$(( ___content - 1 ))
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
  ___worker_domain="$1"
  ___worker_color="$2"

  dm_test__debug \
    '_dm_test__process_output' \
    "started processing worker for domain '${___worker_domain}', waiting for input.."

  while read -r ___worker_line
  do
    echo "$(date +'%s%N') ${___worker_color}${___worker_domain} | ${___worker_line}${RESET}"
  done

  dm_test__debug \
    '_dm_test__process_output' \
    "worker process finished for domain '${___worker_domain}'"
}
