#!/bin/sh
#==============================================================================
# CONTEXT ASSERTIONS - Require running the testable function  with the 'run'.
#==============================================================================

#==============================================================================
# ASSERT_STATUS
#------------------------------------------------------------------------------
# Asserts the status of the last function or command runned by the 'run'
# command.
#==============================================================================

test__assert_status() {
  dummy_function() {
    return 3
  }
  run dummy_function
  assert_status 3
}

test__assert_status__implicit_zero_status() {
  dummy_function() {
    :
  }
  run dummy_function
  assert_status 0
}

should_fail__assert_status() {
  echo 'Expected [assert_status] failure.'
  dummy_function() {
    return 3
  }
  run dummy_function
  assert_status 2
}

#==============================================================================
# ASSERT_OUTPUT WITHOUT A PARAMETER
#------------------------------------------------------------------------------
# Asserts if something has been captured during the last 'run' command
# execution.
#==============================================================================

test__assert_output__no_parameter() {
  dummy_function() {
    echo 'hello'
  }
  run dummy_function
  assert_output
}

test__assert_output__no_parameter__no_newline() {
  dummy_function() {
    printf 'no newline after this line!'
  }
  run dummy_function
  assert_output
}

should_fail__assert_output__no_parameter__empty_output() {
  echo 'Expected [assert_output] failure.'
  dummy_function() {
    :
  }
  run dummy_function
  assert_output
}

#==============================================================================
# ASSERT_NO_OUTPUT
#------------------------------------------------------------------------------
# Asserts if nothing has been captured during the last 'run' command execution.
#==============================================================================

test__assert_no_output() {
  dummy_function() {
    :
  }
  run dummy_function
  assert_no_output
}

should_fail__assert_no_output() {
  echo 'Expected [assert_no_output] failure.'
  dummy_function() {
    echo 'Definitely not an empty'
    echo 'output!'
  }
  run dummy_function
  assert_no_output
}

should_fail__assert_no_output__no_newline() {
  echo 'Expected [assert_no_output] failure.'
  dummy_function() {
    printf 'no newline after this line!'
  }
  run dummy_function
  assert_no_output
}

#==============================================================================
# ASSERT_OUTPUT WITH A PARAMETER
#------------------------------------------------------------------------------
# Asserts the whole captured output of the last function or command runned by
# the 'run' command.
#==============================================================================

test__assert_output() {
  dummy_function() {
    echo 'hello'
  }
  run dummy_function
  assert_output 'hello'
}

test__assert_output__no_newline() {
  dummy_function() {
    printf 'no newline after this line!'
  }
  run dummy_function
  assert_output 'no newline after this line!'
}

should_fail__assert_output__empty_output() {
  echo 'Expected [assert_output] failure.'
  dummy_function() {
    :
  }
  run dummy_function
  assert_output 'bye'
}

should_fail__assert_output__mismatch() {
  echo 'Expected [assert_output] failure.'
  dummy_function() {
    echo 'hello'
  }
  run dummy_function
  assert_output 'bye'
}

should_fail__assert_output__multiline_output_fails_assertion() {
  echo 'Expected [assert_output] failure.'
  dummy_function() {
    echo 'hello 1'
    echo 'hello 2'
  }
  run dummy_function
  assert_output 'hello 1\nhello 2'
}

#==============================================================================
# ASSERT_OUTPUT_LINE_COUNT
#------------------------------------------------------------------------------
# Asserts the line count of the output of the last function or command runned
# by the 'run' command.
#==============================================================================

test__assert_output_line_count() {
  dummy_function() {
    echo 'hello 1'
    echo 'hello 2'
    echo 'hello 3'
  }
  run dummy_function
  assert_output_line_count 3
}

test__assert_output_line_count__empty_count_should_be_handled() {
  dummy_function() {
    :
  }
  run dummy_function
  assert_output_line_count 0
}

test__assert_output_line_count__empty_string() {
  dummy_function() {
    printf ''
  }
  run dummy_function
  assert_output_line_count 0
}

test__assert_output_line_count__only_newline() {
  dummy_function() {
    echo ''
  }
  run dummy_function
  assert_output_line_count 1
}

test__assert_output_line_count__no_newline_should_be_handled() {
  dummy_function() {
    printf 'no newline after this line!'
  }
  run dummy_function
  assert_output_line_count 1
}

