#==============================================================================
#    _____ _
#   / ____| |
#  | (___ | |_ ___  _ __ ___
#   \___ \| __/ _ \| '__/ _ \
#   ____) | || (_) | | |  __/
#  |_____/ \__\___/|_|  \___|
#
#==============================================================================
# STORE
#==============================================================================

#==============================================================================
# The store system provides a way to globally store key-value pairs. The main
# use case for this system is to save spy variables inside of mocked out
# functions to be later validated by an assertion. Generally you cannot assign
# a variable in a mocked out function as it most likely will be executed in a
# subshell, and the test case level shell cannot access it.
#
# The store system is basically a global test suite level temporary file that
# stores the key value pairs. A value is available until the same key gets
# written to it again. This is not an issue, since getting the value is usually
# happens right after the setting.
#
# Internally the store system will encode both the key and the value to be able
# to store multi-line values in any character-set.
#==============================================================================

# Separator string between the key and the value.
DM_TEST__STORE__CONSTANT__KEY_VALUE_SEPARATOR='::'

# Global store system storage file.
DM_TEST__STORE__RUNTIME__STORAGE_FILE='__INVALID__'

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
# Initializes the store system by creating a new temporary file to be used as a
# store file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__STORE__RUNTIME__STORAGE_FILE
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__STORE__RUNTIME__STORAGE_FILE
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm_test__store__init() {
  dm_test__debug 'dm_test__store__init' \
    'initializing store system..'

  DM_TEST__STORE__RUNTIME__STORAGE_FILE="$(dm_test__cache__create_temp_file)"

  dm_test__debug_list 'dm_test__store__init' \
    "store system initialized with storage file path:" \
    "$DM_TEST__STORE__RUNTIME__STORAGE_FILE"
}

#==============================================================================
# Writes a value for a key to the store file.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] key - Key for the given value to be stored in.
#   [2] value - Value that needs to be stored for the given key.
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
dm_test__store__set() {
  ___key="$1"
  ___value="$2"

  dm_test__debug_list 'dm_test__store__set' \
    "storing value for key '${___key}':" "$___value"

  _dm_test__store__log_store_content 'store content before insertion'

  if _dm_test__store__key_exists "$___key"
  then
    _dm_test__store__replace "$___key" "$___value"
  else
    _dm_test__store__insert "$___key" "$___value"
  fi

  _dm_test__store__log_store_content 'store content after insertion'
}

#==============================================================================
# Gets the value for the given key.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] key - Key for the given value to be retrieved with.
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
#   0 - Key exists, value returned.
#   1 - Key does not exist.
#==============================================================================
dm_test__store__get() {
  ___key="$1"

  dm_test__debug 'dm_test__store__get' "reading value for key '${___key}'"

  if ___value="$(_dm_test__store__get_value_for_key "$___key")"
  then
    dm_tools__echo "$___value"
    return 0
  else
    return 1
  fi
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
# Logs out the content of the store file if debug is enabled.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__STORE__RUNTIME__STORAGE_FILE
# Arguments:
#   [1] message - Debug message that should be used for the log message.
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
_dm_test__store__log_store_content() {
  ___message="$1"
  ___store_file="$DM_TEST__STORE__RUNTIME__STORAGE_FILE"

  if dm_test__config__debug_is_enabled
  then
    if [ -s "$___store_file" ]
    then
      dm_test__debug_list '_dm_test__store__log_store_content' \
        "$___message" \
        "$(dm_tools__cat "$___store_file")"
    else
      dm_test__debug '_dm_test__store__log_store_content' 'store file is empty'
    fi
  fi
}

#==============================================================================
# Checks if the given key exists in the storage file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__STORE__CONSTANT__KEY_VALUE_SEPARATOR
#   DM_TEST__STORE__RUNTIME__STORAGE_FILE
# Arguments:
#   [1] key - The key that has to be checked.
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
#   0 - Key found.
#   1 - Key not fount.
#==============================================================================
_dm_test__store__key_exists() {
  ___key="$1"
  ___separator="$DM_TEST__STORE__CONSTANT__KEY_VALUE_SEPARATOR"
  ___store_file="$DM_TEST__STORE__RUNTIME__STORAGE_FILE"

  ___encoded_key="$(_dm_test__store__encode "$___key")"

  ___pattern="^${___encoded_key}${___separator}"

  if dm_tools__grep --silent "$___pattern" "$___store_file"
  then
    dm_test__debug '_dm_test__store__key_exists' 'key found in the store'
    return 0
  else
    dm_test__debug '_dm_test__store__key_exists' \
      'key does not exist in the store'
    return 1
  fi
}

#==============================================================================
# Gets the value from the store for a key is exists.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__STORE__CONSTANT__KEY_VALUE_SEPARATOR
#   DM_TEST__STORE__RUNTIME__STORAGE_FILE
# Arguments:
#   [1] key - The key for the value that should be returned.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Value if exists.
# STDERR:
#   None
# Status:
#   0 - Key found, value returned.
#   1 - Key not fount.
#   2 - Unexpected error, it should be reported..
#==============================================================================
_dm_test__store__get_value_for_key() {
  ___key="$1"
  ___separator="$DM_TEST__STORE__CONSTANT__KEY_VALUE_SEPARATOR"
  ___store_file="$DM_TEST__STORE__RUNTIME__STORAGE_FILE"

  ___encoded_key="$(_dm_test__store__encode "$___key")"

  ___pattern="^${___encoded_key}${___separator}"

  if ___result="$(dm_tools__grep "$___pattern" "$___store_file")"
  then
    dm_test__debug_list '_dm_test__store__get_value_for_key' \
      'key found in the store:' "$___result"

    # This is a very unlikely case, but should be prepared for it..
    ___line_count="$(dm_tools__echo "$___result" | dm_tools__wc --lines)"
    if [ "$___line_count" -ne '1' ]
    then
      dm_test__debug_list '_dm_test__store__get_value_for_key' \
        'unexpected error! more then one matching line found' \
        "$___result"
      return 2
    fi

    ___pattern="^${___encoded_key}${___separator}"
    # Want to remain fully POSIX compliante, variable expansion is not required
    # by POSIX. Read more: https://stackoverflow.com/a/21913014/1565331
    # shellcheck disable=SC2001
    ___encoded_value="$( \
      dm_tools__echo "$___result" | \
      dm_tools__sed --expression "s/${___pattern}//g" \
    )"

    dm_test__debug_list '_dm_test__store__get_value_for_key' \
      'value separated:' "$___encoded_value"

    ___value="$(_dm_test__store__decode "$___encoded_value")"

    dm_test__debug_list '_dm_test__store__get_value_for_key' \
      'value decoded:' "$___value"

    dm_tools__echo "$___value"
    return 0

  else
    dm_test__debug '_dm_test__store__get_value_for_key' \
      'key does not exist in the store, returning (1)..'
    return 1
  fi
}

