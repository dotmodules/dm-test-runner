#!/bin/sh
#==============================================================================
#    _____           _
#   / ____|         | |
#  | |     __ _  ___| |__   ___
#  | |    / _` |/ __| '_ \ / _ \
#  | |___| (_| | (__| | | |  __/
#   \_____\__,_|\___|_| |_|\___|
#
#==============================================================================
# CACHE
#==============================================================================

#==============================================================================
# The cache system provides a convenient way to create temporary directories
# and files in a way. These files and directories are created inside a separate
# cache directory that will be deleted after each run.
#==============================================================================

#==============================================================================
#  ___       _ _   _       _ _          _   _
# |_ _|_ __ (_) |_(_) __ _| (_)______ _| |_(_) ___  _ __
#  | || '_ \| | __| |/ _` | | |_  / _` | __| |/ _ \| '_ \
#  | || | | | | |_| | (_| | | |/ / (_| | |_| | (_) | | | |
# |___|_| |_|_|\__|_|\__,_|_|_/___\__,_|\__|_|\___/|_| |_|
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
#==============================================================================
posix_test__cache__init() {
  posix_test__debug 'posix_test__cache__init' 'initializing cache system..'

  # Initializing and normalizing the cache parent directory.
  _posix_test__cache__normalize_cache_parent_directory

  # At this point the cache parent directory has been finalized, we can try to
  # clean up all the leftover cache directories.
  posix_test__cache__cleanup

  # Creating the new cache directory..
  _posix_test__cache__create_base_cache_directory
  # At this point the current cache directory has been created, so arming the
  # trap system to clean it up on exit or interrupt signals.
  posix_test__arm_trap_system

  # Initializing the internal cache structure..
  _posix_test__cache__init__temp_files_base_directory
  _posix_test__cache__init__temp_directories_base_directory

  # Sub-cache system initialization.
  _posix_test__cache__global_count__init
  _posix_test__cache__global_errors__init
  _posix_test__cache__global_failures__init
  _posix_test__cache__test_result__init

  posix_test__debug 'posix_test__cache__init' 'cache system initialized'
}

#==============================================================================
#  ____                    ____           _            ____  _
# | __ )  __ _ ___  ___   / ___|__ _  ___| |__   ___  |  _ \(_)_ __
# |  _ \ / _` / __|/ _ \ | |   / _` |/ __| '_ \ / _ \ | | | | | '__|
# | |_) | (_| \__ \  __/ | |__| (_| | (__| | | |  __/ | |_| | | |
# |____/ \__,_|___/\___|  \____\__,_|\___|_| |_|\___| |____/|_|_|
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
POSIX_TEST__CACHE__CONFIG__DIRECTORY_PREFIX='posix_test_cache'

# Cache directory prefix extended with the necessary `mktemp` compatible
# template. This variable will be used to create a unique cache directory each
# time.
POSIX_TEST__CACHE__CONFIG__MKTEMP_TEMPLATE=\
"${POSIX_TEST__CACHE__CONFIG__DIRECTORY_PREFIX}.XXXXXXXXXX"

# Global variable that hold the normalized cache parent directory. Normalizing
# the cache parent directory should be the first step during cache system
# initialization.
POSIX_TEST__CACHE__RUNTIME__NORMALIZED_CACHE_PARENT_DIRECTORY='__INVALID__'

# Global variable that holds the path to the currently operational cache
# directory.
POSIX_TEST__CACHE__RUNTIME__CACHE_PATH='__INVALID__'

#==============================================================================
# Function that will normalize and validate the cache parent directory received
# from the configuration.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CONFIG__OPTIONAL__CACHE_PARENT_DIRECTORY
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   POSIX_TEST__CACHE__RUNTIME__NORMALIZED_CACHE_PARENT_DIRECTORY
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_posix_test__cache__normalize_cache_parent_directory() {
  ___raw_parent="$POSIX_TEST__CONFIG__OPTIONAL__CACHE_PARENT_DIRECTORY"
  ___parent="$(posix_adapter__realpath --no-symlinks "$___raw_parent")"

  posix_test__debug '_posix_test__cache__normalize_cache_parent_directory' \
    "normalizing raw cache parent directory: '${___raw_parent}'"

  # Check if the parent directory exists or not. If not, create it!
  if [ -d "$___parent" ]
  then
    :
  else
    if ___output="$(posix_adapter__mkdir --parents "$___parent" 2>&1)"
    then
      :
    else
      posix_test__report_error_and_exit \
        'Cache system initialization failed!' \
        "Cache parent directory '${___parent}' cannot be created!" \
        "$___output"
    fi
  fi

  # Check for write permission in hte parent directory.
  if [ -w "$___parent" ]
  then
    :
  else
    posix_test__report_error_and_exit \
      'Cache system initialization failed!' \
      'Cache parent directory exists but you have no write permission!' \
      "unable to write into '${___parent}': Permission denied"
  fi

  POSIX_TEST__CACHE__RUNTIME__NORMALIZED_CACHE_PARENT_DIRECTORY="$___parent"

  posix_test__debug '_posix_test__cache__normalize_cache_parent_directory' \
    "raw cache parent directory normalized: '${___parent}'"
}

