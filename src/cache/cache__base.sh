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
dm_test__cache__init() {
  dm_test__debug 'dm_test__cache__init' 'initializing cache system..'

  # Initializing and normalizing the cache parent directory.
  _dm_test__cache__normalize_cache_parent_directory

  # At this point the cache parent directory has been finalized, we can try to
  # clean up all the leftover cache directories.
  dm_test__cache__cleanup

  # Creating the new cache directory..
  _dm_test__cache__create_base_cache_directory
  # At this point the current cache directory has been created, so arming the
  # trap system to clean it up on exit or interrupt signals.
  dm_test__arm_trap_system

  # Initializing the internal cache structure..
  _dm_test__cache__init__temp_files_base_directory
  _dm_test__cache__init__temp_directories_base_directory

  # Sub-cache system initialization.
  _dm_test__cache__global_count__init
  _dm_test__cache__global_errors__init
  _dm_test__cache__global_failures__init
  _dm_test__cache__test_result__init

  dm_test__debug 'dm_test__cache__init' 'cache system initialized'
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
DM_TEST__CACHE__CONFIG__DIRECTORY_PREFIX='dm_test_cache'

# Cache directory prefix extended with the necessary `mktemp` compatible
# template. This variable will be used to create a unique cache directory each
# time.
DM_TEST__CACHE__CONFIG__MKTEMP_TEMPLATE=\
"${DM_TEST__CACHE__CONFIG__DIRECTORY_PREFIX}.XXXXXXXXXX"

# Global variable that hold the normalized cache parent directory. Normalizing
# the cache parent directory should be the first step during cache system
# initialization.
DM_TEST__CACHE__RUNTIME__NORMALIZED_CACHE_PARENT_DIRECTORY='__INVALID__'

# Global variable that holds the path to the currently operational cache
# directory.
DM_TEST__CACHE__RUNTIME__CACHE_PATH='__INVALID__'

#==============================================================================
# Function that will normalize and validate the cache parent directory received
# from the configuration.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CONFIG__OPTIONAL__CACHE_PARENT_DIRECTORY
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__CACHE__RUNTIME__NORMALIZED_CACHE_PARENT_DIRECTORY
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_test__cache__normalize_cache_parent_directory() {
  ___raw_parent="$DM_TEST__CONFIG__OPTIONAL__CACHE_PARENT_DIRECTORY"
  ___parent="$(dm_tools__realpath --no-symlinks "$___raw_parent")"

  dm_test__debug '_dm_test__cache__normalize_cache_parent_directory' \
    "normalizing raw cache parent directory: '${___raw_parent}'"

  if [ -d "$___parent" ]
  then
    :
  else
    if ___output="$(dm_tools__mkdir --parents "$___parent" 2>&1)"
    then
      :
    else
      dm_test__report_error_and_exit \
        'Cache system initialization failed!' \
        "Cache parent directory '${___parent}' cannot be created!" \
        "$___output"
    fi
  fi

  if [ -w "$___parent" ]
  then
    :
  else
    dm_test__report_error_and_exit \
      'Cache system initialization failed!' \
      'Cache parent directory exists but you have no write permission!' \
      "unable to write into '${___parent}': Permission denied"
  fi

  DM_TEST__CACHE__RUNTIME__NORMALIZED_CACHE_PARENT_DIRECTORY="$___parent"

  dm_test__debug '_dm_test__cache__normalize_cache_parent_directory' \
    "raw cache parent directory normalized: '${___parent}'"
}

#==============================================================================
# Inner function that will create the cache directory and sets the global
# variable for it.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__CONFIG__MKTEMP_TEMPLATE
#   DM_TEST__CACHE__RUNTIME__CACHE_PATH
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__CACHE__RUNTIME__CACHE_PATH
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_test__cache__create_base_cache_directory() {
  if ___mktemp_output="$( \
    dm_tools__mktemp \
      --directory \
      --tmpdir "$DM_TEST__CACHE__RUNTIME__NORMALIZED_CACHE_PARENT_DIRECTORY" \
      "$DM_TEST__CACHE__CONFIG__MKTEMP_TEMPLATE" \
      2>&1 \
  )"
  then
    DM_TEST__CACHE__RUNTIME__CACHE_PATH="$___mktemp_output"
  else
    dm_test__report_error_and_exit \
      'Cache system initialization failed!' \
      'Cache base directory cannot be created!' \
      "$___mktemp_output"
  fi

  dm_test__debug '_dm_test__cache__create_base_cache_directory' \
    "base cache directory created: '${DM_TEST__CACHE__RUNTIME__CACHE_PATH}'"
}

#==============================================================================
# Cleans up all existing cache directories that are matches to the predefined
# prefix in the cache parent directory..
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
dm_test__cache__cleanup() {
  dm_test__debug 'dm_test__cache__cleanup' \
    'cleanup process started..'

  if ! ___cleanup_targets="$(_dm_test__cache__cleanup__find_targets)"
  then
    ___status="$?"
    exit "$___status"
  fi

  if [ -n "$___cleanup_targets" ]
  then

    for ___target in $___cleanup_targets
    do
      _dm_test__cache__cleanup__delete_target "$___target"
    done

    dm_test__debug 'dm_test__cache__cleanup' 'cleanup finished'
  else
    dm_test__debug 'dm_test__cache__cleanup' 'nothing to clean up'
  fi
}

#==============================================================================
# Helper function to find the deletable cache directories in the cache parent
# directory.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__CONFIG__DIRECTORY_PREFIX
#   DM_TEST__CACHE__RUNTIME__NORMALIZED_CACHE_PARENT_DIRECTORY
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
_dm_test__cache__cleanup__find_targets() {
  dm_test__debug '_dm_test__cache__cleanup__find_targets' \
    'looking for deletable cache directories..'

  if ___find_output="$( \
    dm_tools__find "$DM_TEST__CACHE__RUNTIME__NORMALIZED_CACHE_PARENT_DIRECTORY" \
      --max-depth '1' \
      --type 'd' \
      --name "${DM_TEST__CACHE__CONFIG__DIRECTORY_PREFIX}*" \
      2>&1 \
  )"
  then
    ___directory_count="$( \
      dm_tools__echo "$___find_output" | dm_tools__wc --lines \
    )"
    dm_test__debug '_dm_test__cache__cleanup__find_targets' \
      "deletable directory count: ${___directory_count}"
    dm_test__debug_list '_dm_test__cache__cleanup__find_targets' \
      'target result:' \
      "$___find_output"
    dm_tools__echo "$___find_output"

  else

    dm_test__debug '_dm_test__cache__cleanup__find_targets' \
      'error happened while looking for cache directories.. exiting!'

    dm_test__report_error_and_exit \
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
_dm_test__cache__cleanup__delete_target() {
  ___target="$1"

  dm_test__debug '_dm_test__cache__cleanup__delete_target' \
    "deleting '${___target}'.."

  if ___rm_output="$(dm_tools__rm --recursive --force "$___target" 2>&1)"
  then
    dm_test__debug '_dm_test__cache__cleanup__delete_target' \
      "deleted '${___target}'"
  else
    dm_test__report_error_and_exit \
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
DM_TEST__CACHE__CONFIG__TEMP_FILES_PATH_NAME='temp_files'

# Temporary file name template for the `mktemp` based temporary file
# generation.
DM_TEST__CACHE__CONFIG__TEMP_FILE_TEMPLATE='temp_file.XXXXXXXXXXXXXXXX'

# Postfix that is needed for the unique temporary path creation. It will be
# appended to the unique temp file path created by `mktemp` to have a unique
# path that can be returned.
DM_TEST__CACHE__CONFIG__TEMP_FILE_POSTFIX='.path'

# Variable thar holds the runtime path of the temporary files directory. This
# variable should be used for writing or reading purposes.
DM_TEST__CACHE__RUNTIME__TEMP_FILES_PATH='__INVALID__'

#==============================================================================
# Inner function to initialize the directory for the temporary files.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__RUNTIME__TEMP_FILES_PATH
#   DM_TEST__CACHE__RUNTIME__CACHE_PATH
#   DM_TEST__CACHE__CONFIG__TEMP_FILES_PATH_NAME
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__CACHE__RUNTIME__TEMP_FILES_PATH
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_test__cache__init__temp_files_base_directory() {
  # Using a subshell here to prevent the long line.
  # shellcheck disable=2116
  DM_TEST__CACHE__RUNTIME__TEMP_FILES_PATH="$( \
    dm_tools__printf '%s' "${DM_TEST__CACHE__RUNTIME__CACHE_PATH}/"; \
    dm_tools__echo "$DM_TEST__CACHE__CONFIG__TEMP_FILES_PATH_NAME" \
  )"
  dm_tools__mkdir --parents "$DM_TEST__CACHE__RUNTIME__TEMP_FILES_PATH"

  dm_test__debug '_dm_test__cache__init__temp_files_base_directory' \
    "temp files base created: '${DM_TEST__CACHE__RUNTIME__TEMP_FILES_PATH}'"
}

#==============================================================================
# Creates a temporary file in the cache directory and returns its path.
# Internally it uses the `mktemp` command to create an actual unique temporary
# file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__RUNTIME__TEMP_FILES_PATH
#   DM_TEST__CACHE__CONFIG__TEMP_FILE_TEMPLATE
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
dm_test__cache__create_temp_file() {
  if ___mktemp_output="$( \
    dm_tools__mktemp \
      --tmpdir "$DM_TEST__CACHE__RUNTIME__TEMP_FILES_PATH" \
      "$DM_TEST__CACHE__CONFIG__TEMP_FILE_TEMPLATE" \
      2>&1 \
  )"
  then
    ___file="$___mktemp_output"
    dm_test__debug 'dm_test__cache__create_temp_file' \
      "temp file created: '${___file}'"
    dm_tools__echo "$___file"
  else
    dm_test__report_error_and_exit \
      'Temporary file generation failed!' \
      'Cannot create a unique temporary file!' \
      "$___mktemp_output"
  fi
}

#==============================================================================
# Creates a temporary path without an actual path behind it. Internally it is
# based on a temporary file which is created as a placeholder, and to its path
# a postfix gets appended. This will be the returned unique path. This method
# guarantees a unique path, because the `mktemp -u` could have race conditions.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__CONFIG__TEMP_FILE_POSTFIX
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
dm_test__cache__create_temp_path() {
  ___file="$(dm_test__cache__create_temp_file)"
  ___path="${___file}${DM_TEST__CACHE__CONFIG__TEMP_FILE_POSTFIX}"
  dm_test__debug 'dm_test__cache__create_temp_path' \
    "temp path created: '${___path}'"
  dm_tools__echo "$___path"
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
DM_TEST__CACHE__CONFIG__TEMP_DIRS_PATH_NAME='temp_directories'

# Temporary directory name template for the `mktemp` based temporary directory
# generation.
DM_TEST__CACHE__CONFIG__TEMP_DIR_TEMPLATE='temp_directory.XXXXXXXXXXXXXXXX'


# Variable thar holds the runtime path of the temporary directories directory.
# This variable should be used for writing or reading purposes.
DM_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH='__INVALID__'

#==============================================================================
# Inner function to initialize the directory for the temporary directories.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH
#   DM_TEST__CACHE__RUNTIME__CACHE_PATH
#   DM_TEST__CACHE__CONFIG__TEMP_DIRS_PATH_NAME
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_test__cache__init__temp_directories_base_directory() {
  # Using a subshell here to prevent the long line.
  # shellcheck disable=2116
  DM_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH="$( \
    dm_tools__printf '%s' "${DM_TEST__CACHE__RUNTIME__CACHE_PATH}/"; \
    dm_tools__echo "$DM_TEST__CACHE__CONFIG__TEMP_DIRS_PATH_NAME" \
  )"
  dm_tools__mkdir --parents "$DM_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH"

  dm_test__debug '_dm_test__cache__init__temp_directories_base_directory' \
    "temp dirs base created: '${DM_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH}'"
}

#==============================================================================
# Creates a temporary directory in the cache directory and returns its path.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH
#   DM_TEST__CACHE__CONFIG__TEMP_DIR_TEMPLATE
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
dm_test__cache__create_temp_directory() {
  if ___mktemp_output="$( \
    dm_tools__mktemp \
      --directory \
      --tmpdir "$DM_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH" \
      "$DM_TEST__CACHE__CONFIG__TEMP_DIR_TEMPLATE" \
      2>&1 \
  )"
  then
    ___dir="$___mktemp_output"
    dm_test__debug 'dm_test__cache__create_temp_directory' \
      "temporary directory created: '${___dir}'"
    dm_tools__echo "$___dir"
  else
    dm_test__report_error_and_exit \
      'Temporary file generation failed!' \
      'Cannot create a unique temporary file!' \
      "$___mktemp_output"
  fi
}
