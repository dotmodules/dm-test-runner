#!/bin/sh
#==============================================================================
# __      __        _       _     _
# \ \    / /       (_)     | |   | |
#  \ \  / /_ _ _ __ _  __ _| |__ | | ___  ___
#   \ \/ / _` | '__| |/ _` | '_ \| |/ _ \/ __|
#    \  / (_| | |  | | (_| | |_) | |  __/\__ \
#     \/ \__,_|_|  |_|\__,_|_.__/|_|\___||___/
#
#==============================================================================
# VARIABLES
#==============================================================================

#==============================================================================
# As this file contains variables with default values without actually using
# them, we are disabling shellcheck variable unused warnings (SC2034) for the
# whole file.
# shellcheck disable=SC2034
#==============================================================================

#==============================================================================
# PRETTY COLORING
#==============================================================================

# Checking the availability and usability of tput. If it is available and
# usable we can set the global coloring variables with it.
if posix_adapter__tput --is-available
then
  RED="$(posix_adapter__tput setaf 1)"
  GREEN="$(posix_adapter__tput setaf 2)"
  BLUE="$(posix_adapter__tput setaf 4)"
  RESET="$(posix_adapter__tput sgr0)"
  BOLD="$(posix_adapter__tput bold)"
  DIM="$(posix_adapter__tput dim)"
else
  RED=''
  GREEN=''
  BLUE=''
  RESET=''
  BOLD=''
  DIM=''
fi

#==============================================================================
# GLOBAL CONSTANTS
#==============================================================================

POSIX_TEST__CONSTANT__TEST_RESULT__SUCCESS='0'
POSIX_TEST__CONSTANT__TEST_RESULT__FAILURE='1'
