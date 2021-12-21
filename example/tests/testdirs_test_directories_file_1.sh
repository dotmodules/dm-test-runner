#==============================================================================
# TEST DIRECTORIES
#==============================================================================

#==============================================================================
# During execution the test runner provides temporary directories that are
# available for the test cases to create and reuse test fixtures. There are
# three level of persistency: test case, test file and test suite. The test
# case level only valid for a lifetime of a test case. The test case level is
# available during a test file exeution. The test suite level is available
# during the whole test suite execution.
#
# The following test cases will demonstrate this behavior. The test case level
# path should be unique for every test case. The test file level paths should
# be unique for a test file. The test suite level path should be the same for
# the test suite.
#==============================================================================

test__test_directories__file_1__case_1() {
  dm_tools__echo "[test case] level path:  ${DM_TEST__TEST_DIR__TEST_CASE_LEVEL}"
  dm_tools__echo "[test file] level path:  ${DM_TEST__TEST_DIR__TEST_FILE_LEVEL}"
  dm_tools__echo "[test suite] level path: ${DM_TEST__TEST_DIR__TEST_SUITE_LEVEL}"
  >&2 dm_tools__echo 'making the test case fail intentionally to print the outputs'
}

test__test_directories__file_1__case_2() {
  dm_tools__echo "[test case] level path:  ${DM_TEST__TEST_DIR__TEST_CASE_LEVEL}"
  dm_tools__echo "[test file] level path:  ${DM_TEST__TEST_DIR__TEST_FILE_LEVEL}"
  dm_tools__echo "[test suite] level path: ${DM_TEST__TEST_DIR__TEST_SUITE_LEVEL}"
  >&2 dm_tools__echo 'making the test case fail intentionally to print the outputs'
}
