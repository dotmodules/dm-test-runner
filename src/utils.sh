#==============================================================================
#   _    _ _   _ _ _ _   _
#  | |  | | | (_) (_) | (_)
#  | |  | | |_ _| |_| |_ _  ___  ___
#  | |  | | __| | | | __| |/ _ \/ __|
#  | |__| | |_| | | | |_| |  __/\__ \
#   \____/ \__|_|_|_|\__|_|\___||___/
#
#==============================================================================
# UTILITIES
#==============================================================================

#==============================================================================
# Error reporting function that will display the given message, and abort the
# execution.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] message - Error message that will be displayed.
#   [2] details - Detailed error message.
#   [3] reason - Reason of this error.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Error message.
# STDERR:
#   None
# Status:
#   1 - System exit.
#------------------------------------------------------------------------------
# Tools:
#   echo sed
#==============================================================================
dm_test__utils__report_error_and_exit() {
  ___message="$1"
  ___details="$2"
  ___reason="$3"

  dm_test__debug 'dm_test__utils__report_error_and_exit' \
    'aborting the execution due to an unrecoverable error..'

  echo -n "${RED}============================================================="
  echo "==================${RESET}"
  echo "  ${RED}${BOLD}FATAL ERROR${RESET}"
  echo -n "${RED}============================================================="
  echo "==================${RESET}"
  echo ''
  echo "  ${RED}${___message}${RESET}"
  echo "  ${RED}${___details}${RESET}"
  echo ''
  echo "${___reason}" | sed "s/^/  ${RED}/" | sed "s/$/${RESET}/" 
  echo ''
  echo -n "${RED}============================================================="
  echo "==================${RESET}"
  exit 1
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
#------------------------------------------------------------------------------
# Tools:
#   echo test
#==============================================================================
dm_test__utils__print_output_if_has_content() {
  ___content="$1"
  if [ -n "$___content" ]
  then
    dm_test__debug 'dm_test__utils__print_output_if_has_content' \
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
#   0 - Other status is not expected.
#------------------------------------------------------------------------------
# Tools:
#   echo cat test
#==============================================================================
_dm_test__utils__increment_file_content() {
  ___file_path="$1"

  dm_test__debug '_dm_test__utils__increment_file_content' \
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
#   0 - Other status is not expected.
#------------------------------------------------------------------------------
# Tools:
#   echo cat test
#==============================================================================
_dm_test__utils__decrement_file_content() {
  ___file_path="$1"

  dm_test__debug '_dm_test__utils__decrement_file_content' \
    "decrementing content of file '${___file_path}'"

  if [ -s "$___file_path" ]
  then
    ___content="$(cat "$___file_path")"
    ___content=$(( ___content - 1 ))
    echo "$___content" > "$___file_path"
  fi
}
