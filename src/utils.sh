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

#==============================================================================
# Helper function that will check if the required tools are available on the
# current system.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX
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
#   0 - Every required tool is available.
#   1 - Missing tools. Execution will be aborted.
# Tools:
#   cat command test
#==============================================================================
_dm_test__utils__assert_tools() {
  dm_test__debug '_dm_test__utils__assert_tools' 'asserting required tools..'

  ___required_tools="$( \
    cat \
      "${DM_TEST__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX}/requirements.txt" \
  )"

  dm_test__debug_list '_dm_test__utils__assert_tools' \
    'required tools' "$___required_tools"

  ___missing_tools=''
  for ___tool in $___required_tools
  do
    if command -v "$___tool" >/dev/null 2>&1
    then
      :
    else
      ___missing_tools="${___missing_tools} ${___tool}"
    fi
  done

  if [ -n "$___missing_tools" ]
  then
    dm_test__utils__report_error_and_exit \
      'One or more required command line tool is missing from your system!' \
      'Unable to start dm.test execution..' \
      "$___missing_tools"
  fi

  dm_test__debug '_dm_test__utils__assert_tools' \
    'required tool assertion finished with success'
}
