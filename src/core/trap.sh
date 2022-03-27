#!/bin/sh
#==============================================================================
#   _______
#  |__   __|
#     | |_ __ __ _ _ __
#     | | '__/ _` | '_ \
#     | | | | (_| | |_) |
#     |_|_|  \__,_| .__/
#                 | |
#=================|_|==========================================================
# TRAP
#==============================================================================

#==============================================================================
# This file contains the signal handler functions that are making sure the
# artifacts are cleaned up if the test suite exits or an unexpected event
# happens.
#==============================================================================

#==============================================================================
#     _    ____ ___    __                  _   _
#    / \  |  _ \_ _|  / _|_   _ _ __   ___| |_(_) ___  _ __  ___
#   / _ \ | |_) | |  | |_| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
#  / ___ \|  __/| |  |  _| |_| | | | | (__| |_| | (_) | | | \__ \
# /_/   \_\_|  |___| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
#==============================================================================
# API FUNCTIONS
#==============================================================================

#==============================================================================
# Initializes the trap system to trigger on system exit and on unexpected
# interrupt signals.
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
#==============================================================================
posix_test__arm_trap_system() {
  posix_test__debug 'posix_test__arm_trap_system' \
    'arming trap system..'

  trap '_posix_test__exit_trap__wrapper' EXIT INT HUP TERM

  posix_test__debug 'posix_test__arm_trap_system' \
    'trap system armed'
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
# Trap function that executes before the exit call finishes. It caches the exit
# signal, and replays it at the end. Its main purpose is to delete the cache
# directory.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] original_exit_code - Exit code that was set before the trap execution.
#       This exit code has to be replayed at the end of the trap handler.
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
#   Original exit code replayed from the called level.
#==============================================================================
_posix_test__exit_trap() {
  ___original_exit_code="$1"

  posix_test__debug '_posix_test__exit_trap' \
    "handling exit trap, original status code '${___original_exit_code}' saved"

  posix_test__cache__cleanup
  trap - EXIT

  posix_test__debug '_posix_test__exit_trap' \
    "exit trap finished, exiting with status code '${___original_exit_code}'"

  exit "$___original_exit_code"
}

#==============================================================================
# Exit trap handler wrapper that is used to attach the debugger file descriptor
# to it. In this way the debug messages can be routed correctly during handling
# the received signals. It captures the original exit code and passes it to the
# trap handler.
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
#   None
#==============================================================================
_posix_test__exit_trap__wrapper() {
  ___original_exit_code="$?"
  posix_test__debug__wrapper '_posix_test__exit_trap' "$___original_exit_code"
}