should_fail__assert_output_line_count() {
  echo 'Expected [assert_output_line_count] failure.'
  dummy_function() {
    echo 'hello'
  }
  run dummy_function
  assert_output_line_count 42
}

#==============================================================================
# ASSERT_OUTPUT_LINE_AT_INDEX
#------------------------------------------------------------------------------
# Asserts the line indexed line of the output of the last function or command
# runned by the 'run' command. Lines are indexed from 1.
#==============================================================================

test__assert_output_line_at_index() {
  dummy_function() {
    echo 'hello 1'
    echo 'hello 2'
    echo 'hello 3'
  }
  run dummy_function
  assert_output_line_at_index 2 'hello 2'
}

test__assert_output_line_at_index__single_line_without_newline() {
  dummy_function() {
    printf 'no newline after this line!'
  }
  run dummy_function
  assert_output_line_at_index 1 'no newline after this line!'
}

should_fail__assert_output_line_at_index__empty_output() {
  echo 'Expected [assert_output_line_at_index] failure.'
  dummy_function() {
    :
  }
  run dummy_function
  assert_output_line_at_index 2 'hello 2'
}

should_fail__assert_output_line_at_index__invalid_index__case_1() {
  echo 'Expected [assert_output_line_at_index] failure.'
  dummy_function() {
    echo 'hello'
    echo 'hello'
    echo 'hello'
  }
  run dummy_function
  assert_output_line_at_index 42 'invalid index'
}

should_fail__assert_output_line_at_index__invalid_index__case_2() {
  echo 'Expected [assert_output_line_at_index] failure.'
  dummy_function() {
    echo 'hello'
    echo 'hello'
    echo 'hello'
  }
  run dummy_function
  assert_output_line_at_index 0 'invalid index'
}

should_fail__assert_output_line_at_index__invalid_index__case_3() {
  echo 'Expected [assert_output_line_at_index] failure.'
  dummy_function() {
    echo 'hello'
    echo 'hello'
    echo 'hello'
  }
  run dummy_function
  assert_output_line_at_index -1 'invalid index'
}

should_fail__assert_output_line_at_index__no_match() {
  echo 'Expected [assert_output_line_at_index] failure.'
  dummy_function() {
    echo 'hello 1'
    echo 'hello 2'
    echo 'hello 3'
  }
  run dummy_function
  # This assertion matches the whole line.
  assert_output_line_at_index 2 'hello'
}

test__assert_output_line_line_at_index__empty_line_can_be_validated() {
  dummy_function() {
    echo ''
  }
  run dummy_function
  assert_output_line_at_index 1 ''
}

should_fail__assert_output_line_at_index__empty_line_wont_get_ignored() {
  echo 'Expected [assert_output_line_at_index] failure.'
  dummy_function() {
    echo ''
  }
  run dummy_function
  assert_output_line_at_index 1 'not empty line'
}

#==============================================================================
# ASSERT_OUTPUT_LINE_PARTIALLY_AT_INDEX
#------------------------------------------------------------------------------
# Asserts the line indexed line partially of the output of the last function or
# command runned by the 'run' command. Lines are indexed from 1.
#==============================================================================

test__assert_output_line_partially_at_index() {
  dummy_function() {
    echo 'hello 1'
    echo 'hello 2'
    echo 'hello 3'
  }
  run dummy_function
  assert_output_line_partially_at_index 2 'hello'
}

test__assert_output_line_partially_at_index__no_newline_handling() {
  dummy_function() {
    printf 'no newline after this line!'
  }
  run dummy_function
  assert_output_line_partially_at_index 1 'newline after'
}

should_fail__assert_output_line_partially_at_index__empty_output() {
  echo 'Expected [assert_output_line_partially_at_index] failure.'
  dummy_function() {
    :
  }
  run dummy_function
  assert_output_line_partially_at_index 2 'hello 2'
}

should_fail__assert_output_line_partially_at_index__invalid_index__case_1() {
  echo 'Expected [assert_output_line_partially_at_index] failure.'
  dummy_function() {
    echo 'hello'
    echo 'hello'
    echo 'hello'
  }
  run dummy_function
  assert_output_line_partially_at_index 42 'hello'
}

