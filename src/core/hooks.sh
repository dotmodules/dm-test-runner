#!/bin/sh
#==============================================================================
#   _    _             _
#  | |  | |           | |
#  | |__| | ___   ___ | | _____
#  |  __  |/ _ \ / _ \| |/ / __|
#  | |  | | (_) | (_) |   <\__ \
#  |_|  |_|\___/ \___/|_|\_\___/
#
#==============================================================================
# HOOKS
#==============================================================================

#==============================================================================
# Hooks are used to execute the setup or teardown test fixtures before and
# after a test case or a test file. If a hook function gets matched against the
# predefined hook function signature, the hook function will be executed in the
# correct point of execution during the test file execution. Having multiple
# hook functions defined from the same type won't raise an error, but will
# trigger a warning, and only the last hook function will be executed.
#
# The hook system needs to be initialized for each test file in order to parse
# the hook flags for the given file. After this triggering a hook can be
# executed and the hook will be triggered if it is defined in the current test
# file.
#==============================================================================

# Valid function names for the hook functions.
DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__SETUP='setup'
DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__TEARDOWN='teardown'
DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__SETUP_FILE='setup_file'
DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__TEARDOWN_FILE='teardown_file'

# Patterns that will be used to register a hook.
DM_TEST__HOOKS__CONFIG__PATTERN__SETUP=\
"^${DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__SETUP}()"

DM_TEST__HOOKS__CONFIG__PATTERN__TEARDOWN=\
"^${DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__TEARDOWN}()"

DM_TEST__HOOKS__CONFIG__PATTERN__SETUP_FILE=\
"^${DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__SETUP_FILE}()"

DM_TEST__HOOKS__CONFIG__PATTERN__TEARDOWN_FILE=\
"^${DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__TEARDOWN_FILE}()"

# Hook flags assigned during runtime that determine if a test file has a
# particular hook defined. They contain a single integer value that should
# indicate the matched hook function in the given test file.
DM_TEST__HOOKS__RUNTIME__FLAG__SETUP='__INVALID__'
DM_TEST__HOOKS__RUNTIME__FLAG__TEARDOWN='__INVALID__'
DM_TEST__HOOKS__RUNTIME__FLAG__SETUP_FILE='__INVALID__'
DM_TEST__HOOKS__RUNTIME__FLAG__TEARDOWN_FILE='__INVALID__'

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
# Initializes the hook flags for the given test file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__HOOKS__CONFIG__PATTERN__SETUP
#   DM_TEST__HOOKS__CONFIG__PATTERN__TEARDOWN
#   DM_TEST__HOOKS__CONFIG__PATTERN__SETUP_FILE
#   DM_TEST__HOOKS__CONFIG__PATTERN__TEARDOWN_FILE
#   DM_TEST__HOOKS__RUNTIME__FLAG__SETUP
#   DM_TEST__HOOKS__RUNTIME__FLAG__TEARDOWN
#   DM_TEST__HOOKS__RUNTIME__FLAG__SETUP_FILE
#   DM_TEST__HOOKS__RUNTIME__FLAG__TEARDOWN_FILE
# Arguments:
#   [1] test_file_path - Path of the given test file the hook should be
#       searched in.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__HOOKS__RUNTIME__FLAG__SETUP
#   DM_TEST__HOOKS__RUNTIME__FLAG__TEARDOWN
#   DM_TEST__HOOKS__RUNTIME__FLAG__SETUP_FILE
#   DM_TEST__HOOKS__RUNTIME__FLAG__TEARDOWN_FILE
# STDOUT:
#   Match count for the given pattern.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm_test__hooks__init_hooks_for_test_file() {
  ___test_file_path="$1"

  dm_test__debug 'dm_test__hooks__init_hooks_for_test_file' \
    "initializing hook flags for test file '${___test_file_path}'"

  DM_TEST__HOOKS__RUNTIME__FLAG__SETUP="$( \
    _dm_test__hooks__get_hook_flag \
      "$DM_TEST__HOOKS__CONFIG__PATTERN__SETUP" \
      "$___test_file_path"
  )"

  DM_TEST__HOOKS__RUNTIME__FLAG__TEARDOWN="$( \
    _dm_test__hooks__get_hook_flag \
      "$DM_TEST__HOOKS__CONFIG__PATTERN__TEARDOWN" \
      "$___test_file_path"
  )"

  DM_TEST__HOOKS__RUNTIME__FLAG__SETUP_FILE="$( \
    _dm_test__hooks__get_hook_flag \
      "$DM_TEST__HOOKS__CONFIG__PATTERN__SETUP_FILE" \
      "$___test_file_path"
  )"

  DM_TEST__HOOKS__RUNTIME__FLAG__TEARDOWN_FILE="$( \
    _dm_test__hooks__get_hook_flag \
      "$DM_TEST__HOOKS__CONFIG__PATTERN__TEARDOWN_FILE" \
      "$___test_file_path"
  )"

  dm_test__debug 'dm_test__hooks__init_hooks_for_test_file' \
    'hook flags initialized:'

  dm_test__debug 'dm_test__hooks__init_hooks_for_test_file' \
    "  setup: ${DM_TEST__HOOKS__RUNTIME__FLAG__SETUP}"
  dm_test__debug 'dm_test__hooks__init_hooks_for_test_file' \
    "  teardown: ${DM_TEST__HOOKS__RUNTIME__FLAG__TEARDOWN}"
  dm_test__debug 'dm_test__hooks__init_hooks_for_test_file' \
    "  setup_file: ${DM_TEST__HOOKS__RUNTIME__FLAG__SETUP_FILE}"
  dm_test__debug 'dm_test__hooks__init_hooks_for_test_file' \
    "  teardown_file: ${DM_TEST__HOOKS__RUNTIME__FLAG__TEARDOWN_FILE}"
}

