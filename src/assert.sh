#==============================================================================
#                              _   _                        _____ _____
#      /\                     | | (_)                 /\   |  __ \_   _|
#     /  \   ___ ___  ___ _ __| |_ _  ___  _ __      /  \  | |__) || |
#    / /\ \ / __/ __|/ _ \ '__| __| |/ _ \| '_ \    / /\ \ |  ___/ | |
#   / ____ \\__ \__ \  __/ |  | |_| | (_) | | | |  / ____ \| |    _| |_
#  /_/    \_\___/___/\___|_|   \__|_|\___/|_| |_| /_/    \_\_|   |_____|
#
#==============================================================================
# ASSERTION API
#==============================================================================

#==============================================================================
# This file contains the API functions that the test cases can use to test
# their functionality. There are two kinds of assertion types: basic and
# context based.
#
# Basic assertions can be executed at any time without any context as they are
# working working on the given parameters only. They can be used to compare
# values and to check file system related facts.
#
# Context based assertions - as the name implies - needs a predefined context
# to be able to run. This context is provided by the 'run' function. To be able
# to use context based assertions you need to run the testable funtion or
# command with the 'run' function. This will save the output and the status of
# the runned function or command into the global assertion context, and you can
# call assertions to test this context. In this way you can check if a function
# or command provided the expected status code and output without running it
# multiple times for each assertions.
#==============================================================================

#==============================================================================
#   ____            _                                   _   _
#  |  _ \          (_)          /\                     | | (_)
#  | |_) | __ _ ___ _  ___     /  \   ___ ___  ___ _ __| |_ _  ___  _ __  ___
#  |  _ < / _` / __| |/ __|   / /\ \ / __/ __|/ _ \ '__| __| |/ _ \| '_ \/ __|
#  | |_) | (_| \__ \ | (__   / ____ \\__ \__ \  __/ |  | |_| | (_) | | | \__ \
#  |____/ \__,_|___/_|\___| /_/    \_\___/___/\___|_|   \__|_|\___/|_| |_|___/
#
#==============================================================================
# BASIC ASSERTIONS
#==============================================================================

