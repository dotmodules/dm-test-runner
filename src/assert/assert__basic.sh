#==============================================================================
#   ____            _                                   _   _
#  |  _ \          (_)          /\                     | | (_)
#  | |_) | __ _ ___ _  ___     /  \   ___ ___  ___ _ __| |_ _  ___  _ __  ___
#  |  _ < / _` / __| |/ __|   / /\ \ / __/ __|/ _ \ '__| __| |/ _ \| '_ \/ __|
#  | |_) | (_| \__ \ | (__   / ____ \\__ \__ \  __/ |  | |_| | (_) | | | \__ \
#  |____/ \__,_|___/_|\___| /_/    \_\___/___/\___|_|   \__|_|\___/|_| |_|___/
#
#==============================================================================
# BASIC ASSERTIONS
#==============================================================================

#==============================================================================
# Basic assertions can be executed at any time without any context as they are
# working working on the given parameters only. They can be used to compare
# values and to check file system related facts.
#==============================================================================

#==============================================================================
# Simple assertion helper function that expects a list of parameters that will
# be interpreted as a test command in an if statement. It is common to use the
# 'test' command to write simple assertions, but in general anything can be
# used.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [..] command - Commands and parameters that needs to be executed.
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
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
assert() {
  ___command="$*"

  dm_test__debug 'assert' "running assertion: '${___command}'"

  if $___command
  then
    dm_test__debug 'assert' '=> assertion succeeded'
  else
    dm_test__debug 'assert' '=> assertion failed'

    ___subject='Assertion failed'
    ___reason="Tested command that failed: '${___command}'."
    ___assertion='assert'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Simple assertion helper function that expects a list of parameters that will
# be interpreted as a test command in an if statement. It is common to use the
# 'test' command to write simple assertions, but in general anything can be
# used.
#
# Internally this is exactly the same as the simple 'assert' function only the
# name is different. It exist only to complement the 'assert_failure' function.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [..] command - Commands and parameters that needs to be executed.
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
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
assert_success() {
  ___command="$*"

  dm_test__debug 'assert_success' "running assertion: '${___command}'"

  if $___command
  then
    dm_test__debug 'assert_success' '=> assertion succeeded'
  else
    dm_test__debug 'assert_success' '=> assertion failed'

    ___subject='Assertion failed'
    ___reason="Tested command that failed: '${___command}'."
    ___assertion='assert_success'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}

#==============================================================================
# Simple assertion that succeeds on failure. It expectes a command or function
# name, that will be inserted into an if statement.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [..] command - Commands and parameters that needs to be executed.
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
#   0 - Assertion succeeded.
#   1 - Assertion failed.
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
assert_failure() {
  ___command="$*"

  dm_test__debug 'assert_failure' "running assertion: '${___command}'"

  if ! $___command
  then
    dm_test__debug 'assert_failure' '=> assertion succeeded'
  else
    dm_test__debug 'assert_failure' '=> assertion failed'

    ___subject='Inverse assertion failed, command succeeded'
    ___reason="Command succeeded but should have failed: '${___command}'."
    ___assertion='assert_failure'
    _dm_test__report_failure "$___subject" "$___reason" "$___assertion"
  fi
}
