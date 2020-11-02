#==============================================================================
#    _____           _
#   / ____|         | |
#  | |     __ _  ___| |__   ___
#  | |    / _` |/ __| '_ \ / _ \
#  | |___| (_| | (__| | | |  __/
#   \_____\__,_|\___|_| |_|\___|
#
#==============================================================================

# Prefix that every cache temp directory will have. This uniform prefix would
# make it easy to recover from an unexpected event, by deleting all temporary
# directories with this prefix.
DM_TEST__CACHE__PREFIX="dm.test.temporary.cache"

# Temporary cache files are created with `mktemp` and it expects a predefined
# freedom to create the temporary directory wo be able to solve name
# collisions.
DM_TEST__CACHE__MKTEMP_TEMPLATE="${DM_TEST__CACHE__PREFIX}.XXXXXXXXXX"

# Global variable that holds the path to the currently operational temporary
# cache directory.
DM_TEST__CACHE__PATH="__INVALID__"

# Global variable that holds a directory name inside the cache directory that
# is dedicated to contain temporary files.
DM_TEST__CACHE__TEMP_FILE_PATH_NAME="dm_test__temp_files"
DM_TEST__CACHE__TEMP_FILE_PATH="__INVALID__"

#==============================================================================
# TEST SUBSHELL COMMUNICATION CACHING FILES
#==============================================================================

# Test files are executed in a subshell and error reporting is happening there.
# This temporary file will be the link between the subshell and the top level
# shell. Absolute path is necessary as the subshell starts with a directory
# change.
DM_TEST__CACHE__ERRORS_NAME="dm_test__errors.tmp"
DM_TEST__CACHE__ERRORS="__INVALID__"

# In order to capture the currently executed test case output it has to be run
# in a subshell (subshell in a subshell as the test case is already running in
# its own subshell), and there is no easier way reaching the test result change
# than with this temporary file that will be reset before every test case
# execution. Before executing the test it's value is set to sucess, and in the
# assert function it is set to failure in case of assertion error.
DM_TEST__CACHE__TEST_RESULT_NAME="dm_test__test_result.tmp"
DM_TEST__CACHE__TEST_RESULT="__INVALID__"

# Global suite result that is initialized once with a passed value, then a
# failed tests overwrites it.
DM_TEST__CACHE__GLOBAL_RESULT_NAME="dm_test__global_result.tmp"
DM_TEST__CACHE__GLOBAL_RESULT="__INVALID__"

# Global test case counter file.
DM_TEST__CACHE__GLOBAL_COUNT_NAME="dm_test__global_count.tmp"
DM_TEST__CACHE__GLOBAL_COUNT="__INVALID__"


#==============================================================================
# API FUNCTIONS
#==============================================================================

#==============================================================================
# Function that initializes the cache system. It clears up the leftover cache
# directories and creates a fresh one.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__CACHE__PATH
# - DM_TEST__CACHE__ERRORS_NAME
# - DM_TEST__CACHE__TEST_RESULT_NAME
# - DM_TEST__CACHE__GLOBAL_RESULT_NAME
# Arguments
# - None
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - DM_TEST__CACHE__ERRORS
# - DM_TEST__CACHE__TEST_RESULT
# - DM_TEST__CACHE__GLOBAL_RESULT
# - DM_TEST__CACHE__TEMP_FILE_PATH
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
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
# Cleans up existing leftover cache direcotries.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__CACHE__PREFIX
# Arguments
# - None
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_test__cache__cleanup() {
  find /tmp -type d -name "${DM_TEST__CACHE__PREFIX}*" -print0 2>/dev/null \
    | xargs --null --replace='{}' rm -rf '{}'
}

#==============================================================================
# Creates a temporary file in the cache directory and returns its path.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__CACHE__PATH
# Arguments
# - None
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
dm_test__cache__create_temp_file() {
  ___path="${DM_TEST__CACHE__TEMP_FILE_PATH}/dm.tmp.$(date +'%s%N')"
  echo "$___path"
}


#==============================================================================
# HELPER FUNCTIONS
#==============================================================================

#==============================================================================
# Inner function that will create the cache directory and sets the global
# variable for it.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__CACHE__MKTEMP_TEMPLATE
# Arguments
# - None
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - DM_TEST__CACHE__PATH
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__cache__create_cache_directory() {
  # We are not exporting variables from the dm test runtime. The global
  # variables are being used by sourcing the individual files, so ignoring the
  # warning here.
  # shellcheck disable=SC2034
  DM_TEST__CACHE__PATH="$(
    mktemp --directory -t "$DM_TEST__CACHE__MKTEMP_TEMPLATE"
  )"
}