should_fail__assert_output_line_partially_at_index__invalid_index__case_2() {
  echo 'Expected [assert_output_line_partially_at_index] failure.'
  dummy_function() {
    echo 'hello'
    echo 'hello'
    echo 'hello'
  }
  run dummy_function
  assert_output_line_partially_at_index 0 'hello'
}

should_fail__assert_output_line_partially_at_index__invalid_index__case_3() {
  echo 'Expected [assert_output_line_partially_at_index] failure.'
  dummy_function() {
    echo 'hello'
    echo 'hello'
    echo 'hello'
  }
  run dummy_function
  assert_output_line_partially_at_index -1 'hello'
}

should_fail__assert_output_line_partially_at_index__no_match() {
  echo 'Expected [assert_output_line_partially_at_index] failure.'
  dummy_function() {
    echo 'hello 1'
    echo 'hello 2'
    echo 'hello 3'
  }
  run dummy_function
  assert_output_line_partially_at_index 2 'unrelated content'
}

test__assert_output_line_partially_at_index__empty_line_can_be_validated() {
  dummy_function() {
    echo ''
  }
  run dummy_function
  assert_output_line_partially_at_index 1 ''
}

should_fail__assert_output_line_partially_at_index__empty_line_wont_get_ignored() {
  echo 'Expected [assert_output_line_partially_at_index] failure.'
  dummy_function() {
    echo ''
  }
  run dummy_function
  assert_output_line_partially_at_index 1 'not empty line'
}

#==============================================================================
# ASSERT_ERROR WITHOUT A PARAMETER
#------------------------------------------------------------------------------
# Asserts if something has been captured on the error output of the last
# function or command runned by the 'run' command.
#==============================================================================

test__assert_error__without_parameter() {
  dummy_function() {
    echo 'hello' >&2
  }
  run dummy_function
  assert_error
}

test__assert_error__without_parameter__no_newline() {
  dummy_function() {
    printf 'no newline after this line!' >&2
  }
  run dummy_function
  assert_error
}

should_fail__assert_error__without_parameter() {
  echo 'Expected [assert_error] failure.'
  dummy_function() {
    :
  }
  run dummy_function
  assert_error
}

#==============================================================================
# ASSERT_ERROR WITH A PARAMETER
#------------------------------------------------------------------------------
# Asserts the whole captured error output of the last function or command
# runned by the 'run' command.
#==============================================================================

test__assert_error() {
  dummy_function() {
    echo 'hello' >&2
  }
  run dummy_function
  assert_error 'hello'
}

test__assert_error__no_newline() {
  dummy_function() {
    printf 'no newline after this line!' >&2
  }
  run dummy_function
  assert_error 'no newline after this line!'
}

should_fail__assert_error__empty_output() {
  echo 'Expected [assert_error] failure.'
  dummy_function() {
    :
  }
  run dummy_function
  assert_error 'hello'
}

should_fail__assert_error__mismatch() {
  echo 'Expected [assert_error] failure.'
  dummy_function() {
    echo 'hello' >&2
  }
  run dummy_function
  assert_error 'bye'
}

should_fail__assert_error__multiline_output_fails_assertion() {
  echo 'Expected [assert_error] failure.'
  dummy_function() {
    echo 'hello 1' >&2
    echo 'hello 2' >&2
  }
  run dummy_function
  assert_error 'hello 1\nhello 2'
}

#==============================================================================
# ASSERT_NO_ERROR
#------------------------------------------------------------------------------
# Asserts the whole captured error output of the last function or command
# runned by the 'run' command.
#==============================================================================

test__assert_no_error() {
  dummy_function() {
    echo 'hello'
  }
  run dummy_function
  assert_no_error
}

should_fail__assert_no_error() {
  echo 'Expected [assert_no_error] failure.'
  dummy_function() {
    echo 'error line 1' >&2
    echo 'error line 2' >&2
  }
  run dummy_function
  assert_no_error
}

should_fail__assert_no_error__no_newline() {
  echo 'Expected [assert_no_error] failure.'
  dummy_function() {
    printf 'no newline after this line!' >&2
  }
  run dummy_function
  assert_no_error
}

#==============================================================================
# ASSERT_ERROR_LINE_COUNT
#------------------------------------------------------------------------------
# Asserts the line count of the error output of the last function or command
# runned by the 'run' command.
#==============================================================================

