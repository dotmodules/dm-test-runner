#==============================================================================
#    _____            _
#   / ____|          | |
#  | |     __ _ _ __ | |_ _   _ _ __ ___
#  | |    / _` | '_ \| __| | | | '__/ _ \
#  | |___| (_| | |_) | |_| |_| | | |  __/
#   \_____\__,_| .__/ \__|\__,_|_|  \___|
#              | |
#==============|_|=============================================================
# CAPTURE
#==============================================================================

#==============================================================================
# Submodule that provides a way to execute and capture all outputs of a process
# in a separated way. The captured outputs can be merged together to display
# them at once in an ordered way. The different outputs are differentiated with
# a prefix in the merged lines.
#
# Besides standard output (FD1) standard error (FD2), file descriptor 3 was
# considered as a debugger output for the captured commands and functions. If
# no file descriptor 3 output is present, the capture system will ignore it, so
# it is not a requirement to have output on that file descriptor.
#
# NOTE: the exact time correct ordering is unfortunately not possible with
# this setup. If two event happens too close to each other, the real order
# could be inverted or mixed. This is due to the fact how the OS scheduler
# handles the fifo write events. It can be tested by echoing out a simple
# text from the test case in sequence to all available outputs, and
# inspecting the order in the report, ie:
# >&1 echo 'FD1'
# >&2 echo 'FD2'
# >&3 echo 'FD3'
# >&1 echo 'FD1'
# >&2 echo 'FD2'
# >&3 echo 'FD3'
# Usually this is not a problem though, as between the printouts there are
# usually some other code to execute, that allows the background processes to
# process the outputs in the correct order.
#==============================================================================

# Predefined capture in a subshell flags for the capturing function. See
# details in the 'dm_test__capture__run_and_capture' function definition. These
# constants won't be used in this file, hence the shellcheck command.
# shellcheck disable=SC2034
DM_TEST__CAPTURE__CONSTANT__EXECUTE_COMMAND_IN_SUBSHELL='1'
DM_TEST__CAPTURE__CONSTANT__EXECUTE_COMMAND_DIRECTLY='0'

# Runtime variables to be able to store the process outputs.
DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD1='__INVALID__'
DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD2='__INVALID__'
DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD3='__INVALID__'

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
# Initializes the capture system for a new capture. It will set the global
# runtime variables. It is important to note that the initialization should be
# executed in the same subshell level as the output gathering.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD1
#   DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD2
#   DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD3
# STDOUT:
#   Path to the generated fifo.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#------------------------------------------------------------------------------
# Tools:
#   None
#==============================================================================
dm_test__capture__init() {
  dm_test__debug 'dm_test__capture__init' 'initializing capture system..'

  dm_test__debug 'dm_test__capture__init' \
    'initializing temporary capture files..'
  DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD1="$( \
    _dm_test__capture__create_temp_file \
  )"
  DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD2="$( \
    _dm_test__capture__create_temp_file \
  )"
  DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD3="$( \
    _dm_test__capture__create_temp_file \
  )"
  dm_test__debug 'dm_test__capture__init' 'temporary capture files initialized'

  dm_test__debug 'dm_test__capture__init' 'capture system initialized'
}

