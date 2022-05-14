#!/bin/sh
#==============================================================================
# FILESYSTEM ASSERTIONS - Operates on the file system.
#==============================================================================

setup() {
  # The three different level of test directories are injected into every test
  # case function and into the hook functions as well as 3 parameters that you
  # can use if you need them.
  test_case_level_test_directory="$3"

  # Using the test case level temporary directory to create the dummy paths
  # in there. These paths will be different for each test case as we are using
  # the test case level test directory here. This won't create the file, just
  # saves the path to a variable.
  dummy_file="${test_case_level_test_directory}/dummy_file.txt"
  dummy_directory="${test_case_level_test_directory}/dummy_directory"
  dummy_link="${test_case_level_test_directory}/dummy_link"
}

#==============================================================================
# ASSERT_FILE
#------------------------------------------------------------------------------
# Assert if the path names a file. An existing file should succeed regardless
# of it is empty or has nonzero content. Only file will succeed, if the file
# names a directory or a link, the assertion will fail.
#==============================================================================

test__assert_file__empty_file() {
  posix_adapter__touch "$dummy_file"
  assert_file "$dummy_file"
}

test__assert_file__non_empty_file() {
  echo 'content' > "$dummy_file"
  assert_file "$dummy_file"
}

should_fail__assert_file__no_file() {
  echo 'Expected [assert_file] failure.'
  assert_file "$dummy_file"
}

should_fail__assert_file__has_to_be_a_file() {
  echo 'Expected [assert_file] failure.'
  posix_adapter__mkdir "$dummy_file"
  assert_file "$dummy_file"
}

#==============================================================================
# ASSERT_NO_FILE
#------------------------------------------------------------------------------
# Asserts if there is no file at the given path.
#==============================================================================

test__assert_no_file() {
  assert_no_file "$dummy_file"
}

should_fail__assert_no_file() {
  echo 'Expected [assert_no_file] failure.'
  posix_adapter__touch "$dummy_file"
  assert_no_file "$dummy_file"
}

#==============================================================================
# ASSERT_FILE_HAS_CONTENT
#------------------------------------------------------------------------------
# Asserts if the given path names a file and the file has nonzero content.
#==============================================================================

test__assert_file_has_content() {
  echo 'content' > "$dummy_file"
  assert_file_has_content "$dummy_file"
}

should_fail__assert_file_has_content__file_has_to_exist() {
  echo 'Expected [assert_file_has_content] failure.'
  assert_file_has_content "$dummy_file"
}

should_fail__assert_file_has_content__file_should_not_be_empty() {
  echo 'Expected [assert_file_has_content] failure.'
  posix_adapter__touch "$dummy_file"
  assert_file_has_content "$dummy_file"
}

#==============================================================================
# ASSERT_FILE_HAS_NO_CONTENT
#------------------------------------------------------------------------------
# Assert if the given path names a file but it has to be empty.
#==============================================================================

test__assert_file_has_no_content() {
  posix_adapter__touch "$dummy_file"
  assert_file_has_no_content "$dummy_file"
}

should_fail__assert_file_has_no_content__file_should_exist() {
  echo 'Expected [assert_file_has_no_content] failure.'
  assert_file_has_no_content "$dummy_file"
}

should_fail__assert_file_has_no_content__file_should_be_empty() {
  echo 'Expected [assert_file_has_no_content] failure.'
  echo 'content' > "$dummy_file"
  assert_file_has_no_content "$dummy_file"
}

#==============================================================================
# ASSERT_DIRECTORY
#------------------------------------------------------------------------------
# Assert if the path names a directory.
#==============================================================================

test__assert_directory() {
  posix_adapter__mkdir "$dummy_directory"
  assert_directory "$dummy_directory"
}

should_fail__assert_directory__no_directory() {
  echo 'Expected [assert_directory] failure.'
  assert_directory "$dummy_directory"
}

should_fail__assert_directory__not_a_directory() {
  echo 'Expected [assert_directory] failure.'
  posix_adapter__touch "$dummy_directory"
  assert_directory "$dummy_directory"
}

#==============================================================================
# ASSERT_NO_DIRECTORY
#------------------------------------------------------------------------------
# Assert if the path does not name a directory.
#==============================================================================

test__assert_no_directory() {
  assert_no_directory "$dummy_directory"
}

