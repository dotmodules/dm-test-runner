#==============================================================================
#    _____           _
#   / ____|         | |
#  | |     __ _  ___| |__   ___
#  | |    / _` |/ __| '_ \ / _ \
#  | |___| (_| | (__| | | |  __/
#   \_____\__,_|\___|_| |_|\___|
#
#==============================================================================

#==============================================================================
# This file contains the management scripts of the caching features of dm.test.
# The cache directory located in the /tmp directory is created on startup.
# Every generated files will be located there. After the test suite finished,
# the cache directory will be removed. Therefore sub-cache systems don't need
# to worry about cleaning up after themselves.
#==============================================================================

#==============================================================================
# Function that initializes the cache system. It clears up the leftover cache
# directories and creates a fresh one.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
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
#   0 - Other status is not expected.
# Tools:
#   None
#==============================================================================
dm_test__cache__init() {
  dm_test__cache__cleanup
  _dm_test__cache__create_cache_directory

  _dm_test__cache__init__errors
  _dm_test__cache__init__test_result
  _dm_test__cache__init__global_result
  _dm_test__cache__init__global_count
  _dm_test__cache__init__temp_file_directory
}

#==============================================================================
#    ____           _            ____  _
#   / ___|__ _  ___| |__   ___  |  _ \(_)_ __
#  | |   / _` |/ __| '_ \ / _ \ | | | | | '__|
#  | |__| (_| | (__| | | |  __/ | |_| | | |
#   \____\__,_|\___|_| |_|\___| |____/|_|_|
#
#==============================================================================
# CACHE DIRECTORY
#==============================================================================

#==============================================================================
# Main cahce directory located in the /tmp directory is created with the
# `mktemp` command. This directory will contain all test suite related artifact
# that are created by the test runner or by the test cases.
#==============================================================================

# Prefix that every cache directory will have. This uniform prefix would make
# it easy to recover from an unexpected event when the cache cleanup couldn't
# be executed, by deleting all temporary directories with this prefix.
DM_TEST__CONFIG__CACHE__DIRECTORY_PREFIX="dm.test.temporary.cache"

# Cache directory prefix extended with the necessary `mktemp` compatible
# template. This variable will be used to create a unique cache directory each
# time.
# Using a subshell here to prevent the long line.
# shellcheck disable=2116
DM_TEST__CONFIG__CACHE__MKTEMP_TEMPLATE="$( \
  echo "${DM_TEST__CONFIG__CACHE__DIRECTORY_PREFIX}.XXXXXXXXXX" \
)"

# Global variable that holds the path to the currently operational cache
# directory. Each sub-cache system has to use this base path to generate their
# artifacts.
DM_TEST__RUNTIME__CACHE__PATH="__INVALID__"

#==============================================================================
# Inner function that will create the cache directory and sets the global
# variable for it.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CONFIG__CACHE__MKTEMP_TEMPLATE
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__RUNTIME__CACHE__PATH
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   mktemp
#==============================================================================
_dm_test__cache__create_cache_directory() {
  DM_TEST__RUNTIME__CACHE__PATH="$( \
    mktemp --directory -t "$DM_TEST__CONFIG__CACHE__MKTEMP_TEMPLATE" \
  )"
}

#==============================================================================
# Cleans up existing leftover cache direcotries. It will also delete leftover
# cache directories as well. Cache directories are created with `mktemp` so the
# cleanup has to be done in the `/tmp` directory.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CONFIG__CACHE__DIRECTORY_PREFIX
# Arguments:
#   None
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
#   0 - Other status is not expected.
# Tools:
#   find xargs rm
#==============================================================================
dm_test__cache__cleanup() {
  find /tmp \
    -type d \
    -name "${DM_TEST__CONFIG__CACHE__DIRECTORY_PREFIX}*" \
    -print0 2>/dev/null | xargs --null --replace='{}' rm --recursive --force '{}'
}

#==============================================================================
#    ____ _       _           _   _____
#   / ___| | ___ | |__   __ _| | | ____|_ __ _ __ ___  _ __
#  | |  _| |/ _ \| '_ \ / _` | | |  _| | '__| '__/ _ \| '__|
#  | |_| | | (_) | |_) | (_| | | | |___| |  | | | (_) | |
#   \____|_|\___/|_.__/ \__,_|_| |_____|_|  |_|  \___/|_|
#
#==============================================================================
# GLOBAL ERROR
#==============================================================================