#==============================================================================
# Running the given command and capturing all possible outputs of it. For
# capturing its outputs, the standard output, standard error and the optional
# file descriptor 3 will be attached to temporary named pipes. These pipes will
# be read from separate background processes that will prefix each received
# line with a timestamp while formatting it. The prefixed and formatted lines
# then will be written to dedicated temporary files. The test case's status
# code will also be captured.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD1
#   DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD2
#   DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD3
#   BLUE
#   RED
#   DIM
# Arguments:
#   [1] execute_in_subshell_flag - This flag indicates if the passed command
#       should be executed in a subshell or not. If the value is nonzero, the
#       command wil be executed in a subshell. Executing in a subshell make the
#       capturing processes unaffected by the failed assertion exit call, thus
#       they can finish the scheduled capturings.
#   [..] command - Command as a string that will be executed and captured.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
#------------------------------------------------------------------------------
# Tools:
#   wait test
#==============================================================================
dm_test__capture__run_and_capture() {
  ___execute_in_a_subshell="$1"
  shift
  ___command="$*"

  # Using local variables to have somewhat shorter variable names.
  ___file__fd1="$DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD1"
  ___file__fd2="$DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD2"
  ___file__fd3="$DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD3"

  dm_test__debug 'dm_test__capture__run_and_capture' \
    'initializing temporary capture fifos..'
  ___fifo__fd1="$(_dm_test__capture__create_temp_fifo)"
  ___fifo__fd2="$(_dm_test__capture__create_temp_fifo)"
  ___fifo__fd3="$(_dm_test__capture__create_temp_fifo)"
  dm_test__debug 'dm_test__capture__run_and_capture' \
    'temporary capture fifos initialized'

  # Starting the processor functions in the background and storing they pids to
  # be able to wait for them later.
  dm_test__debug 'dm_test__capture__run_and_capture' \
    'starting file descriptor processing workers in the background..'

  _dm_test__capture__capture_output_for_domain 'stdout' "$BLUE" \
    <"$___fifo__fd1" >>"$___file__fd1" &
  ___pid__fd1="$!"
  _dm_test__capture__capture_output_for_domain 'stderr' "$RED" \
    <"$___fifo__fd2" >>"$___file__fd2" &
  ___pid__fd2="$!"
  _dm_test__capture__capture_output_for_domain 'debug ' "$DIM" \
    <"$___fifo__fd3" >>"$___file__fd3" &
  ___pid__fd3="$!"

  dm_test__debug 'dm_test__capture__run_and_capture' \
    "capture process started for FD1 on pid ${___pid__fd1}"
  dm_test__debug 'dm_test__capture__run_and_capture' \
    "capture process started for FD2 on pid ${___pid__fd2}"
  dm_test__debug 'dm_test__capture__run_and_capture' \
    "capture process started on FD3 pid ${___pid__fd3}"

  dm_test__debug 'dm_test__capture__run_and_capture' \
    "executing command '${___command}'.."

  # We are doing four things here while executing the test case:
  # 1. Blocking the terminate on error global setting by executing the test
  #    case in an if statement while capturing the status code.
  # 2. Capturing the standard output through a fifo.
  # 3. Capturing the standard error through a fifo.
  # 4. Capturing the optional file descriptor 3 assuming it is the debugger
  #    output through a fifo.
  if [ "$___execute_in_a_subshell" -ne '0' ]
  then
    # Executing command in an additional subshell, to prevent the failed
    # assertion exit call effect this currently executing shell.
    if ( $___command ) \
        1>"$___fifo__fd1" \
        2>"$___fifo__fd2" \
        3>"$___fifo__fd3"
    then
      ___status="$?"
    else
      ___status="$?"
    fi
  else
    # Executing command in this shell to be able to affect the environment.
    if $___command \
        1>"$___fifo__fd1" \
        2>"$___fifo__fd2" \
        3>"$___fifo__fd3"
    then
      ___status="$?"
    else
      ___status="$?"
    fi
  fi

  dm_test__debug 'dm_test__capture__run_and_capture' \
    '%%%%%%%%%%%%%%%% waiting for file descriptor processing workers..'

  # Waiting for the output processor background processes to finish. After
  # this, the outputs are available in the temporary files.
  wait "$___pid__fd1" "$___pid__fd2" "$___pid__fd3"

  dm_test__debug 'dm_test__capture__run_and_capture' \
    'evaluating test case results..'

  return "$___status"
}

#==============================================================================
# Merges and sorts the captured outputs located in the temporary files. The
# sorting might not be perfect due to the way the background processes process
# the designated outputs.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD1
#   DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD2
#   DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD3
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Merged and sorted captured file descriptor outputs.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#------------------------------------------------------------------------------
# Tools:
#   cat sort sed
#==============================================================================
dm_test__capture__get_captured_outputs() {
  dm_test__debug 'dm_test__capture__get_captured_outputs' \
    'merging and sorting captured outputs..'

  # Using the timestamps preceding every line for sorting, then removing it.
  {
    cat "$DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD1"
    cat "$DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD2"
    cat "$DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD3"
  } | sort | sed -E 's/^[[:digit:]]+\s//'
}

