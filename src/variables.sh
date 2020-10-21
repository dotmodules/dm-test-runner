#==============================================================================
# __      __        _       _     _
# \ \    / /       (_)     | |   | |
#  \ \  / /_ _ _ __ _  __ _| |__ | | ___  ___
#   \ \/ / _` | '__| |/ _` | '_ \| |/ _ \/ __|
#    \  / (_| | |  | | (_| | |_) | |  __/\__ \
#     \/ \__,_|_|  |_|\__,_|_.__/|_|\___||___/
#
#==============================================================================

# As this file contains variables with default values without actually using
# them, we are disabling shellcheck variable unused warnings (SC2034) for the
# whole file.
# shellcheck disable=SC2034

#==============================================================================
# PRETTY COLORING
#==============================================================================

# Ignoring the not used shellcheck errors as these variables are good to have
# during additional development.
# This is a special case where double quoting is actually not preferable. More
# details: https://stackoverflow.com/a/13864829/1565331
# shellcheck disable=SC2086
if command -v tput > /dev/null && [ ! -s ${TERM+x} ]
then
  # shellcheck disable=SC2034
  RED="$(tput setaf 1)"
  # shellcheck disable=SC2034
  GREEN="$(tput setaf 2)"
  # shellcheck disable=SC2034
  RESET="$(tput sgr0)"
  # shellcheck disable=SC2034
  BOLD="$(tput bold)"
else
  # shellcheck disable=SC2034
  RED=""
  # shellcheck disable=SC2034
  GREEN=""
  # shellcheck disable=SC2034
  RESET=""
  # shellcheck disable=SC2034
  BOLD=""
fi

#==============================================================================
# GLOBAL CONTEXT VARIABLES
#==============================================================================

# Global execution related variables that is used to communicate the currently
# executed test file and test names to the test case running in a subshell.
# They are used in the error reporting section.

DM_TEST__FILE_UNDER_EXECUTION=""
DM_TEST__TEST_UNDER_EXECUTION=""

#==============================================================================
# TEST SUBSHELL COMMUNICATION CACHING FILES
#==============================================================================

# Test files are executed in a subshell and error reporting is happening there.
# This temporary file will be the link between the subshell and the top level
# shell. Absolute path is necessary as the subshell starts with a directory
# change.

DM_TEST__ERROR_CACHE="dm.test.errors.tmp"
DM_TEST__ERROR_CACHE="$(pwd)/$DM_TEST__ERROR_CACHE"

# In order to capture the currently executed test case output it has to be run
# in a subshell (subshell in a subshell as the test case is already running in
# its own subshell), and there is no easier way reaching the test result change
# than with this temporary file that will be reset before every test case
# execution. Before executing the test it's value is set to sucess, and in the
# assert function it is set to failure in case of assertion error.

DM_TEST__TEST_RESULT_CACHE="dm.test.result.tmp"
DM_TEST__TEST_RESULT_CACHE="$(pwd)/$DM_TEST__TEST_RESULT_CACHE"
DM_TEST__TEST_RESULT_SUCCESS="1"
DM_TEST__TEST_RESULT_FAILURE="0"

#==============================================================================
# TEST STATISTICS
#==============================================================================

DM_TEST__STATISTICS__COUNT="0"
DM_TEST__STATISTICS__FAILED="0"