#==============================================================================
# Individual test cases are executed in a subshell of a subshell. Errors
# happening in there should reach the top execution level. This file acts as a
# global buffer where assertion errors can be appended to. If an assertion
# fails it should write to this file via the provided API function.
#==============================================================================

# Variable that holds the name of the global error file. This variable is not
# intended for accessing the file.
DM_TEST__CONFIG__CACHE__ERRORS_NAME="dm_test__errors.tmp"

# Variable thar holds the runtime path of the global error file. This variable
# should be used for writing or reading purposes.
DM_TEST__RUNTIME__CACHE__ERRORS="__INVALID__"

#==============================================================================
# Inner function to create and initialize the error cache file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__RUNTIME__CACHE__PATH
#   DM_TEST__CONFIG__CACHE__ERRORS_NAME
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__RUNTIME__CACHE__ERRORS
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   touch echo
#==============================================================================
_dm_test__cache__init__errors() {
  # Using a subshell here to prevent the long line.
  # shellcheck disable=2116
  DM_TEST__RUNTIME__CACHE__ERRORS="$( \
    echo "${DM_TEST__RUNTIME__CACHE__PATH}/${DM_TEST__CONFIG__CACHE__ERRORS_NAME}" \
  )"
  touch "$DM_TEST__RUNTIME__CACHE__ERRORS"
}

#==============================================================================
# API function to check if errors are present in the global cache file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__RUNTIME__CACHE__ERRORS
# Arguments:
#   None
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
#    0 - There are errors present in the global test cache file.
#   !0 - No errors in the global test cache file.
# Tools:
#   None
#==============================================================================
dm_test__cache__errors__has_errors() {
  test -s "$DM_TEST__RUNTIME__CACHE__ERRORS"
}

#==============================================================================
# API function to print the errors from the global error cache file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__RUNTIME__CACHE__ERRORS
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Global error cache file content.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   cat
#==============================================================================
dm_test__cache__errors__print_errors() {
  cat "$DM_TEST__RUNTIME__CACHE__ERRORS"
}

#==============================================================================
# API function to append to the global error cache file. It redirects its
# standard input to the global error cache file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__RUNTIME__CACHE__ERRORS
# Arguments:
#   None
# STDIN:
#   Error string to be written into the global error cache file.
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   cat
#==============================================================================
dm_test__cache__errors__write_errors() {
  cat - >> "$DM_TEST__RUNTIME__CACHE__ERRORS"
}

#==============================================================================
#   _____         _     ____                 _ _
#  |_   _|__  ___| |_  |  _ \ ___  ___ _   _| | |_
#    | |/ _ \/ __| __| | |_) / _ \/ __| | | | | __|
#    | |  __/\__ \ |_  |  _ <  __/\__ \ |_| | | |_
#    |_|\___||___/\__| |_| \_\___||___/\__,_|_|\__|
#
#==============================================================================
# TEST RESULT CACHE
#==============================================================================

#==============================================================================
# Individual test cases are executed in a subshell of a subshell. Errors
# happening there should change the test case result from success to error, and
# the most trivial way to do that is this test result cache file. Before each
# test case run, this file wil be initialized to success. If an assertion
# fails, it should set this file content to failed via the provided API
# function. Further API function are available to examine the test result file
# content.
#==============================================================================

# Variable that holds the name of the test result file. This
# variable is not intended for accessing the file.
DM_TEST__CONFIG__CACHE__TEST_RESULT_NAME="dm_test__test_result.tmp"

# Variable thar holds the runtime path of the test result cache file. This
# variable should be used for writing or reading purposes.
DM_TEST__RUNTIME__CACHE__TEST_RESULT="__INVALID__"

#==============================================================================
# Inner function to create and initialize the test result file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__RUNTIME__CACHE__PATH
#   DM_TEST__CONFIG__CACHE__TEST_RESULT_NAME
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__RUNTIME__CACHE__TEST_RESULT
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   touch echo
#==============================================================================
_dm_test__cache__init__test_result() {
  # Using a subshell here to prevent the long line.
  # shellcheck disable=2116
  DM_TEST__RUNTIME__CACHE__TEST_RESULT="$( \
    echo "${DM_TEST__RUNTIME__CACHE__PATH}/${DM_TEST__CONFIG__CACHE__TEST_RESULT_NAME}" \
  )"
  touch "$DM_TEST__RUNTIME__CACHE__TEST_RESULT"
}

