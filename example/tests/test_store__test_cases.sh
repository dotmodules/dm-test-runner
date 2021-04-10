#==============================================================================
# STORE MANAGEMENT CASES
#==============================================================================

#==============================================================================
# The store system has to reliably store and retrieve any kind of textual
# input. It is doing it by encoding both the key and the value. In this way
# egzotic characters and multilite textual inputs are not an issue.
#==============================================================================

test__store__single_words_can_be_stored_and_retrieved() {
  key="key"
  value="value"

  dm_test__store__set "$key" "$value"
  result="$(dm_test__store__get "$key")"

  assert_equal "$value" "$result"
}

test__store__multi_word_keys_and_values_can_be_used() {
  key="my key"
  value="my value"

  dm_test__store__set "$key" "$value"
  result="$(dm_test__store__get "$key")"

  assert_equal "$value" "$result"
}

test__store__setting_the_key_again_overrides_old_value() {
  key="my key"
  old_value="old value"
  new_value="new value"

  dm_test__store__set "$key" "$old_value"
  dm_test__store__set "$key" "$new_value"
  result="$(dm_test__store__get "$key")"

  assert_equal "$new_value" "$result"
}

test__store__setting_the_key_multiple_times_wont_create_new_entry() {
  key="my key"

  # Initializing a new storage file to start clean.
  dm_test__store__init

  dm_test__store__set "$key" "one"
  dm_test__store__set "$key" "two"
  dm_test__store__set "$key" "three"
  dm_test__store__set "$key" "four"
  dm_test__store__set "$key" "five"
  dm_test__store__set "$key" "six"
  dm_test__store__set "$key" "seven"
  dm_test__store__set "$key" "eight"
  dm_test__store__set "$key" "nine"
  dm_test__store__set "$key" "ten"

  line_count="$(dm_tools__wc --lines < "$DM_TEST__STORE__RUNTIME__STORAGE_FILE")"

  assert_equal '1' "$line_count"
}

test__store__multiline_values_can_be_stored() {
  key="key"
  value="$( \
    dm_tools__echo 'line 1'; \
    dm_tools__echo 'line 2'; \
  )"

  dummy_test_function() {
    dm_test__store__get "$key"
  }

  dm_test__store__set "$key" "$value"

  run dummy_test_function

  assert_output_line_count 2
  assert_output_line_at_index 1 'line 1'
  assert_output_line_at_index 2 'line 2'
}

test__store__even_multiline_keys_can_be_used() {
  key="$( \
    dm_tools__echo 'key line 1'; \
    dm_tools__echo 'key line 2'; \
  )"
  value="$( \
    dm_tools__echo 'line 1'; \
    dm_tools__echo 'line 2'; \
  )"

  dummy_test_function() {
    dm_test__store__get "$key"
  }

  dm_test__store__set "$key" "$value"

  run dummy_test_function

  assert_output_line_count 2
  assert_output_line_at_index 1 'line 1'
  assert_output_line_at_index 2 'line 2'
}
