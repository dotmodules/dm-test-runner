#==============================================================================
# TEST HOOKS
#==============================================================================

#==============================================================================
# During execution the test runner provides temporary directories that are
# vailable for the test cases to create and reuse test fixtures. There are
# three level of persistency: test case, test file and test suite. The test
# case level only valid for a lifetime of a test case. The test case level is
# available during a test file exeution. The test suite level is available
# during the whole test suite execution.
#
# The following test cases will demonstrate this behavior. There are three file
# paths created during the setup hook for each test case. The test case level
# path should be unique for every test case. The test file level paths should
# be unique for a test file. The test suite level path should be the same for
# the test suite.
#==============================================================================

setup_file() {
  echo 'setup file'
  cat imre
}

setup() {
  echo 'setup'
}

teardown() {
  echo 'teardown'
}

teardown_file() {
  echo 'teardown file'
}

test__hooks__test_case() {
  echo 'test case'
}