#==============================================================================
# Function that initializes the test result cache file with the success
# content. After this only failure content would be written to this file by the
# test case assertions.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__RUNTIME__CACHE__TEST_RESULT
#   DM_TEST__TEST_RESULT__SUCCESS
# Arguments:
#   None
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
#   0 - Other status is not expected.
# Tools:
#   echo
#==============================================================================
dm_test__cache__initialize_test_result() {
  echo "$DM_TEST__TEST_RESULT__SUCCESS" > "$DM_TEST__RUNTIME__CACHE__TEST_RESULT"
}

#==============================================================================
# Function that sets the currently executing test case result as a failure.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__RUNTIME__CACHE__TEST_RESULT
#   DM_TEST__TEST_RESULT__FAILURE
# Arguments:
#   None
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
#   0 - Other status is not expected.
# Tools:
#   echo
#==============================================================================
dm_test__cache__set_test_case_failed() {
  echo "$DM_TEST__TEST_RESULT__FAILURE" > "$DM_TEST__RUNTIME__CACHE__TEST_RESULT"
}

#==============================================================================
# Function that evaulates the test case result cache file content.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__RUNTIME__CACHE__TEST_RESULT
#   DM_TEST__TEST_RESULT__SUCCESS
# Arguments:
#   None
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
#   0 - Test case was succeeded.
#   1 - Test case was failed.
# Tools:
#   grep
#==============================================================================
dm_test__cache__is_test_case_succeeded() {
  grep --silent "$DM_TEST__TEST_RESULT__SUCCESS" "$DM_TEST__RUNTIME__CACHE__TEST_RESULT"
}

#==============================================================================
#    ____ _       _           _    ____                  _
#   / ___| | ___ | |__   __ _| |  / ___|___  _   _ _ __ | |_
#  | |  _| |/ _ \| '_ \ / _` | | | |   / _ \| | | | '_ \| __|
#  | |_| | | (_) | |_) | (_| | | | |__| (_) | |_| | | | | |_
#   \____|_|\___/|_.__/ \__,_|_|  \____\___/ \__,_|_| |_|\__|
#
#==============================================================================
# GLOBAL COUNT
#==============================================================================

#==============================================================================
# Global cache file that holds the count of all executed test cases.
#==============================================================================

# Variable that holds the name of the global test case count file. This
# variable is not intended for accessing the file.
DM_TEST__CONFIG__CACHE__GLOBAL_COUNT_NAME="dm_test__global_count.tmp"

# Variable thar holds the runtime path of the global test case count file. This
# variable should be used for writing or reading purposes.
DM_TEST__RUNTIME__CACHE__GLOBAL_COUNT="__INVALID__"

#==============================================================================
# Inner function to create and initialize the global count file. Writing an
# initial zero value to it. This number will be increased during each test case
# execution.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__RUNTIME__CACHE__PATH
#   DM_TEST__CONFIG__CACHE__GLOBAL_COUNT_NAME
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__RUNTIME__CACHE__GLOBAL_COUNT
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   echo
#==============================================================================
_dm_test__cache__init__global_count() {
  # Using a subshell here to prevent the long line.
  # shellcheck disable=2116
  DM_TEST__RUNTIME__CACHE__GLOBAL_COUNT="$( \
    echo "${DM_TEST__RUNTIME__CACHE__PATH}/${DM_TEST__CONFIG__CACHE__GLOBAL_COUNT_NAME}" \
  )"
  echo '0' > "$DM_TEST__RUNTIME__CACHE__GLOBAL_COUNT"
}

#==============================================================================
# Function to increase the global count cache file's content.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__RUNTIME__GLOBAL_COUNT
# Arguments:
#   None
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
#   0 - Other status is not expected.
# Tools:
#   None
#==============================================================================
dm_test__cache__increment_global_count() {
  _dm_test__increase_file_content "$DM_TEST__RUNTIME__CACHE__GLOBAL_COUNT"
}

