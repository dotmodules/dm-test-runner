#!/bin/sh
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
# File system based assertions can be executed at any time without any context
# as they are working on the given parameters only. They can be used to check
# file system related facts.
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
#==============================================================================
assert_file() {
  ___file_path="$1"

  posix_test__debug 'assert_file' "asserting file existence: '${___file_path}'"

  if [ -f "$___file_path" ]
  then
    posix_test__debug 'assert_file' '=> assertion succeeded'
  else
    posix_test__debug 'assert_file' '=> assertion failed'

    ___subject='Path does not name a file'
    ___reason="File does not exist at path: '${___file_path}'."
    ___assertion='assert_file'
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
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
#==============================================================================
assert_no_file() {
  ___file_path="$1"

  posix_test__debug 'assert_no_file' \
    "asserting file non existence: '${___file_path}'"

  if [ ! -f "$___file_path" ]
  then
    posix_test__debug 'assert_no_file' '=> assertion succeeded'
  else
    posix_test__debug 'assert_no_file' '=> assertion failed'

    ___subject='File exists on path'
    ___reason="File should not exists at: '${___file_path}'."
    ___assertion='assert_no_file'
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
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
#==============================================================================
assert_file_has_content() {
  ___file_path="$1"

  posix_test__debug 'assert_file_has_content' \
    "asserting file content: '${___file_path}'"

  if [ -f "$___file_path" ]
  then
    if [ -s "$___file_path" ]
    then
      posix_test__debug 'assert_file_has_content' '=> assertion succeeded'
    else
      posix_test__debug 'assert_file_has_content' '=> assertion failed'

      ___subject='File exists but it is empty'
      ___reason="File should not be empty: '${___file_path}'."
      ___assertion='assert_file_has_content'
      _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
    fi
  else
    posix_test__debug 'assert_file_has_content' '=> assertion failed'

    ___subject='Path does not name a file'
    ___reason="File does not exist at path: '${___file_path}'."
    ___assertion='assert_file_has_content'
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
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
#==============================================================================
assert_file_has_no_content() {
  ___file_path="$1"

  posix_test__debug 'assert_file_has_no_content' \
    "asserting file empty: '${___file_path}'"

  if [ -f "$___file_path" ]
  then
    if [ ! -s "$___file_path" ]
    then
      posix_test__debug 'assert_file_has_no_content' '=> assertion succeeded'
    else
      posix_test__debug 'assert_file_has_no_content' '=> assertion failed'

      ___subject='File exists but it is not empty'
      ___reason="File should be empty: '${___file_path}'."
      ___assertion='assert_file_has_no_content'
      _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
    fi
  else
    posix_test__debug 'assert_file_has_no_content' '=> assertion failed'

    ___subject='Path does not name a file'
    ___reason="File does not exist at path: '${___file_path}'."
    ___assertion='assert_file_has_no_content'
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
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
#==============================================================================
assert_directory() {
  ___directory_path="$1"

  posix_test__debug 'assert_directory' \
    "asserting directory existence: '${___directory_path}'"

  if [ -d "$___directory_path" ]
  then
    posix_test__debug 'assert_directory' '=> assertion succeeded'
  else
    posix_test__debug 'assert_directory' '=> assertion failed'

    ___subject='Path does not name a directory'
    ___reason="Directory does not exist at path: '${___directory_path}'."
    ___assertion='assert_directory'
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
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
#==============================================================================
assert_no_directory() {
  ___directory_path="$1"

  posix_test__debug 'assert_no_directory' \
    "asserting lack of directory: '${___directory_path}'"

  if [ ! -d "$___directory_path" ]
  then
    posix_test__debug 'assert_no_directory' '=> assertion succeeded'
  else
    posix_test__debug 'assert_no_directory' '=> assertion failed'

    ___subject='Path should not name a directory'
    ___reason="Directory should not exist at path: '${___directory_path}'."
    ___assertion='assert_no_directory'
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
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
#==============================================================================
assert_directory_empty() {
  ___directory_path="$1"

  posix_test__debug 'assert_directory_empty' \
    "asserting directory is empty: '${___directory_path}'"

  if [ -d "$___directory_path" ]
  then
    if [ -z "$(posix_adapter__ls --almost-all "$___directory_path")" ]
    then
      posix_test__debug 'assert_directory_empty' '=> assertion succeeded'
    else
      posix_test__debug 'assert_directory_empty' '=> assertion failed'

      ___subject='Directory is not empty'
      ___reason="Directory should be empty: '${___directory_path}'."
      ___assertion='assert_directory_empty'
      _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
    fi
  else
    posix_test__debug 'assert_directory_empty' '=> assertion failed'

    ___subject='Path does not name a directory'
    ___reason="Directory does not exist at path: '${___directory_path}'."
    ___assertion='assert_directory_empty'
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# File system based assertion that checks if the given path does name a
# directory and the directory is not empty.
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
#==============================================================================
assert_directory_not_empty() {
  ___directory_path="$1"

  posix_test__debug 'assert_directory_not_empty' \
    "asserting directory is not empty: '${___directory_path}'"

  if [ -d "$___directory_path" ]
  then
    if [ -n "$(posix_adapter__ls --almost-all "$___directory_path")" ]
    then
      posix_test__debug 'assert_directory_not_empty' '=> assertion succeeded'
    else
      posix_test__debug 'assert_directory_not_empty' '=> assertion failed'

      ___subject='Directory is empty'
      ___reason="Directory should not be empty: '${___directory_path}'."
      ___assertion='assert_directory_not_empty'
      _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
    fi
  else
    posix_test__debug 'assert_directory_not_empty' '=> assertion failed'

    ___subject='Path does not name a directory'
    ___reason="Directory does not exist at path: '${___directory_path}'."
    ___assertion='assert_directory_not_empty'
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
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
#==============================================================================
assert_symlink() {
  ___link_path="$1"

  posix_test__debug 'assert_symlink' \
    "asserting symlink existence: '${___link_path}'"

  if [ -L "$___link_path" ]
  then
    posix_test__debug 'assert_symlink' '=> assertion succeeded'
  else
    posix_test__debug 'assert_symlink' '=> assertion failed'

    ___subject='Path does not name a symbolic link'
    ___reason="Symbolic link does not exist at path: '${___link_path}'."
    ___assertion='assert_symlink'
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
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
#==============================================================================
assert_no_symlink() {
  ___link_path="$1"

  posix_test__debug 'assert_no_symlink' \
    "asserting symlink non existence: '${___link_path}'"

  if [ ! -L "$___link_path" ]
  then
    posix_test__debug 'assert_no_symlink' '=> assertion succeeded'
  else
    posix_test__debug 'assert_no_symlink' '=> assertion failed'

    ___subject='Path should not name a symbolic link'
    ___reason="Symbolic link should not exist at path: '${___link_path}'."
    ___assertion='assert_no_symlink'
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
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
#==============================================================================
assert_symlink_target() {
  ___link_path="$1"
  ___target_path="$2"

  posix_test__debug 'assert_symlink_target' \
    "asserting symlink '${___link_path}' target '${___target_path}'"

  if [ -L "$___link_path" ]
  then
    ___actual_target="$(posix_adapter__readlink "$___link_path")"
    if [ "$___target_path" = "$___actual_target" ]
    then
      posix_test__debug 'assert_symlink_target' '=> assertion succeeded'
    else
      posix_test__debug 'assert_symlink_target' '=> assertion failed'

      ___subject='Symbolic link target does not match'
      ___reason="$( \
        echo "expected target: '${___target_path}'"; \
        echo "actual target: '${___actual_target}'." \
      )"
      ___assertion='assert_symlink_target'
      _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
    fi
  else
    posix_test__debug 'assert_symlink_target' '=> assertion failed'

    ___subject='Path does not name a symbolic link'
    ___reason="Symbolic link does not exist at path: '${___link_path}'."
    ___assertion='assert_symlink_target'
    _posix_test__assert__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}