test__assert_error_line_count() {
  dummy_function() {
    echo 'hello 1' >&2
    echo 'hello 2' >&2
    echo 'hello 3' >&2
  }
  run dummy_function
  assert_error_line_count 3
}

test__assert_error_line_count__empty_output_should_be_handled() {
  dummy_function() {
    :
  }
  run dummy_function
  assert_error_line_count 0
}

test__assert_error_line_count__empty_string() {
  dummy_function() {
    printf '' >&2
  }
  run dummy_function
  assert_error_line_count 0
}

test__assert_error_line_count__newline_only() {
  dummy_function() {
    echo '' >&2
  }
  run dummy_function
  assert_error_line_count 1
}

test__assert_error_line_count__no_newline_should_be_handled() {
  dummy_function() {
    printf 'no newline after this line!' >&2
  }
  run dummy_function
  assert_error_line_count 1
}

should_fail__assert_error_line_count() {
  echo 'Expected [assert_error_line_count] failure.'
  dummy_function() {
    echo 'hello' >&2
  }
  run dummy_function
  assert_error_line_count 42
}

#==============================================================================
# ASSERT_ERROR_LINE_AT_INDEX
#------------------------------------------------------------------------------
# Asserts the line indexed line of the error output of the last function or
# command runned by the 'run' command. Lines are indexed from 1.
#==============================================================================

test__assert_error_line_at_index() {
  dummy_function() {
    echo 'hello 1' >&2
    echo 'hello 2' >&2
    echo 'hello 3' >&2
  }
  run dummy_function
  assert_error_line_count 3
  assert_error_line_at_index 2 'hello 2'
}

test__assert_error_line_at_index__no_newline() {
  dummy_function() {
    printf 'no newline after this line!' >&2
  }
  run dummy_function
  assert_error_line_count 1
  assert_error_line_at_index 1 'no newline after this line!'
}

should_fail__assert_error_line_at_index__empty_output() {
  echo 'Expected [assert_error_line_at_index] failure.'
  dummy_function() {
    :
  }
  run dummy_function
  assert_error_line_at_index 42 'invalid index'
}

should_fail__assert_error_line_at_index__invalid_index__case_1() {
  echo 'Expected [assert_error_line_at_index] failure.'
  dummy_function() {
    echo 'hello' >&2
    echo 'hello' >&2
    echo 'hello' >&2
  }
  run dummy_function
  assert_error_line_count 3
  assert_error_line_at_index 42 'invalid index'
}

should_fail__assert_error_line_at_index__invalid_index__case_2() {
  echo 'Expected [assert_error_line_at_index] failure.'
  dummy_function() {
    echo 'hello' >&2
    echo 'hello' >&2
    echo 'hello' >&2
  }
  run dummy_function
  assert_error_line_count 3
  assert_error_line_at_index 0 'invalid index'
}

should_fail__assert_error_line_at_index__invalid_index__case_3() {
  echo 'Expected [assert_error_line_at_index] failure.'
  dummy_function() {
    echo 'hello' >&2
    echo 'hello' >&2
    echo 'hello' >&2
  }
  run dummy_function
  assert_error_line_count 3
  assert_error_line_at_index -1 'invalid index'
}

should_fail__assert_error_line_at_index__no_match() {
  echo 'Expected [assert_error_line_at_index] failure.'
  dummy_function() {
    echo 'hello 1' >&2
    echo 'hello 2' >&2
    echo 'hello 3' >&2
  }
  run dummy_function
  assert_error_line_count 3
  # This assertion matches the whole line.
  assert_error_line_at_index 2 'hello'
}

test__assert_output_line_line_at_index__empty_line_can_be_validated() {
  echo 'Expected [assert_error_line_at_index] failure.'
  dummy_function() {
    echo '' >&2
  }
  run dummy_function
  assert_error_line_count 1
  assert_error_line_at_index 1 ''
}

should_fail__assert_error_line_at_index__empty_line_wont_get_ignored() {
  echo 'Expected [assert_error_line_at_index] failure.'
  dummy_function() {
    echo '' >&2
  }
  run dummy_function
  assert_error_line_count 1
  assert_error_line_at_index 1 'not empty line'
}

#==============================================================================
# ASSERT_ERROR_LINE_PARTIALLY_AT_INDEX
#------------------------------------------------------------------------------
# Asserts the line indexed line partially of the error output of the last
# function or command runned by the 'run' command. Lines are indexed from 1.
#==============================================================================

