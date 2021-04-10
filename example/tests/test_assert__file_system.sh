#==============================================================================
# FILESYSTEM ASSERTIONS - Operates on the file system.
#==============================================================================

setup() {
  # Using the test case level temporary directory to create the dummy paths
  # in there. These paths will be different for each test case as we are using
  # the test case level test directory here. This won't create the file, just
  # saves the path to a variable.
  dummy_file="${DM_TEST__TEST_DIR__TEST_CASE_LEVEL}/dummy_file.txt"
  dummy_directory="${DM_TEST__TEST_DIR__TEST_CASE_LEVEL}/dummy_directory"
  dummy_link="${DM_TEST__TEST_DIR__TEST_CASE_LEVEL}/dummy_link"
}

#==============================================================================
# ASSERT_FILE
#------------------------------------------------------------------------------
# Assert if the path names a file. An existing file should succeed regardless
# of it is empty or has nonzero content. Only file will succeed, if the file
# names a directory or a link, the assertion will fail.
#==============================================================================

test__assert_file__empty_file() {
  dm_tools__touch "$dummy_file"
  assert_file "$dummy_file"
}

test__assert_file__non_empty_file() {
  dm_tools__echo 'content' > "$dummy_file"
  assert_file "$dummy_file"
}

should_fail__assert_file__no_file() {
  dm_tools__echo 'Expected [assert_file] failure.'
  assert_file "$dummy_file"
}

should_fail__assert_file__has_to_be_a_file() {
  dm_tools__echo 'Expected [assert_file] failure.'
  dm_tools__mkdir "$dummy_file"
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
  dm_tools__echo 'Expected [assert_no_file] failure.'
  dm_tools__touch "$dummy_file"
  assert_no_file "$dummy_file"
}

#==============================================================================
# ASSERT_FILE_HAS_CONTENT
#------------------------------------------------------------------------------
# Asserts if the given path names a file and the file has nonzero content.
#==============================================================================

test__assert_file_has_content() {
  dm_tools__echo 'content' > "$dummy_file"
  assert_file_has_content "$dummy_file"
}

should_fail__assert_file_has_content__file_has_to_exist() {
  dm_tools__echo 'Expected [assert_file_has_content] failure.'
  assert_file_has_content "$dummy_file"
}

should_fail__assert_file_has_content__file_should_not_be_empty() {
  dm_tools__echo 'Expected [assert_file_has_content] failure.'
  dm_tools__touch "$dummy_file"
  assert_file_has_content "$dummy_file"
}

#==============================================================================
# ASSERT_FILE_HAS_NO_CONTENT
#------------------------------------------------------------------------------
# Assert if the given path names a file but it has to be empty.
#==============================================================================

test__assert_file_has_no_content() {
  dm_tools__touch "$dummy_file"
  assert_file_has_no_content "$dummy_file"
}

should_fail__assert_file_has_no_content__file_should_exist() {
  dm_tools__echo 'Expected [assert_file_has_no_content] failure.'
  assert_file_has_no_content "$dummy_file"
}

should_fail__assert_file_has_no_content__file_should_be_empty() {
  dm_tools__echo 'Expected [assert_file_has_no_content] failure.'
  dm_tools__echo 'content' > "$dummy_file"
  assert_file_has_no_content "$dummy_file"
}

#==============================================================================
# ASSERT_DIRECTORY
#------------------------------------------------------------------------------
# Assert if the path names a directory.
#==============================================================================

test__assert_directory() {
  dm_tools__mkdir "$dummy_directory"
  assert_directory "$dummy_directory"
}

should_fail__assert_directory__no_directory() {
  dm_tools__echo 'Expected [assert_directory] failure.'
  assert_directory "$dummy_directory"
}

should_fail__assert_directory__not_a_directory() {
  dm_tools__echo 'Expected [assert_directory] failure.'
  dm_tools__touch "$dummy_directory"
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
  dm_tools__echo 'Expected [assert_no_directory] failure.'
  dm_tools__mkdir "$dummy_directory"
  assert_no_directory "$dummy_directory"
}

