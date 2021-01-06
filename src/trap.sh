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
#------------------------------------------------------------------------------
# Tools:
#   trap
#==============================================================================
_dm_test__exit_trap() {
  ___original_exit_code="$1"

  dm_test__debug '_dm_test__exit_trap' \
    "handling exit trap, original status code '${___original_exit_code}' saved"

  dm_test__cache__cleanup
  trap - EXIT

  dm_test__debug '_dm_test__exit_trap' \
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
#------------------------------------------------------------------------------
# Tools:
#   None
#==============================================================================
_dm_test__exit_trap__wrapper() {
  ___original_exit_code="$?"
  dm_test__debug__wrapper '_dm_test__exit_trap' "$___original_exit_code"
}

trap '_dm_test__exit_trap__wrapper' EXIT INT HUP TERM