should_fail__assert_no_directory() {
  echo 'Expected [assert_no_directory] failure.'
  posix_adapter__mkdir "$dummy_directory"
  assert_no_directory "$dummy_directory"
}

#==============================================================================
# ASSERT_DIRECTORY_EMPTY
#------------------------------------------------------------------------------
# Assert if the path names a directory and it is empty.
#==============================================================================

test__assert_directory_empty() {
  posix_adapter__mkdir "$dummy_directory"
  assert_directory_empty "$dummy_directory"
}

should_fail__assert_directory_empty() {
  echo 'Expected [assert_directory_empty] failure.'
  posix_adapter__mkdir "$dummy_directory"
  touch "${dummy_directory}/dummy_file"
  assert_directory_empty "$dummy_directory"
}

should_fail__assert_directory_empty__directory_should_present() {
  echo 'Expected [assert_directory_empty] failure.'
  assert_directory_empty "$dummy_directory"
}

#==============================================================================
# ASSERT_DIRECTORY_NOT_EMPTY
#------------------------------------------------------------------------------
# Assert if the path names a directory and it is empty.
#==============================================================================

test__assert_directory_not_empty() {
  posix_adapter__mkdir "$dummy_directory"
  touch "${dummy_directory}/dummy_file"
  assert_directory_not_empty "$dummy_directory"
}

should_fail__assert_directory_not_empty() {
  echo 'Expected [assert_directory_not_empty] failure.'
  posix_adapter__mkdir "$dummy_directory"
  assert_directory_not_empty "$dummy_directory"
}

should_fail__assert_directory_not_empty__directory_should_present() {
  echo 'Expected [assert_directory_not_empty] failure.'
  assert_directory_not_empty "$dummy_directory"
}

#==============================================================================
# ASSERT_SYMLINK
#------------------------------------------------------------------------------
# Assert if the path names a symbolic link.
#==============================================================================

test__assert_symlink() {
  posix_adapter__touch "$dummy_file"
  posix_adapter__ln --symbolic --path-to-file "$dummy_file" --path-to-link "$dummy_link"
  assert_symlink "$dummy_link"
}

should_fail__assert_symlink__has_to_be_a_link() {
  echo 'Expected [assert_symlink] failure.'
  posix_adapter__touch "$dummy_file"
  assert_symlink "$dummy_file"
}

should_fail__assert_symlink__has_to_exists() {
  echo 'Expected [assert_symlink] failure.'
  assert_symlink "$dummy_link"
}

#==============================================================================
# ASSERT_NO_SYMLINK
#------------------------------------------------------------------------------
# Assert if the path does not name a symbolic link.
#==============================================================================

test__assert_no_symlink__not_exist() {
  assert_no_symlink "$dummy_link"
}

test__assert_no_symlink__not_file() {
  posix_adapter__touch "$dummy_file"
  assert_no_symlink "$dummy_file"
}

should_fail__assert_no_symlink() {
  echo 'Expected [assert_no_symlink] failure.'
  posix_adapter__touch "$dummy_file"
  posix_adapter__ln --symbolic --path-to-file "$dummy_file" --path-to-link "$dummy_link"
  assert_no_symlink "$dummy_link"
}

#==============================================================================
# ASSERT_SYMLINK_TARGET
#------------------------------------------------------------------------------
# Assert if the path is a link and the target is given.
#==============================================================================

test__assert_symlink_target() {
  posix_adapter__touch "$dummy_file"
  posix_adapter__ln --symbolic --path-to-file "$dummy_file" --path-to-link "$dummy_link"
  assert_symlink_target "$dummy_link" "$dummy_file"
}

should_fail__assert_symlink_target__target_mismatch() {
  echo 'Expected [assert_symlink_target] failure.'
  posix_adapter__touch "$dummy_file"
  posix_adapter__ln --symbolic --path-to-file "$dummy_file" --path-to-link "$dummy_link"
  assert_symlink_target "$dummy_link" "non_existent_target.txt"
}

should_fail__assert_symlink_target__no_link() {
  echo 'Expected [assert_symlink_target] failure.'
  posix_adapter__touch "$dummy_file"
  assert_symlink_target "$dummy_link" "$dummy_file"
}

should_fail__assert_symlink_target__not_a_link() {
  echo 'Expected [assert_symlink_target] failure.'
  posix_adapter__touch "$dummy_file"
  assert_symlink_target "$dummy_link" "$dummy_file"
}