#==============================================================================
# ASSERT_DIRECTORY_EMPTY
#------------------------------------------------------------------------------
# Assert if the path names a directory and it is empty.
#==============================================================================

test__assert_directory_empty() {
  dm_tools__mkdir "$dummy_directory"
  assert_directory_empty "$dummy_directory"
}

should_fail__assert_directory_empty() {
  dm_tools__echo 'Expected [assert_directory_empty] failure.'
  dm_tools__mkdir "$dummy_directory"
  touch "${dummy_directory}/dummy_file"
  assert_directory_empty "$dummy_directory"
}

should_fail__assert_directory_empty__directory_should_present() {
  dm_tools__echo 'Expected [assert_directory_empty] failure.'
  assert_directory_empty "$dummy_directory"
}

#==============================================================================
# ASSERT_DIRECTORY_NOT_EMPTY
#------------------------------------------------------------------------------
# Assert if the path names a directory and it is empty.
#==============================================================================

test__assert_directory_not_empty() {
  dm_tools__mkdir "$dummy_directory"
  touch "${dummy_directory}/dummy_file"
  assert_directory_not_empty "$dummy_directory"
}

should_fail__assert_directory_not_empty() {
  dm_tools__echo 'Expected [assert_directory_not_empty] failure.'
  dm_tools__mkdir "$dummy_directory"
  assert_directory_not_empty "$dummy_directory"
}

should_fail__assert_directory_not_empty__directory_should_present() {
  dm_tools__echo 'Expected [assert_directory_not_empty] failure.'
  assert_directory_not_empty "$dummy_directory"
}

#==============================================================================
# ASSERT_SYMLINK
#------------------------------------------------------------------------------
# Assert if the path names a symbolic link.
#==============================================================================

test__assert_symlink() {
  dm_tools__touch "$dummy_file"
  dm_tools__ln --symbolic --target "$dummy_file" --link-name "$dummy_link"
  assert_symlink "$dummy_link"
}

should_fail__assert_symlink__has_to_be_a_link() {
  dm_tools__echo 'Expected [assert_symlink] failure.'
  dm_tools__touch "$dummy_file"
  assert_symlink "$dummy_file"
}

should_fail__assert_symlink__has_to_exists() {
  dm_tools__echo 'Expected [assert_symlink] failure.'
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
  dm_tools__touch "$dummy_file"
  assert_no_symlink "$dummy_file"
}

should_fail__assert_no_symlink() {
  dm_tools__echo 'Expected [assert_no_symlink] failure.'
  dm_tools__touch "$dummy_file"
  dm_tools__ln --symbolic --target "$dummy_file" --link-name "$dummy_link"
  assert_no_symlink "$dummy_link"
}

#==============================================================================
# ASSERT_SYMLINK_TARGET
#------------------------------------------------------------------------------
# Assert if the path is a link and the target is given.
#==============================================================================

test__assert_symlink_target() {
  dm_tools__touch "$dummy_file"
  dm_tools__ln --symbolic --target "$dummy_file" --link-name "$dummy_link"
  assert_symlink_target "$dummy_link" "$dummy_file"
}

should_fail__assert_symlink_target__target_mismatch() {
  dm_tools__echo 'Expected [assert_symlink_target] failure.'
  dm_tools__touch "$dummy_file"
  dm_tools__ln --symbolic --target "$dummy_file" --link-name "$dummy_link"
  assert_symlink_target "$dummy_link" "non_existent_target.txt"
}

should_fail__assert_symlink_target__no_link() {
  dm_tools__echo 'Expected [assert_symlink_target] failure.'
  dm_tools__touch "$dummy_file"
  assert_symlink_target "$dummy_link" "$dummy_file"
}

should_fail__assert_symlink_target__not_a_link() {
  dm_tools__echo 'Expected [assert_symlink_target] failure.'
  dm_tools__touch "$dummy_file"
  assert_symlink_target "$dummy_link" "$dummy_file"
}
