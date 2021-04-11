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

should_fail__assert_status() {
  dm_tools__echo 'Expected [assert_status] failure.'
  dummy_function() {
    return 3
  }
  run dummy_function
  assert_status 2
}

#==============================================================================
# ASSERT_OUTPUT
#------------------------------------------------------------------------------
# Asserts the whole captured output of the last function or command runned by
# the 'run' command.
#==============================================================================

test__assert_output() {
  dummy_function() {
    dm_tools__echo 'hello'
  }
  run dummy_function
  assert_output 'hello'
}

should_fail__assert_output__mismatch() {
  dm_tools__echo 'Expected [assert_output] failure.'
  dummy_function() {
    dm_tools__echo 'hello'
  }
  run dummy_function
  assert_output 'bye'
}

should_fail__assert_output__multiline_output_fails_assertion() {
  dm_tools__echo 'Expected [assert_output] failure.'
  dummy_function() {
    dm_tools__echo 'hello 1'
    dm_tools__echo 'hello 2'
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
    dm_tools__echo 'hello 1'
    dm_tools__echo 'hello 2'
    dm_tools__echo 'hello 3'
  }
  run dummy_function
  assert_output_line_count 3
}

should_fail__assert_output_line_count() {
  dm_tools__echo 'Expected [assert_output_line_count] failure.'
  dummy_function() {
    dm_tools__echo 'hello'
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
    dm_tools__echo 'hello 1'
    dm_tools__echo 'hello 2'
    dm_tools__echo 'hello 3'
  }
  run dummy_function
  assert_output_line_at_index 2 'hello 2'
}

should_fail__assert_output_line_at_index__invalid_index__case_1() {
  dm_tools__echo 'Expected [assert_output_line_at_index] failure.'
  dummy_function() {
    dm_tools__echo 'hello'
    dm_tools__echo 'hello'
    dm_tools__echo 'hello'
  }
  run dummy_function
  assert_output_line_at_index 42 'invalid index'
}

should_fail__assert_output_line_at_index__invalid_index__case_2() {
  dm_tools__echo 'Expected [assert_output_line_at_index] failure.'
  dummy_function() {
    dm_tools__echo 'hello'
    dm_tools__echo 'hello'
    dm_tools__echo 'hello'
  }
  run dummy_function
  assert_output_line_at_index 0 'invalid index'
}

should_fail__assert_output_line_at_index__invalid_index__case_3() {
  dm_tools__echo 'Expected [assert_output_line_at_index] failure.'
  dummy_function() {
    dm_tools__echo 'hello'
    dm_tools__echo 'hello'
    dm_tools__echo 'hello'
  }
  run dummy_function
  assert_output_line_at_index -1 'invalid index'
}

should_fail__assert_output_line_at_index__no_match() {
  dm_tools__echo 'Expected [assert_output_line_at_index] failure.'
  dummy_function() {
    dm_tools__echo 'hello 1'
    dm_tools__echo 'hello 2'
    dm_tools__echo 'hello 3'
  }
  run dummy_function
  # This assertion matches the whole line.
  assert_output_line_at_index 2 'hello'
}

test__assert_output_line_line_at_index__empty_line_can_be_validated() {
  dummy_function() {
    dm_tools__echo ''
  }
  run dummy_function
  assert_output_line_at_index 1 ''
}

should_fail__assert_output_line_at_index__empty_line_wont_get_ignored() {
  dummy_function() {
    dm_tools__echo ''
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
    dm_tools__echo 'hello 1'
    dm_tools__echo 'hello 2'
    dm_tools__echo 'hello 3'
  }
  run dummy_function
  assert_output_line_partially_at_index 2 'hello'
}

should_fail__assert_output_line_partially_at_index__invalid_index__case_1() {
  dm_tools__echo 'Expected [assert_output_line_partially_at_index] failure.'
  dummy_function() {
    dm_tools__echo 'hello'
    dm_tools__echo 'hello'
    dm_tools__echo 'hello'
  }
  run dummy_function
  assert_output_line_partially_at_index 42 'hello'
}

