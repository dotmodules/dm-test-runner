#==============================================================================
# OUTPUT CAPTURING
#==============================================================================

#==============================================================================
# During test case execution the test runner captures the standard output,
# standard error and the file descriptor 3 as an optional debugger ouput. The
# captured content will be only visible if the test case fails. Having captured
# standard error content makes the test case automatically fail.
#
# Note that the captured outputs might not be printed in the exact order as the
# test case executes them. This is due to the way the test runner captures the
# outputs with processing commands running as a background command, having no
# control over the timings.
#
# If the tested code outputs too much in its outputs, the related capturing
# processes might not be able to keep up with the rate, and might not be able
# to process all output lines before a failing assertion exits from the test
# case execution. Therefore the executor code has to make sure that the
# capturing processes has not effected by the exit call due to the failed
# assertion. This can be achieved by executing the test case in another
# subshell inside the capturing function.
#==============================================================================

setup() {
  echo 'There should be 42 debug messages displayed after execution.' >&3
  echo 'FD3 [01/42] - setup hook' >&3
}

test__overwhelmed_capturing_process() {
  # If all of the 42 output lines appears in the captured debug output, then
  # the capturing process is not affected by the assertion exit call.
  dummy_function() {
    echo 'FD3 [02/42] - test case' >&3
    echo 'FD3 [03/42] - test case' >&3
    echo 'FD3 [04/42] - test case' >&3
    echo 'FD3 [05/42] - test case' >&3
    echo 'FD3 [06/42] - test case' >&3
    echo 'FD3 [07/42] - test case' >&3
    echo 'FD3 [08/42] - test case' >&3
    echo 'FD3 [09/42] - test case' >&3
    echo 'FD3 [10/42] - test case' >&3
    echo 'FD3 [11/42] - test case' >&3
    echo 'FD3 [12/42] - test case' >&3
    echo 'FD3 [13/42] - test case' >&3
    echo 'FD3 [14/42] - test case' >&3
    echo 'FD3 [15/42] - test case' >&3
    echo 'FD3 [16/42] - test case' >&3
    echo 'FD3 [17/42] - test case' >&3
    echo 'FD3 [18/42] - test case' >&3
    echo 'FD3 [19/42] - test case' >&3
    echo 'FD3 [20/42] - test case' >&3
    echo 'FD3 [21/42] - test case' >&3
    echo 'FD3 [22/42] - test case' >&3
    echo 'FD3 [23/42] - test case' >&3
    echo 'FD3 [24/42] - test case' >&3
    echo 'FD3 [25/42] - test case' >&3
    echo 'FD3 [26/42] - test case' >&3
    echo 'FD3 [27/42] - test case' >&3
    echo 'FD3 [28/42] - test case' >&3
    echo 'FD3 [29/42] - test case' >&3
    echo 'FD3 [30/42] - test case' >&3
    echo 'FD3 [31/42] - test case' >&3
    echo 'FD3 [32/42] - test case' >&3
    echo 'FD3 [33/42] - test case' >&3
    echo 'FD3 [34/42] - test case' >&3
    echo 'FD3 [35/42] - test case' >&3
    echo 'FD3 [36/42] - test case' >&3
    echo 'FD3 [37/42] - test case' >&3
    echo 'FD3 [38/42] - test case' >&3
    echo 'FD3 [39/42] - test case' >&3
    echo 'FD3 [40/42] - test case' >&3
    echo 'FD3 [41/42] - test case' >&3
    return 1
  }
  run dummy_function
  assert_status 0
}

teardown() {
  echo 'FD3 [42/42] - teardown hook' >&3
  echo 'There should be 42 debug messages displayed after execution.' >&3
}