test__assert_error_line_partially_at_index() {
  dummy_function() {
    echo 'hello 1' >&2
    echo 'hello 2' >&2
    echo 'hello 3' >&2
  }
  run dummy_function
  assert_error_line_count 3
  assert_error_line_partially_at_index 2 'hello'
}

test__assert_error_line_partially_at_index__no_newline() {
  dummy_function() {
    printf 'no newline after this line!' >&2
  }
  run dummy_function
  assert_error_line_count 1
  assert_error_line_partially_at_index 1 'newline after'
}

should_fail__assert_error_line_partially_at_index__empty_output() {
  echo 'Expected [assert_error_line_partially_at_index] failure.'
  dummy_function() {
    :
  }
  run dummy_function
  assert_error_line_partially_at_index 42 'hello'
}

should_fail__assert_error_line_partially_at_index__invalid_index__case_1() {
  echo 'Expected [assert_error_line_partially_at_index] failure.'
  dummy_function() {
    echo 'hello' >&2
    echo 'hello' >&2
    echo 'hello' >&2
  }
  run dummy_function
  assert_error_line_count 3
  assert_error_line_partially_at_index 42 'hello'
}

should_fail__assert_error_line_partially_at_index__invalid_index__case_2() {
  echo 'Expected [assert_error_line_partially_at_index] failure.'
  dummy_function() {
    echo 'hello' >&2
    echo 'hello' >&2
    echo 'hello' >&2
  }
  run dummy_function
  assert_error_line_count 3
  assert_error_line_partially_at_index 0 'hello'
}

should_fail__assert_error_line_partially_at_index__invalid_index__case_3() {
  echo 'Expected [assert_error_line_partially_at_index] failure.'
  dummy_function() {
    echo 'hello' >&2
    echo 'hello' >&2
    echo 'hello' >&2
  }
  run dummy_function
  assert_error_line_count 3
  assert_error_line_partially_at_index -1 'hello'
}

should_fail__assert_error_line_partially_at_index__no_match() {
  echo 'Expected [assert_error_line_partially_at_index] failure.'
  dummy_function() {
    echo 'hello 1' >&2
    echo 'hello 2' >&2
    echo 'hello 3' >&2
  }
  run dummy_function
  assert_error_line_count 3
  assert_error_line_partially_at_index 2 'unrelated content'
}

test__assert_error_line_partially_at_index__empty_line_can_be_validated() {
  echo 'Expected [assert_error_line_partially_at_index] failure.'
  dummy_function() {
    echo '' >&2
  }
  run dummy_function
  assert_error_line_count 1
  assert_error_line_partially_at_index 1 ''
}

should_fail__assert_error_line_partially_at_index__empty_line_wont_get_ignored() {
  echo 'Expected [assert_error_line_partially_at_index] failure.'
  dummy_function() {
    echo '' >&2
  }
  run dummy_function
  assert_error_line_count 1
  assert_error_line_partially_at_index 1 'not empty line'
}

#==============================================================================
# MIXED CASES
#------------------------------------------------------------------------------
# Standard output and standard error output assertions can be used together.
#==============================================================================

test__mixed_case() {
  dummy_function() {
    echo 'output line 1'
    echo 'output line 2'
    echo 'error line 1' >&2
    echo 'output line 3'
    echo 'error line 2' >&2
    echo 'error line 3' >&2
    echo 'error line 4' >&2
  }
  run dummy_function
  assert_output
  assert_error
  assert_output_line_count 3
  assert_error_line_count 4
  assert_output_line_at_index 2 'output line 2'
  assert_error_line_at_index 4 'error line 4'
  assert_output_line_partially_at_index 3 'line 3'
  assert_error_line_partially_at_index 1 'line 1'
}

#==============================================================================
# WORD SPLITTING IS NOT A PROBLEM WITH THE RUN FUNCTION
#------------------------------------------------------------------------------
# Re-splitting should not occure when using the 'run' command to provide a
# testing context.
#==============================================================================

test__word_splitting_validation() {
  dummy_function() {
    echo "$#"
  }
  param_3='param 3'

  # If word splitting would occur inside the run function, it would report 6
  # parameters instead of the correct 3 params here.
  run dummy_function 'param 1' 'param 2' "$param_3"
  assert_output '3'
}
