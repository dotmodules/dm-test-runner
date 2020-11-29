#==============================================================================
#   _    _             _
#  | |  | |           | |
#  | |__| | ___   ___ | | _____
#  |  __  |/ _ \ / _ \| |/ / __|
#  | |  | | (_) | (_) |   <\__ \
#  |_|  |_|\___/ \___/|_|\_\___/
#
#==============================================================================

#==============================================================================
# Checks if in the given test file execution hook [setup, teardown, setup_file,
# teardown_file] are present. It checks for only one given hook, and returns
# the match count.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] pattern - Grep compatible pattern that should match the presence of the
#       testable hook.
#   [2] test_file_path - Path of the given test file the hook should be
#   searched in.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Match count for the given pattern.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   grep true
#==============================================================================
dm_test__get_hook_flag() {
  ___pattern="$1"
  ___test_file_path="$2"

  dm_test__debug \
    'dm_test__get_hook_flag' \
    "checking hook '${___pattern}' in test file '${___test_file_path}'"

  grep --count "$___pattern" "$___test_file_path" || true
}

#==============================================================================
# Runs the given hook that is actually an already sourced function from the
# currently executing test file. The hook name should match one of the
# following [setup, teardown, setup_file, teardown_file]. A flag also passed
# that should determine if the given hook needs to be executed or not.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] flag - Integer number that should represent the given hook occurance
#       count in the currently executing test file.
#   [2] hook - Hook function name that is called when the flag allows it. It
#       should be one of the following names: [setup, teardown, setup_file,
#       teardown_file]
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Optionally it can output the output of the given hook if needed.
# STDERR:
#   Error that occured during operation.
# Status:
#   0 - Other status is not expected.
# Tools:
#   None
#==============================================================================
dm_test__run_hook() {
  ___flag="$1"
  ___hook="$2"

  if [ "$___flag" -ne '0' ]
  then

    dm_test__debug \
      'dm_test__run_hook' \
      "executing hook '${___hook}'"

    if $___hook
    then
      return 0
    else
      ___hook_status="$?"
      >&2 echo "Error during '${___hook}' hook execution! Status: ${___hook_status}"
      return "$___hook_status"
    fi

  fi
}
