#==============================================================================
#   _______
#  |__   __|
#     | |_ __ __ _ _ __
#     | | '__/ _` | '_ \
#     | | | | (_| | |_) |
#     |_|_|  \__,_| .__/
#                 | |
#=================|_|==========================================================

#==============================================================================
# Trap function that executes before the exit call finishes. It caches the exit
# signal, and replays it at the end. Its main purpose is to delete the cache
# directory.
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
#   Status code saved and replayed from the called level.
# Tools:
#   trap exit
#==============================================================================
_dm_test__exit_trap() {
  ___exit_code_backup="$?"
  dm_test__cache__cleanup
  trap - EXIT
  exit "$___exit_code_backup"
}

trap '_dm_test__exit_trap' EXIT INT HUP TERM