#==============================================================================
# Returns true if there was output on standard error.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD2
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
#   0 - There was output on standard error.
#   1 - There was no output on standard error.
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
dm_test__capture__was_standard_error_captured() {
  dm_test__debug 'dm_test__capture__was_standard_error_captured' \
    'checking if there was output captured from standard error..'

  if [ -s "$DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD2" ]
  then
    dm_test__debug 'dm_test__capture__was_standard_error_captured' \
      'standard error was captured'
    return 0
  else
    dm_test__debug 'dm_test__capture__was_standard_error_captured' \
      'nothing was captured from standard error'
    return 1
  fi
}

#==============================================================================
# Appends a string to the temporary file that captures the standard errors in
# the same way as the capturing process would have done it, so it will be
# processable by the sorting and merging function.
#------------------------------------------------------------------------------
# Globals:
#   RED RESET
#   DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD2
# Arguments:
#   [1] message - Formatted message that needs to be appended to the standard
#       error file.
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
#------------------------------------------------------------------------------
# Tools:
#   echo
#==============================================================================
dm_test__capture__append_to_standard_error() {
  ___message="$1"

  dm_test__debug 'dm_test__capture__append_to_standard_error' \
    'appending to standard error temporary file..'

  ___timestamp="$(_dm_test__capture__create_timestamp)"

  echo "${___timestamp} ${RED}stderr | ${___message}${RESET}" >> \
    "$DM_TEST__CAPTURE__RUNTIME__TEMP_FILE__FD2"
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
# Creates a temporary file for capturing output content.
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
#   Path to the generated file.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#------------------------------------------------------------------------------
# Tools:
#   touch echo
#==============================================================================
_dm_test__capture__create_temp_file() {
  dm_test__debug '_dm_test__capture__create_temp_file' \
    'creating temporary file..'

  ___tmp_path="$(dm_test__cache__create_temp_file)"
  # Touching might not be necessary as redirecting an output would create a
  # file, but touching it anyway, if the capturing process fails for some
  # reason.
  touch "$___tmp_path"

  dm_test__debug '_dm_test__capture__create_temp_file' \
    "temporary file created: '${___tmp_path}'"

  echo "$___tmp_path"
}

#==============================================================================
# Creates a temporary file as a fifo.
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
#   Path to the generated fifo.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#------------------------------------------------------------------------------
# Tools:
#   mkfifo echo
#==============================================================================
_dm_test__capture__create_temp_fifo() {
  dm_test__debug '_dm_test__capture__create_temp_fifo' \
    'creating temporary fifo..'

  ___tmp_path="$(dm_test__cache__create_temp_file)"
  mkfifo "$___tmp_path"

  dm_test__debug '_dm_test__capture__create_temp_fifo' \
    "temporary fifo created: '${___tmp_path}'"

  echo "$___tmp_path"
}

#==============================================================================
# Text line processor function that has triple duty:
# - Prepends each line with a precise timestamp that could be used for sorting
#   later on.
# - Inserts the given domain name that is passed as an argument into each line.
# - Colors each line with the given color passed as an argument.
#------------------------------------------------------------------------------
# Globals:
#   RESET
# Arguments:
#   [1] domain - Domain name the processing is happening in.
#   [2] color - The color the line should be colored with.
# STDIN:
#   Processable lines of text.
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Processed lines.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#------------------------------------------------------------------------------
# Tools:
#   read echo printf
#==============================================================================
_dm_test__capture__capture_output_for_domain() {
  ___worker_domain="$1"
  ___worker_color="$2"

  dm_test__debug '_dm_test__capture__capture_output_for_domain' \
    ">> processing worker for domain '${___worker_domain}' is waiting for input.."

  while read -r ___worker_line
  do
    ___timestamp="$(_dm_test__capture__create_timestamp)"
    printf '%s' "${___timestamp} ${___worker_color}${___worker_domain} | "
    echo "${___worker_line}${RESET}"
  done

  dm_test__debug '_dm_test__capture__capture_output_for_domain' \
    ">> worker process finished for domain '${___worker_domain}'"
}

#==============================================================================
# Returns the sorting related timestamp prefix.
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
#   Timestamp prefix.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#------------------------------------------------------------------------------
# Tools:
#   echo date
#==============================================================================
_dm_test__capture__create_timestamp() {
  ___timestamp="$(date +'%s%N')"
  echo "$___timestamp"
}