#==============================================================================
# Triggers the [setup] hook.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__SETUP
#   DM_TEST__HOOKS__RUNTIME__FLAG__SETUP
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Outputs the given hook's output.
# STDERR:
#   Outputs the given hook's error output.
# Status:
#   Returns the given hook's status.
#==============================================================================
dm_test__hooks__trigger_hook__setup() {
  _dm_test__hooks__trigger_hook \
    "$DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__SETUP" \
    "$DM_TEST__HOOKS__RUNTIME__FLAG__SETUP"
}

#==============================================================================
# Triggers the [teardown] hook.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__TEARDOWN
#   DM_TEST__HOOKS__RUNTIME__FLAG__TEARDOWN
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Outputs the given hook's output.
# STDERR:
#   Outputs the given hook's error output.
# Status:
#   Returns the given hook's status.
#==============================================================================
dm_test__hooks__trigger_hook__teardown() {
  _dm_test__hooks__trigger_hook \
    "$DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__TEARDOWN" \
    "$DM_TEST__HOOKS__RUNTIME__FLAG__TEARDOWN"
}

#==============================================================================
# Triggers the [setup file] hook.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__SETUP_FILE
#   DM_TEST__HOOKS__RUNTIME__FLAG__SETUP_FILE
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Outputs the given hook's output.
# STDERR:
#   Outputs the given hook's error output.
# Status:
#   Returns the given hook's status.
#==============================================================================
dm_test__hooks__trigger_hook__setup_file() {
  _dm_test__hooks__trigger_hook \
    "$DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__SETUP_FILE" \
    "$DM_TEST__HOOKS__RUNTIME__FLAG__SETUP_FILE"
}

#==============================================================================
# Triggers the [teardown file] hook.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__TEARDOWN_FILE
#   DM_TEST__HOOKS__RUNTIME__FLAG__TEARDOWN_FILE
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Outputs the given hook's output.
# STDERR:
#   Outputs the given hook's error output.
# Status:
#   Returns the given hook's status.
#==============================================================================
dm_test__hooks__trigger_hook__teardown_file() {
  _dm_test__hooks__trigger_hook \
    "$DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__TEARDOWN_FILE" \
    "$DM_TEST__HOOKS__RUNTIME__FLAG__TEARDOWN_FILE"
}

#==============================================================================
# Returns zero if the [setup] hook is available.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__SETUP
#   DM_TEST__HOOKS__RUNTIME__FLAG__SETUP
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
#   0 - Given hook is available.
#   1 - Given hook is not available.
#==============================================================================
dm_test__hooks__is_hook_available__setup() {
  _dm_test__hooks__is_hook_available \
    "$DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__SETUP" \
    "$DM_TEST__HOOKS__RUNTIME__FLAG__SETUP"
}

#==============================================================================
# Returns zero if the [teardown] hook is available.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__TEARDOWN
#   DM_TEST__HOOKS__RUNTIME__FLAG__TEARDOWN
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
#   0 - Given hook is available.
#   1 - Given hook is not available.
#==============================================================================
dm_test__hooks__is_hook_available__teardown() {
  _dm_test__hooks__is_hook_available \
    "$DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__TEARDOWN" \
    "$DM_TEST__HOOKS__RUNTIME__FLAG__TEARDOWN"
}

#==============================================================================
# Returns zero if the [setup file] hook is available.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__SETUP_FILE
#   DM_TEST__HOOKS__RUNTIME__FLAG__SETUP_FILE
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
#   0 - Given hook is available.
#   1 - Given hook is not available.
#==============================================================================
dm_test__hooks__is_hook_available__setup_file() {
  _dm_test__hooks__is_hook_available \
    "$DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__SETUP_FILE" \
    "$DM_TEST__HOOKS__RUNTIME__FLAG__SETUP_FILE"
}