#==============================================================================
# Simple assertion helper function that expects a list of parameters that will
# be interpreted as a test command in an if statement. It is common to use the
# 'test' command to write simple assertions, but in general anything can be
# used.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [..] command - Commands and parameters that needs to be executed.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
assert() {
  ___command="$*"

  dm_test__debug 'assert' "running assertion: '${___command}'"

  if $___command
  then
    dm_test__debug 'assert' '=> assertion succeeded'
  else
    dm_test__debug 'assert' '=> assertion failed'

    ___subject='Assertion failed'
    ___reason="Tested command that failed: '${___command}'."
    ___assertion='assert'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Simple assertion helper function that expects a list of parameters that will
# be interpreted as a test command in an if statement. It is common to use the
# 'test' command to write simple assertions, but in general anything can be
# used.
#
# Internally this is exactly the same as the simple 'assert' function only the
# name is different. It exist only to complement the 'assert_failure' function.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [..] command - Commands and parameters that needs to be executed.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
assert_success() {
  ___command="$*"

  dm_test__debug 'assert_success' "running assertion: '${___command}'"

  if $___command
  then
    dm_test__debug 'assert_success' '=> assertion succeeded'
  else
    dm_test__debug 'assert_success' '=> assertion failed'

    ___subject='Assertion failed'
    ___reason="Tested command that failed: '${___command}'."
    ___assertion='assert_success'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Simple assertion that succeeds on failure. It expectes a command or function
# name, that will be inserted into an if statement.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [..] command - Commands and parameters that needs to be executed.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
assert_failure() {
  ___command="$*"

  dm_test__debug 'assert_failure' "running assertion: '${___command}'"

  if ! $___command
  then
    dm_test__debug 'assert_failure' '=> assertion succeeded'
  else
    dm_test__debug 'assert_failure' '=> assertion failed'

    ___subject='Inverse assertion failed, command succeeded'
    ___reason="Command succeeded but should have failed: '${___command}'."
    ___assertion='assert_failure'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
#   ______ _ _                      _
#  |  ____(_) |                    | |
#  | |__   _| | ___   ___ _   _ ___| |_ ___ _ __ ___
#  |  __| | | |/ _ \ / __| | | / __| __/ _ \ '_ ` _ \
#  | |    | | |  __/ \__ \ |_| \__ \ ||  __/ | | | | |
#  |_|    |_|_|\___| |___/\__, |___/\__\___|_| |_| |_|
#                          __/ |
#=========================|___/================================================
# FILE SYSTEM BASED ASSERTIONS
#==============================================================================

#==============================================================================
# File system based assertion that checks if the given path does name a file.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] file_path - Path that should name a file.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
assert_file() {
  ___file_path="$1"

  dm_test__debug 'assert_file' "asserting file existence: '${___file_path}'"

  if [ -f "$___file_path" ]
  then
    dm_test__debug 'assert_file' '=> assertion succeeded'
  else
    dm_test__debug 'assert_file' '=> assertion failed'

    ___subject='Path does not name a file'
    ___reason="File does not exist at path: '${___file_path}'."
    ___assertion='assert_file'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# File system based assertion that checks if the given path does not name a
# file.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] file_path - Path that should not name a file.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
assert_no_file() {
  ___file_path="$1"

  dm_test__debug 'assert_no_file' \
    "asserting file non existence: '${___file_path}'"

  if [ ! -f "$___file_path" ]
  then
    dm_test__debug 'assert_no_file' '=> assertion succeeded'
  else
    dm_test__debug 'assert_no_file' '=> assertion failed'

    ___subject='File exists on path'
    ___reason="File should not exists at: '${___file_path}'."
    ___assertion='assert_no_file'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# File system based assertion that checks if the given path does name a file
# and that file has nonzero content.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] file_path - Path that should name a file and should have nonzero
#       content.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
assert_file_has_content() {
  ___file_path="$1"

  dm_test__debug 'assert_file_has_content' \
    "asserting file content: '${___file_path}'"

  if [ -f "$___file_path" ]
  then
    if [ -s "$___file_path" ]
    then
      dm_test__debug 'assert_file_has_content' '=> assertion succeeded'
    else
      dm_test__debug 'assert_file_has_content' '=> assertion failed'

      ___subject='File exists but it is empty'
      ___reason="File should not be empty: '${___file_path}'."
      ___assertion='assert_file_has_content'
      _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
    fi
  else
    dm_test__debug 'assert_file_has_content' '=> assertion failed'

    ___subject='Path does not name a file'
    ___reason="File does not exist at path: '${___file_path}'."
    ___assertion='assert_file_has_content'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# File system based assertion that checks if the given path does name a file
# and that file has no content.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] file_path - Path that should name a file but it should be empty.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
assert_file_has_no_content() {
  ___file_path="$1"

  dm_test__debug 'assert_file_has_no_content' \
    "asserting file empty: '${___file_path}'"

  if [ -f "$___file_path" ]
  then
    if [ ! -s "$___file_path" ]
    then
      dm_test__debug 'assert_file_has_no_content' '=> assertion succeeded'
    else
      dm_test__debug 'assert_file_has_no_content' '=> assertion failed'

      ___subject='File exists but it is not empty'
      ___reason="File should be empty: '${___file_path}'."
      ___assertion='assert_file_has_no_content'
      _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
    fi
  else
    dm_test__debug 'assert_file_has_no_content' '=> assertion failed'

    ___subject='Path does not name a file'
    ___reason="File does not exist at path: '${___file_path}'."
    ___assertion='assert_file_has_no_content'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# File system based assertion that checks if the given path does name a
# directory.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] directory_path - Path that needs to name a directory.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
assert_directory() {
  ___directory_path="$1"

  dm_test__debug 'assert_directory' \
    "asserting directory existence: '${___directory_path}'"

  if [ -d "$___directory_path" ]
  then
    dm_test__debug 'assert_directory' '=> assertion succeeded'
  else
    dm_test__debug 'assert_directory' '=> assertion failed'

    ___subject='Path does not name a directory'
    ___reason="Directory does not exist at path: '${___directory_path}'."
    ___assertion='assert_directory'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# File system based assertion that checks if the given path does not name a
# directory.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] directory_path - Path that should not name a directory.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
assert_no_directory() {
  ___directory_path="$1"

  dm_test__debug 'assert_no_directory' \
    "asserting lack of directory: '${___directory_path}'"

  if [ ! -d "$___directory_path" ]
  then
    dm_test__debug 'assert_no_directory' '=> assertion succeeded'
  else
    dm_test__debug 'assert_no_directory' '=> assertion failed'

    ___subject='Path should not name a directory'
    ___reason="Directory should not exist at path: '${___directory_path}'."
    ___assertion='assert_no_directory'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# File system based assertion that checks if the given path does name a
# directory and the directory is empty.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] directory_path - Path that needs to name a directory that should be
#       empty.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
assert_directory_empty() {
  ___directory_path="$1"

  dm_test__debug 'assert_directory_empty' \
    "asserting directory is empty: '${___directory_path}'"

  if [ -d "$___directory_path" ]
  then
    if [ -z "$(ls -A "$___directory_path")" ]
    then
      dm_test__debug 'assert_directory_empty' '=> assertion succeeded'
    else
      dm_test__debug 'assert_directory_empty' '=> assertion failed'

      ___subject='Directory is not empty'
      ___reason="Directory should be empty: '${___directory_path}'."
      ___assertion='assert_directory_empty'
      _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
    fi
  else
    dm_test__debug 'assert_directory_empty' '=> assertion failed'

    ___subject='Path does not name a directory'
    ___reason="Directory does not exist at path: '${___directory_path}'."
    ___assertion='assert_directory_empty'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# File system based assertion that checks if the given path does name a
# directory an the directory is not empty.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] directory_path - Path that needs to name a directory that should not be
#       empty.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
assert_directory_not_empty() {
  ___directory_path="$1"

  dm_test__debug 'assert_directory_not_empty' \
    "asserting directory is not empty: '${___directory_path}'"

  if [ -d "$___directory_path" ]
  then
    if [ -n "$(ls -A "$___directory_path")" ]
    then
      dm_test__debug 'assert_directory_not_empty' '=> assertion succeeded'
    else
      dm_test__debug 'assert_directory_not_empty' '=> assertion failed'

      ___subject='Directory is empty'
      ___reason="Directory should not be empty: '${___directory_path}'."
      ___assertion='assert_directory_not_empty'
      _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
    fi
  else
    dm_test__debug 'assert_directory_not_empty' '=> assertion failed'

    ___subject='Path does not name a directory'
    ___reason="Directory does not exist at path: '${___directory_path}'."
    ___assertion='assert_directory_not_empty'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# File system based assertion that checks if the given path does name a
# symlink.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] link_path - Path that needs to name a symbolic link.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
assert_symlink() {
  ___link_path="$1"

  dm_test__debug 'assert_symlink' \
    "asserting symlink existence: '${___link_path}'"

  if [ -L "$___link_path" ]
  then
    dm_test__debug 'assert_symlink' '=> assertion succeeded'
  else
    dm_test__debug 'assert_symlink' '=> assertion failed'

    ___subject='Path does not name a symbolic link'
    ___reason="Symbolic link does not exist at path: '${___link_path}'."
    ___assertion='assert_symlink'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# File system based assertion that checks if the given path does not name a
# symlink.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] link_path - Path that should not name a symbolic link.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
assert_no_symlink() {
  ___link_path="$1"

  dm_test__debug 'assert_no_symlink' \
    "asserting symlink non existence: '${___link_path}'"

  if [ ! -L "$___link_path" ]
  then
    dm_test__debug 'assert_no_symlink' '=> assertion succeeded'
  else
    dm_test__debug 'assert_no_symlink' '=> assertion failed'

    ___subject='Path should not name a symbolic link'
    ___reason="Symbolic link should not exist at path: '${___link_path}'."
    ___assertion='assert_no_symlink'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# File system based assertion that checks if the given path names a symlink and
# the target is correct.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] link_path - Path that needs to name a symbolic link.
#   [2] target_path - Path that is the target of the link.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test readlink echo
#==============================================================================
assert_symlink_target() {
  ___link_path="$1"
  ___target_path="$2"

  dm_test__debug 'assert_symlink_target' \
    "asserting symlink '${___link_path}' target '${___target_path}'"

  if [ -L "$___link_path" ]
  then
    ___actual_target="$(readlink "$___link_path")"
    if [ "$___target_path" = "$___actual_target" ]
    then
      dm_test__debug 'assert_symlink_target' '=> assertion succeeded'
    else
      dm_test__debug 'assert_symlink_target' '=> assertion failed'

      ___subject='Symbolic link target does not match'
      ___reason="$( \
        echo "expected target: '${___target_path}'"; \
        echo "actual target: '${___actual_target}'." \
      )"
      ___assertion='assert_symlink_target'
      _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
    fi
  else
    dm_test__debug 'assert_symlink_target' '=> assertion failed'

    ___subject='Path does not name a symbolic link'
    ___reason="Symbolic link does not exist at path: '${___link_path}'."
    ___assertion='assert_symlink_target'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
#    _____            _            _     _                        _
#   / ____|          | |          | |   | |                      | |
#  | |     ___  _ __ | |_ _____  _| |_  | |__   __ _ ___  ___  __| |
#  | |    / _ \| '_ \| __/ _ \ \/ / __| | '_ \ / _` / __|/ _ \/ _` |
#  | |___| (_) | | | | ||  __/>  <| |_  | |_) | (_| \__ \  __/ (_| |
#   \_____\___/|_| |_|\__\___/_/\_\\__| |_.__/ \__,_|___/\___|\__,_|
#
#==============================================================================
# CONTEXT BASED ASSERTIONS
#==============================================================================

# Global variables that hold the last execution results of the tested function
# or command.
DM_TEST__ASSERT__RUNTIME__LAST_STATUS='__INVALID__'
DM_TEST__ASSERT__RUNTIME__LAST_OUTPUT='__INVALID__'

#==============================================================================
# Function under test capturer API function. It excepts a list of parameters
# that will be executed while the output and the status will be captured and
# will be put into test case level global output variables. Calling the
# testable function in this way is necessary if we want to use the advanced
# context based assertion functions, as those are working on the output
# variables of this function.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [..] command - Commands and parameters that needs to be executed.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__ASSERT__RUNTIME__LAST_STATUS
#   DM_TEST__ASSERT__RUNTIME__LAST_OUTPUT
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected, as the status of the given command is
#       captured.
#------------------------------------------------------------------------------
# Tools:
#   test printf echo
#==============================================================================
run() {
  dm_test__debug 'run' "running command: '$*'"

  # Storing the passed command as a variable is not an option here, because it
  # would be re-splitted on execution.
  if DM_TEST__ASSERT__RUNTIME__LAST_OUTPUT="$("$@")"
  then
    DM_TEST__ASSERT__RUNTIME__LAST_STATUS="$?"
  else
    DM_TEST__ASSERT__RUNTIME__LAST_STATUS="$?"
  fi

  dm_test__debug_list 'run' 'captured output:' \
    "$DM_TEST__ASSERT__RUNTIME__LAST_OUTPUT"
  dm_test__debug 'run' "$( \
    printf '%s' 'captured status: '; \
    echo "'${DM_TEST__ASSERT__RUNTIME__LAST_STATUS}'" \
  )"
}

#==============================================================================
# Context based assertion function that will evaluate the previously set
# 'status' variable by the 'run' function.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__ASSERT__RUNTIME__LAST_STATUS
# Arguments:
#   [1] expected_status - Expected status of the previously run function.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
assert_status() {
  ___expected="$1"
  ___result="$DM_TEST__ASSERT__RUNTIME__LAST_STATUS"

  dm_test__debug 'assert_status' 'asserting status:'
  dm_test__debug 'assert_status' "- expected: '${___expected}'"
  dm_test__debug 'assert_status' "- result:   '${___result}'"

  if [ "$___result" = "$___expected" ]
  then
    dm_test__debug 'assert_status' '=> assertion succeeded'
  else
    dm_test__debug 'assert_status' '=> assertion failed'

    ___subject='Status comparison failed'
    ___reason="expected: ${___expected}\n  actual: ${___result}"
    ___assertion='assert_status'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Context based assertion function that will evaluate the previously set output
# variables by the 'run' function.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__ASSERT__RUNTIME__LAST_OUTPUT
# Arguments:
#   [1] expected_output - Expected output of the previously run function.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
# - None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test echo wc printf
#==============================================================================
assert_output() {
  ___expected="$1"
  ___result="$DM_TEST__ASSERT__RUNTIME__LAST_OUTPUT"
  ___count="$(echo "$___result" | wc --lines)"

  if [ "$___count" -ne '1' ]
  then
    dm_test__debug 'assert_output' '=> assertion failed'

    ___subject='Inappropriate assertion function'
    ___reason="$( \
      printf '%s' 'Multiline output should be asserted with '; \
      echo "'assert_line_at_index' or 'assert_line_partially_at_index'." \
    )"
    ___assertion='assert_output'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi

  dm_test__debug 'assert_output' 'asserting output:'
  dm_test__debug 'assert_output' "- expected: '${___expected}'"
  dm_test__debug 'assert_output' "- result:   '${___result}'"

  if [ "$___result" = "$___expected" ]
  then
    dm_test__debug 'assert_output' '=> assertion succeeded'
  else
    dm_test__debug 'assert_output' '=> assertion failed'

    ___subject='Output comparison failed'
    ___reason="expected: '${___expected}'\n  actual: '${___result}'"
    ___assertion='assert_output'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Context based assertion function to check the line count of the command
# output runned with the 'run' function.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__ASSERT__RUNTIME__LAST_OUTPUT
# Arguments:
#   [1] expected_line_count - Expected output line count.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   echo wc test
#==============================================================================
assert_output_line_count() {
  ___expected="$1"
  ___result="$(echo "$DM_TEST__ASSERT__RUNTIME__LAST_OUTPUT" | wc --lines)"

  dm_test__debug 'assert_output_line_count' 'asserting output line count:'
  dm_test__debug 'assert_output_line_count' "- expected: '${___expected}'"
  dm_test__debug 'assert_output_line_count' "- result:   '${___result}'"

  if [ "$___result" -eq "$___expected" ]
  then
    dm_test__debug 'assert_output_line_count' '=> assertion succeeded'
  else
    dm_test__debug 'assert_output_line_count' '=> assertion failed'

    ___subject='Output line count mismatch'
    ___reason="expected: '${___expected}'\n  actual: '${___result}'"
    ___assertion='assert_output_line_count'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Context based assertion function that compares the output line indexed by the
# index parameter with the expected parameter.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__ASSERT__RUNTIME__LAST_OUTPUT
# Arguments:
#   [1] line_index - One-based line index.
#   [2] expected - Expected content of the given line without the new line
#       character.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
assert_line_at_index() {
  ___index="$1"
  ___expected="$2"

  if ___result="$( \
    dm_test__get_line_from_output_by_index \
      "$___index" \
      "$DM_TEST__ASSERT__RUNTIME__LAST_OUTPUT" \
  )"
  then
    # Line extraction succeeded, the '__result' variable contains the extracted
    # line.
    :
  else
    # As the line extraction function returned a nonzero status, the line
    # extraction failed, and the error was already reported. Since it is
    # happened in a subshell to obtain the output from it, the execution won't
    # stopped here, so we should simply return from here.
    return
  fi

  dm_test__debug 'assert_line_at_index' 'asserting output line at index:'
  dm_test__debug 'assert_line_at_index' "- expected: '${___expected}'"
  dm_test__debug 'assert_line_at_index' "- result:   '${___result}'"

  if [ "$___result" = "$___expected" ]
  then
    dm_test__debug 'assert_line_at_index' '=> assertion succeeded'
  else
    dm_test__debug 'assert_line_at_index' '=> assertion failed'

    ___subject="Line at index '${___index}' differs from expected"
    ___reason="expected: '${___expected}'\n  actual: '${___result}'"
    ___assertion='assert_line_at_index'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Context based assertion function that compares the output line indexed by the
# index parameter with the expected parameter. The line has to partially match
# only, should be a part of the whole output line.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__ASSERT__RUNTIME__LAST_OUTPUT
# Arguments:
#   [1] line_index - One-based line index.
#   [2] expected - Expected content of the given line without the new line
#       character.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test echo grep
#==============================================================================
assert_line_partially_at_index() {
  ___index="$1"
  ___expected="$2"

  if ___result="$( \
    dm_test__get_line_from_output_by_index \
      "$___index" \
      "$DM_TEST__ASSERT__RUNTIME__LAST_OUTPUT" \
  )"
  then
    # Line extraction succeeded, the '__result' variable contains the extracted
    # line.
    :
  else
    # As the line extraction function returned a nonzero status, the line
    # extraction failed, and the error was already reported. Since it is
    # happened in a subshell to obtain the output from it, the execution won't
    # stopped here, so we should simply return from here.
    return
  fi

  dm_test__debug 'assert_line_partially_at_index' \
    'asserting output line at index partially:'
  dm_test__debug 'assert_line_partially_at_index' "- pattern: '${___expected}'"
  dm_test__debug 'assert_line_partially_at_index' "- target:   '${___result}'"

  if echo "$___result" | grep --silent "$___expected"
  then
    dm_test__debug 'assert_line_partially_at_index' '=> assertion succeeded'
  else
    dm_test__debug 'assert_line_partially_at_index' '=> assertion failed'

    ___subject="Line at index '${___index}' differs from expected'"
    ___reason="expected: '${___expected}'\n  actual: '${___result}'"
    ___assertion='assert_line_partially_at_index'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
#   _    _ _   _ _ _ _   _
#  | |  | | | (_) (_) | (_)
#  | |  | | |_ _| |_| |_ _  ___  ___
#  | |  | | __| | | | __| |/ _ \/ __|
#  | |__| | |_| | | | |_| |  __/\__ \
#   \____/ \__|_|_|_|\__|_|\___||___/
#
#==============================================================================
# TEST UTILITIES
#==============================================================================

#==============================================================================
# Utility function to get the Nth line of the output while validating the given
# one-based index. If the index is invalid, it will behave as a failed
# assertion. This function can be used in the test cases as a helper function
# to access specific lines in the output.
#
# This function is intended to be used in the test cases if needed, hence the
# missing assert naming scope.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__ASSERT__RUNTIME__LAST_OUTPUT
# Arguments:
#   [1] line_index - One-based line index.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Indexed line if the index is valid.
# STDERR:
#   None
# Status:
#   0 - Line extraction succeeded.
#   1 - Line extraction failed.
#------------------------------------------------------------------------------
# Tools:
#   echo wc sed test
#==============================================================================
dm_test__get_line_from_output_by_index() {
  ___line_index="$1"

  ___lines="$DM_TEST__ASSERT__RUNTIME__LAST_OUTPUT"

  dm_test__debug_list 'dm_test__get_line_from_output_by_index' \
    "getting line for index '${___line_index}' from output:" "$___lines"

  ___line_count="$(echo "$___lines" | wc --lines)"
  if [ "$___line_index" -gt "$___line_count" ] || [ "$___line_index" -lt '1' ]
  then
    dm_test__debug 'dm_test__get_line_from_output_by_index' \
      "invalid line index! should be inside the range of [1-${___line_count}]"

    ___subject='Line index is out of range'
    ___reason="$( \
      echo "index should be in range: [1-${___line_count}]"; \
      echo "given index: '${___line_index}'" \
    )"
    ___assertion='utils__get_line_from_output_by_index'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi

  # Getting the indexed line.
  ___line="$(echo "$___lines" | sed "${___line_index}q;d")"

  dm_test__debug_list 'dm_test__get_line_from_output_by_index' \
    'line selected:' "$___line"

  echo "$___line"
}

#==============================================================================
#  ____       _            _         _          _
# |  _ \ _ __(_)_   ____ _| |_ ___  | |__   ___| |_ __   ___ _ __ ___
# | |_) | '__| \ \ / / _` | __/ _ \ | '_ \ / _ \ | '_ \ / _ \ '__/ __|
# |  __/| |  | |\ V / (_| | ||  __/ | | | |  __/ | |_) |  __/ |  \__ \
# |_|   |_|  |_| \_/ \__,_|\__\___| |_| |_|\___|_| .__/ \___|_|  |___/
#================================================|_|===========================
# PRIVATE HELPERS
#==============================================================================

#==============================================================================
# Common failure reporting helper function. It sets the test case to failed,
# generates the error report, appends it to the global error list, then exits
# the test case. There is no point to check further assertions.
#------------------------------------------------------------------------------
# Globals:
#   RED
#   BOLD
#   RESET
# Arguments:
#   [1] subject - Subject of the failure.
#   [2] reason - Reason of the failure.
#   [3] assertion - Assertion function name that produced that failed.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   1 - This function will exit the caller process with status 1.
#------------------------------------------------------------------------------
# Tools:
#   echo printf sed exit
#==============================================================================
_dm_test__report_failure() {
  ___subject="$1"
  ___reason="$2"
  ___assertion="$3"

  dm_test__debug '_dm_test__report_failure' \
    'reporting failure and exiting from test case..'

  dm_test__cache__test_result__mark_as_failed

  ___test_case_identifier="$( \
    dm_test__test_case__get_current_test_case_identifier \
  )"
  # Appending the current error report to the error cache file.
  {
    echo "${RED}${BOLD}${___test_case_identifier}${RESET}";
    printf '%s' "  ${RED}${___subject}: ";
    echo "[${BOLD}${___assertion}${RESET}${RED}]${RESET}";
    # We want to use printf here to display the inline line newlines, so using
    # only the template parameter, shellcheck can be disabled.
    # shellcheck disable=SC2059
    printf "${RED}${___reason}${RESET}\n" | sed 's/^/    /';
    echo "";
  } | dm_test__cache__global_errors__write_errors

  # Report the concise error report to the standard error.
  >&2 printf '%s' "${___assertion} | "
  >&2 echo "Aborting due to failed assertion: ${BOLD}${___subject}${RESET}."

  # Only the first  assertion error should be reported, the latter ones could
  # be the direct result of the first one, so they have minimal new information
  # content. Explicitly exiting after the first report. This should end the
  # testcase subprocess inside the test file subprocess.
  exit 1
}
