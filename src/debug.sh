#!/bin/sh
#==============================================================================
#   _____       _
#  |  __ \     | |
#  | |  | | ___| |__  _   _  __ _
#  | |  | |/ _ \ '_ \| | | |/ _` |
#  | |__| |  __/ |_) | |_| | (_| |
#  |_____/ \___|_.__/ \__,_|\__, |
#                            __/ |
#===========================|___/==============================================
# DEBUG SYSTEM
#==============================================================================

#==============================================================================
#   ____          _                  _          _   _
#  / ___|   _ ___| |_ ___  _ __ ___ (_)______ _| |_(_) ___  _ __
# | |  | | | / __| __/ _ \| '_ ` _ \| |_  / _` | __| |/ _ \| '_ \
# | |__| |_| \__ \ || (_) | | | | | | |/ / (_| | |_| | (_) | | | |
#  \____\__,_|___/\__\___/|_| |_| |_|_/___\__,_|\__|_|\___/|_| |_|
#==============================================================================
# DEBUG SYSTEM CUSTOMIZATION LAYER
#==============================================================================

#==============================================================================
# The following two functions provide a way to customize the file descriptor
# used by the debug system. By default the debug messages are sent to file
# descriptor 4. If this is not suitable for the testable target, a custom file
# descriptor could be set by overriding these two functions and using a
# different file descriptor inside them.
#
# Be aware, than file descriptor 1-3 are captured during test case execution.
# Beside the capturing, having any output on file descriptor 2 during test case
# execution will make the test case to fail.
#
# Note, that there are other ways to have a dynamic file descriptor redirection
# that is controlled by a configuration variable, but AFAIK it can be only
# achieved by using `eval` which is undesirable in this project.
#==============================================================================

#==============================================================================
# Printf proxy function that redirects the output to file descriptor 4. This
# function can be used to set up a different file descriptor for the debug
# output by overriding it.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [..] args - printf compatible argument interface.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# FILE_DESCRIPTOR_4:
#   This function uses file descriptor 4 to output the debug messages. This
#   file descriptor needs to be opened for the process before any writing
#   attempt.
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm_test__debug__printf() {
  # This function behaves like a proxy thus having parameters in the first
  # argument of printf is okay in this case.
  # shellcheck disable=SC2059
  >&4 dm_tools__printf "$@"
}

#==============================================================================
# Custom runner function to initialize file descriptor for the debug system.
# This function has to wrap the main test suite call by passing the function
# name to this function.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [..] args - Variable length arguments that will be executed as a command
#        while having a file descriptor attached to it.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Output of the given command and also the redirected file descriptor 4
#   output.
# STDERR:
#   Output of the given command.
# Status:
#   Status of the given command.
#==============================================================================
dm_test__debug__wrapper() {
  "$@" 4>&1
}

#==============================================================================
#  ____       _                      _    ____ ___
# |  _ \  ___| |__  _   _  __ _     / \  |  _ \_ _|
# | | | |/ _ \ '_ \| | | |/ _` |   / _ \ | |_) | |
# | |_| |  __/ |_) | |_| | (_| |  / ___ \|  __/| |
# |____/ \___|_.__/ \__,_|\__, | /_/   \_\_|  |___|
#=========================|___/================================================
# DEBUG API
#==============================================================================

#==============================================================================
# General debug message registering. Since we are writing the test system purely
# in bash, we cannot determine the caller function name in a portable POSIX
# compliant way, so we have to pass the function name to the debug message..
#------------------------------------------------------------------------------
# Globals:
#   DIM
#   BLUE
#   RESET
# Arguments:
#   [1] domain - Debug message's domain, i.e. the function's name it is emitted
#                from.
#   [2] message - Content of the debug message.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Debug message if debug mode is enabled.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm_test__debug() {
  if dm_test__config__debug_is_enabled
  then
    ___debug_domain="$1"
    ___debug_message="$2"

    dm_test__debug__printf "${DIM}${BLUE}DEBUG | %56s | %s\n${RESET}" \
      "$___debug_domain" \
      "$___debug_message"
  fi
}

#==============================================================================
# List based debug message registering.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] domain - Debug message's domain, i.e. the function it is emitted from.
#   [2] message - Content of the debug message.
#   [3] list - Whitespace separated list that will be broken up during
#       printout.
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
dm_test__debug_list() {
  if dm_test__config__debug_is_enabled
  then
    ___debug_domain="$1"
    ___debug_message="$2"
    ___debug_list="$3"

    dm_test__debug "$___debug_domain" "$___debug_message"

    dm_tools__echo "$___debug_list" | while IFS= read -r ___debug_list_item
    do
      dm_test__debug "$___debug_domain" "- '${___debug_list_item}'"
    done
  fi
}
