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