#==============================================================================
# Returns zero if the [teardown file] hook is available.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__TEARDOWN_FILE
#   DM_TEST__HOOKS__RUNTIME__FLAG__TEARDOWN_FILE
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
#   0 - Given hook is available.
#   1 - Given hook is not available.
#==============================================================================
dm_test__hooks__is_hook_available__teardown_file() {
  _dm_test__hooks__is_hook_available \
    "$DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__TEARDOWN_FILE" \
    "$DM_TEST__HOOKS__RUNTIME__FLAG__TEARDOWN_FILE"
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
# Checks if in the given test file execution hooks [setup, teardown, setup_file,
# teardown_file] are present. It checks for only one given hook, and returns the
# match count.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] pattern - Grep compatible pattern that should match the presence of the
#       testable hook.
#   [2] test_file_path - Path of the given test file the hook should be
#       searched in.
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
#==============================================================================
_dm_test__hooks__get_hook_flag() {
  ___pattern="$1"
  ___test_file_path="$2"

  dm_test__debug '_dm_test__hooks__get_hook_flag' \
    "checking hook pattern '${___pattern}' in test file '${___test_file_path}'"

  ___result="$( \
    dm_tools__grep --count "$___pattern" "$___test_file_path" || true \
  )"

  dm_test__debug '_dm_test__hooks__get_hook_flag' \
    "${___result} match was found"

  dm_tools__echo "$___result"
}

#==============================================================================
# Triggers the given hook if it needs to be run based on the related hook flag
# initialized prior to this call.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] hook_name - Name of the triggered hook function.
#   [2] hook_flag - Flag variable that corresponds to the triggered hook.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Outputs the given hook's output.
# STDERR:
#   Outputs the given hook's error output.
# Status:
#   Returns the given hook's status.
#==============================================================================
_dm_test__hooks__trigger_hook() {
  ___hook_name="$1"
  ___hook_flag="$2"

  dm_test__debug '_dm_test__hooks__trigger_hook' \
    "hook function has triggered: '${___hook_name}'"

  if [ "$___hook_flag" -ne '0' ]
  then
    _dm_test__hooks__check_singular_flag "$___hook_flag"
    _dm_test__hooks__execute_hook "$___hook_name"
  else
    dm_test__debug '_dm_test__hooks__trigger_hook' \
      "ignoring trigger for hook function: '${___hook_name}'"
  fi
}

#==============================================================================
# Checks if the given hook is available or not.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] hook_name - Name of the triggered hook function.
#   [2] hook_flag - Flag variable that corresponds to the triggered hook.
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
#   0 - Given hook is available.
#   1 - Given hook is not available.
#==============================================================================
_dm_test__hooks__is_hook_available() {
  ___hook_name="$1"
  ___hook_flag="$2"

  dm_test__debug '_dm_test__hooks__is_hook_available' \
    "checking if hook '${___hook_name}' is available.."

  if [ "$___hook_flag" -ne '0' ]
  then
    dm_test__debug '_dm_test__hooks__is_hook_available' \
      "hook '${___hook_name}' is available"
    return 0
  else
    dm_test__debug '_dm_test__hooks__is_hook_available' \
      "hook '${___hook_name}' is NOT available"
    return 1
  fi

}

#==============================================================================
# Prints a warning if a hook function's flag is greater than one.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] hook_flag - Hook flag that needs to be validated.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Warning message if the given hook flag is greater than one.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_test__hooks__check_singular_flag() {
  ___hook_flag="$1"

  if [ "$___hook_flag" -gt '1' ]
  then
    dm_tools__printf '%s' \
      "WARNING: multiple definitions of hook function '${___hook_name}' "
    dm_tools__echo 'found, only the last one will be executed.'
  fi
}

#==============================================================================
# Executes the given hook function.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__RUNTIME__TEST_DIR__TEST_SUITE
#   DM_TEST__CACHE__RUNTIME__TEST_DIR__TEST_FILE
#   DM_TEST__CACHE__RUNTIME__TEST_DIR__TEST_CASE
#   DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__SETUP
#   DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__TEARDOWN
#   DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__SETUP_FILE
#   DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__TEARDOWN_FILE
# Arguments:
#   [1] hook_name - Name of the triggered hook function.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Outputs the given hook's output.
# STDERR:
#   Outputs the given hook's error output and an error message on failure.
# Status:
#   Returns the given hook's status.
#==============================================================================
_dm_test__hooks__execute_hook() {
  ___hook_name="$1"

  dm_test__debug '_dm_test__hooks__execute_hook' \
    "executing hook function: '${___hook_name}'"

  ___dir_suite="$DM_TEST__CACHE__RUNTIME__TEST_DIR__TEST_SUITE"
  ___dir_file="$DM_TEST__CACHE__RUNTIME__TEST_DIR__TEST_FILE"
  ___dir_case="$DM_TEST__CACHE__RUNTIME__TEST_DIR__TEST_CASE"

  # We have to differentiate between file level and test case level hooks in
  # terms of test directories. For file level hooks, we cannot interprete test
  # case level hooks, as no test case is executing at that time. Hence, test
  # case level test directories only injected into test case level hooks.
  case "$___hook_name" in
    "$DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__SETUP")
      "$___hook_name" "$___dir_suite" "$___dir_file" "$___dir_case"
      ;;
    "$DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__TEARDOWN")
      "$___hook_name" "$___dir_suite" "$___dir_file" "$___dir_case"
      ;;
    "$DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__SETUP_FILE")
      "$___hook_name" "$___dir_suite" "$___dir_file"
      ;;
    "$DM_TEST__HOOKS__CONFIG__FUNCTION_NAME__TEARDOWN_FILE")
      "$___hook_name" "$___dir_suite" "$___dir_file"
      ;;
  esac
}