#==============================================================================
# Inserts the given key-value pair to the store by appending it to the store
# file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__STORE__CONSTANT__KEY_VALUE_SEPARATOR
#   DM_TEST__STORE__RUNTIME__STORAGE_FILE
# Arguments:
#   [1] key - Key for the given value to be stored in.
#   [2] value - Value that needs to be stored for the given key.
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
_dm_test__store__insert() {
  ___key="$1"
  ___value="$2"
  ___separator="$DM_TEST__STORE__CONSTANT__KEY_VALUE_SEPARATOR"
  ___store_file="$DM_TEST__STORE__RUNTIME__STORAGE_FILE"

  dm_test__debug '_dm_test__store__insert' \
    'inserting key-value pair to the store file..'

  ___encoded_key="$(_dm_test__store__encode "$___key")"
  ___encoded_value="$(_dm_test__store__encode "$___value")"

  ___line="${___encoded_key}${___separator}${___encoded_value}"
  dm_tools__echo "$___line" >> "$___store_file"

  dm_test__debug '_dm_test__store__insert' \
    'key-value pair has been inserted to the store file'
}

#==============================================================================
# Replaces an existing key with new a key-value pair to the store.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__STORE__CONSTANT__KEY_VALUE_SEPARATOR
#   DM_TEST__STORE__RUNTIME__STORAGE_FILE
# Arguments:
#   [1] key - Key for the given value to be stored in.
#   [2] value - Value that needs to be stored for the given key.
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
_dm_test__store__replace() {
  ___key="$1"
  ___value="$2"
  ___separator="$DM_TEST__STORE__CONSTANT__KEY_VALUE_SEPARATOR"
  ___store_file="$DM_TEST__STORE__RUNTIME__STORAGE_FILE"

  dm_test__debug '_dm_test__store__replace' \
    'replacing existing key with new value..'

  ___encoded_key="$(_dm_test__store__encode "$___key")"
  ___encoded_value="$(_dm_test__store__encode "$___value")"

  ___pattern="^${___encoded_key}${___separator}.*"
  ___new="${___encoded_key}${___separator}${___encoded_value}"

  dm_tools__sed \
    --in-place '' \
    --expression "s/${___pattern}/${___new}/g" \
    "$___store_file"

  dm_test__debug '_dm_test__store__replace' \
    'key value has been replaced'
}

#==============================================================================
# Encodes the given input to be able to store in a failsafe way by generating a
# single line of hexadecimal dump. In this way any multiline text can be stored
# in a single line in the storage file.
# Example: 'hello world\n' -> '68656c6c6f20776f726c640a'
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] value - Value that needs to be encoded.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Encoded input value.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_test__store__encode() {
  ___value="$1"

  dm_test__debug_list '_dm_test__store__encode' \
    'encoding input value:' "$___value"

  ___encoded="$( \
    dm_tools__echo "$___value" | \
    dm_tools__xxd --plain | \
    dm_tools__tr --delete '\n' \
  )"

  dm_test__debug_list '_dm_test__store__encode' \
    'input value encoded:' "$___encoded"

  dm_tools__echo "$___encoded"
}

#==============================================================================
# Decodes the previously decoded text.
# Example: '68656c6c6f20776f726c640a' -> 'hello world\n'
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] encoded_value - Encoded value that needs to be decoded.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Decoded value.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_test__store__decode() {
  ___encoded_value="$1"

  dm_test__debug_list '_dm_test__store__decode' \
    'decoding input value:' "$___encoded_value"

  ___value="$( \
    dm_tools__echo "$___encoded_value" | \
    dm_tools__xxd --revert --plain \
  )"

  dm_test__debug_list '_dm_test__store__decode' \
    'decoded value:' "$___value"

  dm_tools__echo "$___value"
}