#==============================================================================
# Inner function that will create the cache directory and sets the value in the
# corresponding global variable.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CACHE__RUNTIME__NORMALIZED_CACHE_PARENT_DIRECTORY
#   POSIX_TEST__CACHE__CONFIG__MKTEMP_TEMPLATE
#   POSIX_TEST__CACHE__RUNTIME__CACHE_PATH
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   POSIX_TEST__CACHE__RUNTIME__CACHE_PATH
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_posix_test__cache__create_base_cache_directory() {
  if ___mktemp_output="$( \
    posix_adapter__mktemp \
      --directory \
      --tmpdir "$POSIX_TEST__CACHE__RUNTIME__NORMALIZED_CACHE_PARENT_DIRECTORY" \
      "$POSIX_TEST__CACHE__CONFIG__MKTEMP_TEMPLATE" \
      2>&1 \
  )"
  then
    POSIX_TEST__CACHE__RUNTIME__CACHE_PATH="$___mktemp_output"
  else
    posix_test__report_error_and_exit \
      'Cache system initialization failed!' \
      'Cache base directory cannot be created!' \
      "$___mktemp_output"
  fi

  posix_test__debug '_posix_test__cache__create_base_cache_directory' \
    "base cache directory created: '${POSIX_TEST__CACHE__RUNTIME__CACHE_PATH}'"
}

#==============================================================================
# Cleans up all existing cache directories that matche to the predefined prefix
# in the cache parent directory..
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
#==============================================================================
posix_test__cache__cleanup() {
  posix_test__debug 'posix_test__cache__cleanup' \
    'cleanup process started..'

  if ! ___cleanup_targets="$(_posix_test__cache__cleanup__find_targets)"
  then
    ___status="$?"
    exit "$___status"
  fi

  if [ -n "$___cleanup_targets" ]
  then

    for ___target in $___cleanup_targets
    do
      _posix_test__cache__cleanup__delete_target "$___target"
    done

    posix_test__debug 'posix_test__cache__cleanup' 'cleanup finished'
  else
    posix_test__debug 'posix_test__cache__cleanup' 'nothing to clean up'
  fi
}

#==============================================================================
# Helper function to find the deletable cache directories in the cache parent
# directory.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CACHE__RUNTIME__NORMALIZED_CACHE_PARENT_DIRECTORY
#   POSIX_TEST__CACHE__CONFIG__DIRECTORY_PREFIX
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Multiline list of deletable targets.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_posix_test__cache__cleanup__find_targets() {
  posix_test__debug '_posix_test__cache__cleanup__find_targets' \
    'looking for deletable cache directories..'

  if ___find_output="$( \
    posix_adapter__find "$POSIX_TEST__CACHE__RUNTIME__NORMALIZED_CACHE_PARENT_DIRECTORY" \
      --max-depth '1' \
      --type 'd' \
      --name "${POSIX_TEST__CACHE__CONFIG__DIRECTORY_PREFIX}*" \
      2>&1 \
  )"
  then
    ___directory_count="$( \
      posix_adapter__echo "$___find_output" | posix_adapter__wc --lines \
    )"
    posix_test__debug '_posix_test__cache__cleanup__find_targets' \
      "deletable directory count: ${___directory_count}"
    posix_test__debug_list '_posix_test__cache__cleanup__find_targets' \
      'target result:' \
      "$___find_output"
    posix_adapter__echo "$___find_output"

  else

    posix_test__debug '_posix_test__cache__cleanup__find_targets' \
      'error happened while looking for cache directories.. exiting!'

    posix_test__report_error_and_exit \
      'Cache system clean up failed!' \
      'An unexpected error happened during the clean up target findig process!' \
      "$___find_output"

  fi
}

