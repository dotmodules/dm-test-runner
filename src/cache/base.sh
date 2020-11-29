#==============================================================================
#    _____           _
#   / ____|         | |
#  | |     __ _  ___| |__   ___
#  | |    / _` |/ __| '_ \ / _ \
#  | |___| (_| | (__| | | |  __/
#   \_____\__,_|\___|_| |_|\___|
#
#==============================================================================

#==============================================================================
#   ____                    ____           _            ____  _
#  | __ )  __ _ ___  ___   / ___|__ _  ___| |__   ___  |  _ \(_)_ __
#  |  _ \ / _` / __|/ _ \ | |   / _` |/ __| '_ \ / _ \ | | | | | '__|
#  | |_) | (_| \__ \  __/ | |__| (_| | (__| | | |  __/ | |_| | | |
#  |____/ \__,_|___/\___|  \____\__,_|\___|_| |_|\___| |____/|_|_|
#
#==============================================================================
# BASE CACHE DIRECTORY
#==============================================================================

#==============================================================================
# The cache directory located in the /tmp directory is created on startup.
# Every generated files will be located in there. After the test suite
# finished, the cache directory will be removed. Therefore sub-cache systems
# don't need to worry about cleaning up after themselves.
#==============================================================================

# Prefix that every cache directory will have. This uniform prefix would make
# it easy to recover from an unexpected event when the cache cleanup couldn't
# be executed, by deleting all temporary directories with this prefix.
DM_TEST__CACHE__DIRECTORY_PREFIX="dm_test_cache"

# Cache directory prefix extended with the necessary `mktemp` compatible
# template. This variable will be used to create a unique cache directory each
# time.
# Using a subshell here to prevent the long line.
# shellcheck disable=2116
DM_TEST__CACHE__MKTEMP_TEMPLATE="$( \
  echo "${DM_TEST__CACHE__DIRECTORY_PREFIX}.XXXXXXXXXX" \
)"

# Global variable that holds the path to the currently operational cache
# directory.
DM_TEST__CACHE__PATH="__INVALID__"

#==============================================================================
# Inner function that will create the cache directory and sets the global
# variable for it.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__MKTEMP_TEMPLATE
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__CACHE__PATH
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   mktemp
#==============================================================================
_dm_test__cache__create_base_cache_directory() {
  DM_TEST__CACHE__PATH="$( \
    mktemp --directory -t "$DM_TEST__CACHE__MKTEMP_TEMPLATE" \
  )"

  dm_test__debug \
    '_dm_test__cache__create_base_cache_directory' \
    "base cache directory created: '${DM_TEST__CACHE__PATH}'"
}

#==============================================================================
# Cleans up existing leftover cache direcotries. It will also delete leftover
# cache directories as well. Cache directories are created with `mktemp` so the
# cleanup has to be done in the `/tmp` directory.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__DIRECTORY_PREFIX
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
#   0 - Other status is not expected.
# Tools:
#   find xargs rm
#==============================================================================
dm_test__cache__cleanup() {
  find /tmp \
    -type d \
    -name "${DM_TEST__CACHE__DIRECTORY_PREFIX}*" \
    -print0 2>/dev/null | \
  xargs --null --replace='{}' \
    rm --recursive --force '{}'

  dm_test__debug \
    'dm_test__cache__cleanup' \
    'cache cleaned up'
}

#==============================================================================
#  _____                                                 _____ _ _
# |_   _|__ _ __ ___  _ __   ___  _ __ __ _ _ __ _   _  |  ___(_) | ___  ___
#   | |/ _ \ '_ ` _ \| '_ \ / _ \| '__/ _` | '__| | | | | |_  | | |/ _ \/ __|
#   | |  __/ | | | | | |_) | (_) | | | (_| | |  | |_| | |  _| | | |  __/\__ \
#   |_|\___|_| |_| |_| .__/ \___/|_|  \__,_|_|   \__, | |_|   |_|_|\___||___/
#                    |_|                         |___/
#==============================================================================
# TEMPORARY FILES
#==============================================================================

#==============================================================================
# The cache system provides a way to create temporary files that can be used
# during the test execution. These temporary files are created inside a
# seprated directory. The files are generated with a precise timestamp postfix,
# to prevent collision between the generated file names.
#==============================================================================

# Variable that holds the name of the temporary files directory. This variable
# is not intended for accessing the directory.
DM_TEST__CACHE__TEMP_FILES_PATH_NAME="temp_files"

# Variable thar holds the runtime path of the temporary files directory. This
# variable should be used for writing or reading purposes.
DM_TEST__CACHE__TEMP_FILES_PATH="__INVALID__"

#==============================================================================
# Inner function to initialize the directory for the temporary files.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__PATH
#   DM_TEST__CACHE__TEMP_FILES_PATH_NAME
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__CACHE__TEMP_FILES_PATH
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   mkdir echo
#==============================================================================
_dm_test__cache__init__temp_files_base_directory() {
  # Using a subshell here to prevent the long line.
  # shellcheck disable=2116
  DM_TEST__CACHE__TEMP_FILES_PATH="$( \
    echo "${DM_TEST__CACHE__PATH}/${DM_TEST__CACHE__TEMP_FILES_PATH_NAME}" \
  )"
  mkdir --parents "$DM_TEST__CACHE__TEMP_FILES_PATH"

  dm_test__debug \
    '_dm_test__cache__init__temp_files_base_directory' \
    "temp files base directory created: '${DM_TEST__CACHE__TEMP_FILES_PATH}'"
}

