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
#==============================================================================
# INPUT
#==============================================================================
# Global variables
# - None
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
_dm_test__exit_trap() {
  ___exit_code_backup="$?"
  dm_test__cache__cleanup
  trap - EXIT
  exit "$___exit_code_backup"
}

trap '_dm_test__exit_trap' EXIT INT HUP TERM