should_fail__assert_output_line_partially_at_index__invalid_index__case_2() {
  dm_tools__echo 'Expected [assert_output_line_partially_at_index] failure.'
  dummy_function() {
    dm_tools__echo 'hello'
    dm_tools__echo 'hello'
    dm_tools__echo 'hello'
  }
  run dummy_function
  assert_output_line_partially_at_index 0 'hello'
}

should_fail__assert_output_line_partially_at_index__invalid_index__case_3() {
  dm_tools__echo 'Expected [assert_output_line_partially_at_index] failure.'
  dummy_function() {
    dm_tools__echo 'hello'
    dm_tools__echo 'hello'
    dm_tools__echo 'hello'
  }
  run dummy_function
  assert_output_line_partially_at_index -1 'hello'
}

should_fail__assert_output_line_partially_at_index__no_match() {
  dm_tools__echo 'Expected [assert_output_line_partially_at_index] failure.'
  dummy_function() {
    dm_tools__echo 'hello 1'
    dm_tools__echo 'hello 2'
    dm_tools__echo 'hello 3'
  }
  run dummy_function
  assert_output_line_partially_at_index 2 'unrelated content'
}

test__assert_output_line_partially_at_index__empty_line_can_be_validated() {
  dummy_function() {
    dm_tools__echo ''
  }
  run dummy_function
  assert_output_line_partially_at_index 1 ''
}

should_fail__assert_output_line_partially_at_index__empty_line_wont_get_ignored() {
  dummy_function() {
    dm_tools__echo ''
  }
  run dummy_function
  assert_output_line_partially_at_index 1 'not empty line'
}

#==============================================================================
# ASSERT_ERROR
#------------------------------------------------------------------------------
# Asserts the whole captured error output of the last function or command
# runned by the 'run' command.
#==============================================================================

test__assert_error() {
  dummy_function() {
    dm_tools__echo 'hello' >&2
  }
  run dummy_function
  assert_error 'hello'
}

should_fail__assert_error__mismatch() {
  dm_tools__echo 'Expected [assert_error] failure.'
  dummy_function() {
    dm_tools__echo 'hello' >&2
  }
  run dummy_function
  assert_error 'bye'
}

should_fail__assert_error__multiline_output_fails_assertion() {
  dm_tools__echo 'Expected [assert_error] failure.'
  dummy_function() {
    dm_tools__echo 'hello 1' >&2
    dm_tools__echo 'hello 2' >&2
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
    dm_tools__echo 'hello'
  }
  run dummy_function
  assert_no_error
}

should_fail__assert_no_error() {
  dummy_function() {
    dm_tools__echo 'error line 1' >&2
    dm_tools__echo 'error line 2' >&2
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
    dm_tools__echo 'hello 1' >&2
    dm_tools__echo 'hello 2' >&2
    dm_tools__echo 'hello 3' >&2
  }
  run dummy_function
  assert_error_line_count 3
}

should_fail__assert_error_line_count() {
  dm_tools__echo 'Expected [assert_error_line_count] failure.'
  dummy_function() {
    dm_tools__echo 'hello' >&2
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
    dm_tools__echo 'hello 1' >&2
    dm_tools__echo 'hello 2' >&2
    dm_tools__echo 'hello 3' >&2
  }
  run dummy_function
  assert_error_line_count 3
  assert_error_line_at_index 2 'hello 2'
}

should_fail__assert_error_line_at_index__invalid_index__case_1() {
  dm_tools__echo 'Expected [assert_error_line_at_index] failure.'
  dummy_function() {
    dm_tools__echo 'hello' >&2
    dm_tools__echo 'hello' >&2
    dm_tools__echo 'hello' >&2
  }
  run dummy_function
  assert_error_line_count 3
  assert_error_line_at_index 42 'invalid index'
}

should_fail__assert_error_line_at_index__invalid_index__case_2() {
  dm_tools__echo 'Expected [assert_error_line_at_index] failure.'
  dummy_function() {
    dm_tools__echo 'hello' >&2
    dm_tools__echo 'hello' >&2
    dm_tools__echo 'hello' >&2
  }
  run dummy_function
  assert_error_line_count 3
  assert_error_line_at_index 0 'invalid index'
}