#==============================================================================
# Helper function to delete the given target cache directory.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] target - Deletable target.
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
_posix_test__cache__cleanup__delete_target() {
  ___target="$1"

  posix_test__debug '_posix_test__cache__cleanup__delete_target' \
    "deleting '${___target}'.."

  if ___rm_output="$(posix_adapter__rm --recursive --force "$___target" 2>&1)"
  then
    posix_test__debug '_posix_test__cache__cleanup__delete_target' \
      "deleted '${___target}'"
  else
    posix_test__report_error_and_exit \
      'Cache system clean up failed!' \
      "An unexpected error happened while cleaning up '${___target}'!" \
      "$___rm_output"
  fi
}

#==============================================================================
#  _____                                                 _____ _ _
# |_   _|__ _ __ ___  _ __   ___  _ __ __ _ _ __ _   _  |  ___(_) | ___  ___
#   | |/ _ \ '_ ` _ \| '_ \ / _ \| '__/ _` | '__| | | | | |_  | | |/ _ \/ __|
#   | |  __/ | | | | | |_) | (_) | | | (_| | |  | |_| | |  _| | | |  __/\__ \
#   |_|\___|_| |_| |_| .__/ \___/|_|  \__,_|_|   \__, | |_|   |_|_|\___||___/
#====================|_|=========================|___/=========================
# TEMPORARY FILES
#==============================================================================

#==============================================================================
# The cache system provides a way to create temporary files and temporary paths
# that can be used during the test execution.
#==============================================================================

# Variable that holds the name of the temporary files directory. This variable
# is not intended for accessing the directory.
POSIX_TEST__CACHE__CONFIG__TEMP_FILES_PATH_NAME='temp_files'

# Temporary file name template for the `mktemp` based temporary file
# generation.
POSIX_TEST__CACHE__CONFIG__TEMP_FILE_TEMPLATE='temp_file.XXXXXXXXXXXXXXXX'

# Postfix that is needed for the unique temporary path creation. It will be
# appended to the unique temp file path created by `mktemp` to have a unique
# path that can be returned.
POSIX_TEST__CACHE__CONFIG__TEMP_FILE_POSTFIX='.path'

# Variable thar holds the runtime path of the temporary files directory. This
# variable should be used for writing or reading purposes.
POSIX_TEST__CACHE__RUNTIME__TEMP_FILES_PATH='__INVALID__'

#==============================================================================
# Inner function to initialize the directory for the temporary files.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CACHE__RUNTIME__TEMP_FILES_PATH
#   POSIX_TEST__CACHE__RUNTIME__CACHE_PATH
#   POSIX_TEST__CACHE__CONFIG__TEMP_FILES_PATH_NAME
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   POSIX_TEST__CACHE__RUNTIME__TEMP_FILES_PATH
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_posix_test__cache__init__temp_files_base_directory() {
  # Using a subshell here to prevent the long line.
  # shellcheck disable=2116
  POSIX_TEST__CACHE__RUNTIME__TEMP_FILES_PATH="$( \
    posix_adapter__printf '%s' "${POSIX_TEST__CACHE__RUNTIME__CACHE_PATH}/"; \
    posix_adapter__echo "$POSIX_TEST__CACHE__CONFIG__TEMP_FILES_PATH_NAME" \
  )"
  posix_adapter__mkdir --parents "$POSIX_TEST__CACHE__RUNTIME__TEMP_FILES_PATH"

  posix_test__debug '_posix_test__cache__init__temp_files_base_directory' \
    "temp files base created: '${POSIX_TEST__CACHE__RUNTIME__TEMP_FILES_PATH}'"
}

#==============================================================================
# Creates a temporary file in the cache directory and returns its path.
# Internally it uses the `mktemp` command to create an actual unique temporary
# file.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CACHE__RUNTIME__TEMP_FILES_PATH
#   POSIX_TEST__CACHE__CONFIG__TEMP_FILE_TEMPLATE
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
#==============================================================================
posix_test__cache__create_temp_file() {
  if ___mktemp_output="$( \
    posix_adapter__mktemp \
      --tmpdir "$POSIX_TEST__CACHE__RUNTIME__TEMP_FILES_PATH" \
      "$POSIX_TEST__CACHE__CONFIG__TEMP_FILE_TEMPLATE" \
      2>&1 \
  )"
  then
    ___file="$___mktemp_output"
    posix_test__debug 'posix_test__cache__create_temp_file' \
      "temp file created: '${___file}'"
    posix_adapter__echo "$___file"
  else
    posix_test__report_error_and_exit \
      'Temporary file generation failed!' \
      'Cannot create a unique temporary file!' \
      "$___mktemp_output"
  fi
}