#==============================================================================
# Function to get the global count cache file's content.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__RUNTIME__CACHE__GLOBAL_COUNT
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Content of the global count cache file.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   cat
#==============================================================================
dm_test__cache__get_global_count() {
  cat "$DM_TEST__RUNTIME__CACHE__GLOBAL_COUNT"
}

#==============================================================================
#    ____ _       _           _   _____     _ _
#   / ___| | ___ | |__   __ _| | |  ___|_ _(_) |_   _ _ __ ___  ___
#  | |  _| |/ _ \| '_ \ / _` | | | |_ / _` | | | | | | '__/ _ \/ __|
#  | |_| | | (_) | |_) | (_| | | |  _| (_| | | | |_| | | |  __/\__ \
#   \____|_|\___/|_.__/ \__,_|_| |_|  \__,_|_|_|\__,_|_|  \___||___/
#
#==============================================================================
# GLOBAL FAILURES
#==============================================================================

#==============================================================================
# Global cache file that holds the count of all failed test cases.
#==============================================================================

# Variable that holds the name of the global test case failure count file. This
# variable is not intended for accessing the file.
DM_TEST__CONFIG__CACHE__GLOBAL_FAILURES_NAME="dm_test__global_result.tmp"

# Variable thar holds the runtime path of the global test case failure count
# file. This variable should be used for writing or reading purposes.
DM_TEST__RUNTIME__CACHE__GLOBAL_FAILURES="__INVALID__"

#==============================================================================
# Inner function to create and initialize the global result file. Writing an
# initial success value to the file, as it is a zero. Any nonzero number will
# represent failure.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__RUNTIME__CACHE__PATH
#   DM_TEST__CONFIG__CACHE__GLOBAL_FAILURES_NAME
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__RUNTIME__CACHE__GLOBAL_FAILURES
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   echo
#==============================================================================
_dm_test__cache__init__global_result() {
  # Using a subshell here to prevent the long line.
  # shellcheck disable=2116
  DM_TEST__RUNTIME__CACHE__GLOBAL_FAILURES="$( \
    echo "${DM_TEST__RUNTIME__CACHE__PATH}/${DM_TEST__CONFIG__CACHE__GLOBAL_FAILURES_NAME}" \
  )"
  echo '0' > "$DM_TEST__RUNTIME__CACHE__GLOBAL_FAILURES"
}

#==============================================================================
# Function to increase the global failure cache file's content.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__RUNTIME__CACHE__GLOBAL_FAILURES
# Arguments:
#   None
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
#   0 - Other status is not expected.
# Tools:
#   None
#==============================================================================
dm_test__cache__increment_global_failure() {
  _dm_test__increase_file_content "$DM_TEST__RUNTIME__CACHE__GLOBAL_FAILURES"
}

#==============================================================================
# Function to get the global failures cache file's content.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__RUNTIME__CACHE__GLOBAL_FAILURES
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Content of the global count cache file.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   cat
#==============================================================================
dm_test__cache__get_global_failure_count() {
  cat "$DM_TEST__RUNTIME__CACHE__GLOBAL_FAILURES"
}

#==============================================================================
# Function to get the global failures cache file's content.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__RUNTIME__CACHE__GLOBAL_FAILURES
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Content of the global count cache file.
# STDERR:
#   None
# Status:
#   0 - Global failures count is nonzero.
#   1 - Global failures count is zero.
# Tools:
#   grep
#==============================================================================
dm_test__cache__was_global_failure() {
  grep --silent --invert-match '^0$' "$DM_TEST__RUNTIME__CACHE__GLOBAL_FAILURES"
}

#==============================================================================
#  _____                                                 _____ _ _
# |_   _|__ _ __ ___  _ __   ___  _ __ __ _ _ __ _   _  |  ___(_) | ___  ___
#   | |/ _ \ '_ ` _ \| '_ \ / _ \| '__/ _` | '__| | | | | |_  | | |/ _ \/ __|
#   | |  __/ | | | | | |_) | (_) | | | (_| | |  | |_| | |  _| | | |  __/\__ \
#   |_|\___|_| |_| |_| .__/ \___/|_|  \__,_|_|   \__, | |_|   |_|_|\___||___/
#                    |_|                         |___/
#==============================================================================
# TEMPORARY FILES
#==============================================================================

