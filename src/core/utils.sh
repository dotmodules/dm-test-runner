#!/bin/sh
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
#==============================================================================
posix_test__utils__print_output_if_has_content() {
  ___content="$1"
  if [ -n "$___content" ]
  then
    posix_test__debug 'posix_test__utils__print_output_if_has_content' \
      'displaying captured output..'

    posix_adapter__echo "$___content"
  fi
}

#==============================================================================
# Function that increments the content of a file that contains a single integer
# number. Can be used to count something.
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
#==============================================================================
_posix_test__utils__increment_file_content() {
  ___file_path="$1"

  posix_test__debug '_posix_test__utils__increment_file_content' \
    "incrementing content of file '${___file_path}'"

  if [ -s "$___file_path" ]
  then
    ___content="$(posix_adapter__cat "$___file_path")"
    ___content=$(( ___content + 1 ))
    posix_adapter__echo "$___content" > "$___file_path"
  fi
}

#==============================================================================
# Function that decrements the content of a file that contains a single integer
# number. Can be used to count something.
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
#==============================================================================
_posix_test__utils__decrement_file_content() {
  ___file_path="$1"

  posix_test__debug '_posix_test__utils__decrement_file_content' \
    "decrementing content of file '${___file_path}'"

  if [ -s "$___file_path" ]
  then
    ___content="$(posix_adapter__cat "$___file_path")"
    ___content=$(( ___content - 1 ))
    posix_adapter__echo "$___content" > "$___file_path"
  fi
}

#==============================================================================
# Strip all coloring characters from the input string if possible.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
# STDIN:
#   String that need to be de-colored.
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   De-colored string.
# Status:
#   0 - Other status is not expected.
#==============================================================================
_posix_test__utils__strip_colors() {
  # Solution derived from https://superuser.com/a/380778
  # The output of the 'tput sgr0' reset character could be '033 ( B' so the
  # replace pattern has to be extended.
  ___pattern='s/\x1b[\[\(][0-9;]*[mB]//g'

  posix_test__debug '_posix_test__utils__strip_colors' \
    'stripping colors from input stream..'

  # Making sure that the running system supports the necessary escape
  # characters.. If not no stripping will be executed.
  if posix_adapter__echo '' | \
    posix_adapter__sed --expression "$___pattern" >/dev/null 2>&1
  then
    posix_adapter__cat - | posix_adapter__sed --expression "$___pattern"
  else
    posix_adapter__cat -
  fi
}