#==============================================================================
# Creates a temporary path without an actual path behind it. Internally it is
# based on a temporary file which is created as a placeholder, and to its path
# a postfix gets appended. This will be the returned unique path. This method
# guarantees a unique path, because the `mktemp -u` (dry-run) could have race
# conditions. So in the end we will have an extra empty temporary file.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CACHE__CONFIG__TEMP_FILE_POSTFIX
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
# - Temporary path.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
posix_test__cache__create_temp_path() {
  ___file="$(posix_test__cache__create_temp_file)"
  ___path="${___file}${POSIX_TEST__CACHE__CONFIG__TEMP_FILE_POSTFIX}"
  posix_test__debug 'posix_test__cache__create_temp_path' \
    "temp path created: '${___path}'"
  posix_adapter__echo "$___path"
}

#==============================================================================
#  _____                                                 ____  _
# |_   _|__ _ __ ___  _ __   ___  _ __ __ _ _ __ _   _  |  _ \(_)_ __ ___
#   | |/ _ \ '_ ` _ \| '_ \ / _ \| '__/ _` | '__| | | | | | | | | '__/ __|
#   | |  __/ | | | | | |_) | (_) | | | (_| | |  | |_| | | |_| | | |  \__ \
#   |_|\___|_| |_| |_| .__/ \___/|_|  \__,_|_|   \__, | |____/|_|_|  |___/
#====================|_|=========================|___/=========================
# TEMPORARY DIRECTORIES
#==============================================================================

#==============================================================================
# The cache system also provides a way to create temporary directories that can
# be used during the test execution. These temporary directories are created
# inside a separated directory. The directories are generated with a precise
# timestamp postfix, so collision between the names are very unlikely.
#==============================================================================

# Variable that holds the name of the temporary directories directory. This
# variable is not intended for accessing the directory.
POSIX_TEST__CACHE__CONFIG__TEMP_DIRS_PATH_NAME='temp_directories'

# Temporary directory name template for the `mktemp` based temporary directory
# generation.
POSIX_TEST__CACHE__CONFIG__TEMP_DIR_TEMPLATE='temp_directory.XXXXXXXXXXXXXXXX'

# Variable thar holds the runtime path of the temporary directories directory.
# This variable should be used for writing or reading purposes.
POSIX_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH='__INVALID__'

#==============================================================================
# Inner function to initialize the directory for the temporary directories.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH
#   POSIX_TEST__CACHE__RUNTIME__CACHE_PATH
#   POSIX_TEST__CACHE__CONFIG__TEMP_DIRS_PATH_NAME
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   POSIX_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_posix_test__cache__init__temp_directories_base_directory() {
  # Using a subshell here to prevent the long line.
  # shellcheck disable=2116
  POSIX_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH="$( \
    posix_adapter__printf '%s' "${POSIX_TEST__CACHE__RUNTIME__CACHE_PATH}/"; \
    posix_adapter__echo "$POSIX_TEST__CACHE__CONFIG__TEMP_DIRS_PATH_NAME" \
  )"
  posix_adapter__mkdir --parents "$POSIX_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH"

  posix_test__debug '_posix_test__cache__init__temp_directories_base_directory' \
    "temp dirs base created: '${POSIX_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH}'"
}

#==============================================================================
# Creates a temporary directory in the cache directory and returns its path.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH
#   POSIX_TEST__CACHE__CONFIG__TEMP_DIR_TEMPLATE
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
#==============================================================================
posix_test__cache__create_temp_directory() {
  if ___mktemp_output="$( \
    posix_adapter__mktemp \
      --directory \
      --tmpdir "$POSIX_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH" \
      "$POSIX_TEST__CACHE__CONFIG__TEMP_DIR_TEMPLATE" \
      2>&1 \
  )"
  then
    ___dir="$___mktemp_output"
    posix_test__debug 'posix_test__cache__create_temp_directory' \
      "temporary directory created: '${___dir}'"
    posix_adapter__echo "$___dir"
  else
    posix_test__report_error_and_exit \
      'Temporary file generation failed!' \
      'Cannot create a unique temporary file!' \
      "$___mktemp_output"
  fi
}