#==============================================================================
# The cache system provides a way to create temporary files that can be used
# during the test execution. These temporary files are created inside a
# seprated directory. The files are generated with a precise timestamp prefix,
# so collision between the names are very unlikely.
#==============================================================================

# Variable that holds the name of the temporary files directory. This variable
# is not intended for accessing the directory.
DM_TEST__CONFIG__CACHE__TEMP_FILE_PATH_NAME="dm_test__temp_files"

# Variable thar holds the runtime path of the temporary files directory. This
# variable should be used for writing or reading purposes.
DM_TEST__RUNTIME__CACHE__TEMP_FILE_PATH="__INVALID__"

#==============================================================================
# Inner function to initialize the directory for the temporary files.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__RUNTIME__CACHE__PATH
#   DM_TEST__CONFIG__CACHE__TEMP_FILE_PATH_NAME
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__RUNTIME__CACHE__TEMP_FILE_PATH
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   mkdir echo
#==============================================================================
_dm_test__cache__init__temp_file_directory() {
  # Using a subshell here to prevent the long line.
  # shellcheck disable=2116
  DM_TEST__RUNTIME__CACHE__TEMP_FILE_PATH="$( \
    echo "${DM_TEST__RUNTIME__CACHE__PATH}/${DM_TEST__CONFIG__CACHE__TEMP_FILE_PATH_NAME}" \
  )"
  mkdir -p "$DM_TEST__RUNTIME__CACHE__TEMP_FILE_PATH"
}

#==============================================================================
# Creates a temporary file in the cache directory and returns its path.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__RUNTIME__CACHE__TEMP_FILE_PATH
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
# - None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   date echo
#==============================================================================
dm_test__cache__create_temp_file() {
  echo "${DM_TEST__RUNTIME__CACHE__TEMP_FILE_PATH}/dm.tmp.$(date +'%s%N')"
}

#==============================================================================
#  _____         _     ____  _               _
# |_   _|__  ___| |_  |  _ \(_)_ __ ___  ___| |_ ___  _ __ _   _
#   | |/ _ \/ __| __| | | | | | '__/ _ \/ __| __/ _ \| '__| | | |
#   | |  __/\__ \ |_  | |_| | | | |  __/ (__| || (_) | |  | |_| |
#   |_|\___||___/\__| |____/|_|_|  \___|\___|\__\___/|_|   \__, |
#                                                          |___/
#==============================================================================
# TEST DIRECTORY
#==============================================================================

#==============================================================================
# For each test file a new temporary directory will be created. This directory
# can be used to generate test artifacts that are used in the file level or in
# the test case level, it depends on the user. After all test cases were
# executed in a given test file, this temporary directory will be deleted. That
# means each test file will have a clean environemnt to put test artifacts in,
# but it also means there is no way a test file to communication another test
# file.
#==============================================================================

# Variable that holds the name of the temp test directory. This variable
# is not intended for accessing the directory.
DM_TEST__CONFIG__CACHE__TEMP_TEST_DIR_NAME="dm_test__test_temp"

# Variable thar holds the runtime path of the temp test directory. This
# variable should be used for writing or reading purposes. Its name is
# different to the usual cache variable, because it is intended to use inside
# the test cases.
DM_TEST__TMP_TEST_DIR="__INVALID__"

#==============================================================================
# Creates a temporary directory for the currently executing test file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__RUNTIME__CACHE__PATH
#   DM_TEST__CONFIG__CACHE__TEMP_TEST_DIR_NAME
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__TMP_TEST_DIR
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   mkdir echo
#==============================================================================
dm_test__cache__create_tmp_directory() {
  # Using a subshell here to prevent the long line.
  # shellcheck disable=2116
  DM_TEST__TMP_TEST_DIR="$( \
    echo "${DM_TEST__RUNTIME__CACHE__PATH}/${DM_TEST__CONFIG__CACHE__TEMP_TEST_DIR_NAME}" \
  )"
  mkdir -p "$DM_TEST__TMP_TEST_DIR"
}

#==============================================================================
# Deletes the previously created temporary directory.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__TMP_TEST_DIR
# Arguments:
#   None
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
#   0 - Other status is not expected.
# Tools:
#   rm
#==============================================================================
dm_test__cache__cleanup_tmp_directory() {
  rm --recursive --force "$DM_TEST__TMP_TEST_DIR"
}