#==============================================================================
# Inner function to create and initialize the error cache file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__CACHE__PATH
# - DM_TEST__CACHE__ERRORS_NAME
# Arguments
# - None
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - DM_TEST__CACHE__ERRORS
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__cache__init__errors() {
  DM_TEST__CACHE__ERRORS="${DM_TEST__CACHE__PATH}/${DM_TEST__CACHE__ERRORS_NAME}"
  touch "$DM_TEST__CACHE__ERRORS"
}

#==============================================================================
# Inner function to create and initialize the test result file.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__CACHE__PATH
# - DM_TEST__CACHE__TEST_RESULT_NAME
# Arguments
# - None
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - DM_TEST__CACHE__TEST_RESULT
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__cache__init__test_result() {
  DM_TEST__CACHE__TEST_RESULT="${DM_TEST__CACHE__PATH}/${DM_TEST__CACHE__TEST_RESULT_NAME}"
  touch "$DM_TEST__CACHE__TEST_RESULT"
}

#==============================================================================
# Inner function to create and initialize the global result file. Writing an
# initial success value to the file, as it is a zero. Any nonzero number will
# represent failure.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__CACHE__PATH
# - DM_TEST__CACHE__GLOBAL_RESULT_NAME
# - DM_TEST__TEST_RESULT__SUCCESS
# Arguments
# - None
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - DM_TEST__CACHE__GLOBAL_RESULT
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__cache__init__global_result() {
  DM_TEST__CACHE__GLOBAL_RESULT="${DM_TEST__CACHE__PATH}/${DM_TEST__CACHE__GLOBAL_RESULT_NAME}"
  echo "$DM_TEST__TEST_RESULT__SUCCESS" > "$DM_TEST__CACHE__GLOBAL_RESULT"
}

#==============================================================================
# Inner function to create and initialize the global count file. Writing an
# initial zero value to it. This number will be increased during each test case
# execution.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__CACHE__PATH
# - DM_TEST__CACHE__GLOBAL_COUNT_NAME
# Arguments
# - None
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - DM_TEST__CACHE__GLOBAL_COUNT
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__cache__init__global_count() {
  DM_TEST__CACHE__GLOBAL_COUNT="${DM_TEST__CACHE__PATH}/${DM_TEST__CACHE__GLOBAL_COUNT_NAME}"
  echo '0' > "$DM_TEST__CACHE__GLOBAL_COUNT"
}

#==============================================================================
# Inner function to initialize the directory for the temporary files.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__CACHE__PATH
# - DM_TEST__CACHE__TEMP_FILE_PATH_NAME
# Arguments
# - None
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - DM_TEST__CACHE__TEMP_FILE_PATH
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__cache__init__temp_file_directory() {
  DM_TEST__CACHE__TEMP_FILE_PATH="${DM_TEST__CACHE__PATH}/${DM_TEST__CACHE__TEMP_FILE_PATH_NAME}"
  mkdir -p "$DM_TEST__CACHE__TEMP_FILE_PATH"
}

#==============================================================================
# Creates a temporary directory for the currently executing test file. For each
# test file a new temporary directory will be created. This test file can be
# used to generate test artifacts that are used in the file level or in the
# test case level, it depends on the user.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__CACHE__PATH
# Arguments
# - None
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - DM_TEST__TMP_TEST_DIR
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__cache__create_tmp_directory() {
  DM_TEST__TMP_TEST_DIR="${DM_TEST__CACHE__PATH}/test_file_tmp_directory"
  mkdir --parents "$DM_TEST__TMP_TEST_DIR"
}

#==============================================================================
# Deletes the previously created temporary directory.
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - DM_TEST__TMP_TEST_DIR
# Arguments
# - None
# StdIn
# - None
#==============================================================================
# OUTPUT
#==============================================================================
# Output variables
# - None
# StdOut
# - None
# StdErr
# - None
# Status
# -  0 : ok
# - !0 : error
#==============================================================================
_dm_test__cache__cleanup_tmp_directory() {
  rm -rf "$DM_TEST__TMP_TEST_DIR"
}