#==============================================================================
# Creates a temporary file path in the cache directory and returns its path.
# Note: only a filepath will be created, the caller is responsible for creating
# the file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__RUNTIME__CACHE__TEMP_FILE_PATH
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
# - Temporary file's path.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   echo
#==============================================================================
dm_test__cache__create_temp_file() {
  ___postfix="$(_dm_test__cache__generate_postfix)"
  ___file="${DM_TEST__CACHE__TEMP_FILES_PATH}/${___postfix}"
  echo "$___file"

  dm_test__debug \
    'dm_test__cache__create_temp_file' \
    "temp file created: '${___file}'"
}

#==============================================================================
#  _____                                                 ____  _
# |_   _|__ _ __ ___  _ __   ___  _ __ __ _ _ __ _   _  |  _ \(_)_ __ ___
#   | |/ _ \ '_ ` _ \| '_ \ / _ \| '__/ _` | '__| | | | | | | | | '__/ __|
#   | |  __/ | | | | | |_) | (_) | | | (_| | |  | |_| | | |_| | | |  \__ \
#   |_|\___|_| |_| |_| .__/ \___/|_|  \__,_|_|   \__, | |____/|_|_|  |___/
#                    |_|                         |___/
#==============================================================================
# TEMPORARY DIRECTORIES
#==============================================================================

#==============================================================================
# The cache system also provides a way to create temporary directories that can
# be used during the test execution. These temporary directories are created
# inside a seprated directory. The directories are generated with a precise
# timestamp postfix, so collision between the names are very unlikely.
#==============================================================================

# Variable that holds the name of the temporary directories directory. This
# variable is not intended for accessing the directory.
DM_TEST__CACHE__TEMP_DIRS_PATH_NAME="temp_directories"

# Variable thar holds the runtime path of the temporary direcotories directory.
# This variable should be used for writing or reading purposes.
DM_TEST__CACHE__TEMP_DIRS_PATH="__INVALID__"

#==============================================================================
# Inner function to initialize the directory for the temporary directories.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__PATH
#   DM_TEST__CACHE__TEMP_DIRS_PATH_NAME
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__CACHE__TEMP_DIRS_PATH
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   mkdir echo
#==============================================================================
_dm_test__cache__init__temp_directories_base_directory() {
  # Using a subshell here to prevent the long line.
  # shellcheck disable=2116
  DM_TEST__CACHE__TEMP_DIRS_PATH="$( \
    echo "${DM_TEST__CACHE__PATH}/${DM_TEST__CACHE__TEMP_DIRS_PATH_NAME}" \
  )"
  mkdir --parents "$DM_TEST__CACHE__TEMP_DIRS_PATH"

  dm_test__debug \
    '_dm_test__cache__init__temp_directories_base_directory' \
    "temporary directories directory created: '${DM_TEST__CACHE__TEMP_DIRS_PATH}'"
}

#==============================================================================
# Creates a temporary directory in the cache directory and returns its path.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__TEMP_DIRS_PATH
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
# - Temporary directory's path.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   mkdir echo
#==============================================================================
dm_test__cache__create_temp_directory() {
  ___postfix="$(_dm_test__cache__generate_postfix)"
  ___dir="${DM_TEST__CACHE__TEMP_DIRS_PATH}/${___postfix}.d"
  mkdir --parents "$___dir"
  echo "$___dir"

  dm_test__debug \
    'dm_test__cache__create_temp_directory' \
    "temporary directory created: '${___dir}'"
}

#==============================================================================
#   ___       _ _   _       _ _          _   _
#  |_ _|_ __ (_) |_(_) __ _| (_)______ _| |_(_) ___  _ __
#   | || '_ \| | __| |/ _` | | |_  / _` | __| |/ _ \| '_ \
#   | || | | | | |_| | (_| | | |/ / (_| | |_| | (_) | | | |
#  |___|_| |_|_|\__|_|\__,_|_|_/___\__,_|\__|_|\___/|_| |_|
#
#==============================================================================
# INITIALIZATION
#==============================================================================

#==============================================================================
# Function that initializes the cache system. It clears up the leftover cache
# directories and creates a fresh one.
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
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   None
#==============================================================================
dm_test__cache__init() {
  dm_test__debug \
    'dm_test__cache__init' \
    'initializing cache system..'

  dm_test__cache__cleanup

  # Base cache system initialization.
  _dm_test__cache__create_base_cache_directory
  _dm_test__cache__init__temp_files_base_directory
  _dm_test__cache__init__temp_directories_base_directory

  # Sub-cache system initialization.
  _dm_test__cache__global_count__init
  _dm_test__cache__global_errors__init
  _dm_test__cache__global_failures__init
  _dm_test__cache__test_result__init

  dm_test__debug \
    'dm_test__cache__init' \
    'cache system initialized'
}

#==============================================================================
#   _   _ _   _ _
#  | | | | |_(_) |___
#  | | | | __| | / __|
#  | |_| | |_| | \__ \
#   \___/ \__|_|_|___/
#
#==============================================================================
# UTILS
#==============================================================================

#==============================================================================
# Generates the 'should-be-unique' postfix for the temporary files and
# directories.
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
#   Unique-ish postfix.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
# Tools:
#   date
#==============================================================================
_dm_test__cache__generate_postfix() {
  ___postfix="$(date +'%s%N')"
  echo "$___postfix"

  dm_test__debug \
    '_dm_test__cache__generate_postfix' \
    "postfix generated: '${___postfix}'"
}