should_fail__assert_error_line_at_index__invalid_index__case_3() {
  dm_tools__echo 'Expected [assert_error_line_at_index] failure.'
  dummy_function() {
    dm_tools__echo 'hello' >&2
    dm_tools__echo 'hello' >&2
    dm_tools__echo 'hello' >&2
  }
  run dummy_function
  assert_error_line_count 3
  assert_error_line_at_index -1 'invalid index'
}

should_fail__assert_error_line_at_index__no_match() {
  dm_tools__echo 'Expected [assert_error_line_at_index] failure.'
  dummy_function() {
    dm_tools__echo 'hello 1' >&2
    dm_tools__echo 'hello 2' >&2
    dm_tools__echo 'hello 3' >&2
  }
  run dummy_function
  assert_error_line_count 3
  # This assertion matches the whole line.
  assert_error_line_at_index 2 'hello'
}

test__assert_output_line_line_at_index__empty_line_can_be_validated() {
  dummy_function() {
    dm_tools__echo '' >&2
  }
  run dummy_function
  assert_error_line_count 1
  assert_error_line_at_index 1 ''
}

should_fail__assert_error_line_at_index__empty_line_wont_get_ignored() {
  dummy_function() {
    dm_tools__echo '' >&2
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
    dm_tools__echo 'hello 1' >&2
    dm_tools__echo 'hello 2' >&2
    dm_tools__echo 'hello 3' >&2
  }
  run dummy_function
  assert_error_line_count 3
  assert_error_line_partially_at_index 2 'hello'
}

should_fail__assert_error_line_partially_at_index__invalid_index__case_1() {
  dm_tools__echo 'Expected [assert_error_line_partially_at_index] failure.'
  dummy_function() {
    dm_tools__echo 'hello' >&2
    dm_tools__echo 'hello' >&2
    dm_tools__echo 'hello' >&2
  }
  run dummy_function
  assert_error_line_count 3
  assert_error_line_partially_at_index 42 'hello'
}

should_fail__assert_error_line_partially_at_index__invalid_index__case_2() {
  dm_tools__echo 'Expected [assert_error_line_partially_at_index] failure.'
  dummy_function() {
    dm_tools__echo 'hello' >&2
    dm_tools__echo 'hello' >&2
    dm_tools__echo 'hello' >&2
  }
  run dummy_function
  assert_error_line_count 3
  assert_error_line_partially_at_index 0 'hello'
}

should_fail__assert_error_line_partially_at_index__invalid_index__case_3() {
  dm_tools__echo 'Expected [assert_error_line_partially_at_index] failure.'
  dummy_function() {
    dm_tools__echo 'hello' >&2
    dm_tools__echo 'hello' >&2
    dm_tools__echo 'hello' >&2
  }
  run dummy_function
  assert_error_line_count 3
  assert_error_line_partially_at_index -1 'hello'
}

should_fail__assert_error_line_partially_at_index__no_match() {
  dm_tools__echo 'Expected [assert_error_line_partially_at_index] failure.'
  dummy_function() {
    dm_tools__echo 'hello 1' >&2
    dm_tools__echo 'hello 2' >&2
    dm_tools__echo 'hello 3' >&2
  }
  run dummy_function
  assert_error_line_count 3
  assert_error_line_partially_at_index 2 'unrelated content'
}

test__assert_error_line_partially_at_index__empty_line_can_be_validated() {
  dummy_function() {
    dm_tools__echo '' >&2
  }
  run dummy_function
  assert_error_line_count 1
  assert_error_line_partially_at_index 1 ''
}

should_fail__assert_error_line_partially_at_index__empty_line_wont_get_ignored() {
  dummy_function() {
    dm_tools__echo '' >&2
  }
  run dummy_function
  assert_error_line_count 1
  assert_error_line_partially_at_index 1 'not empty line'
}

#==============================================================================
# WORD SPLITTING IS NOT A PROBLEM WITH THE RUN FUNCTION
#------------------------------------------------------------------------------
# Re-splitting should not occure when using the 'run' command to provide a
# testing context.
#==============================================================================

test__word_splitting_validation() {
  dummy_function() {
    dm_tools__echo "$#"
  }
  param_3='param 3'

  # If word splitting would occur inside the run function, it would report 6
  # parameters instead of the correct 3 params here.
  run dummy_function 'param 1' 'param 2' "$param_3"
  assert_output '3'
}
