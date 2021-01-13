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
#------------------------------------------------------------------------------
# Tools:
#   None
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
  # At this point the current cache drectory has been created, so arming the
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
#------------------------------------------------------------------------------
# Tools:
#   realpath mkdir test
#==============================================================================
_dm_test__cache__normalize_cache_parent_directory() {
  ___raw_parent="$DM_TEST__CONFIG__OPTIONAL__CACHE_PARENT_DIRECTORY"
  ___parent="$(realpath --no-symlinks "$___raw_parent")"

  dm_test__debug '_dm_test__cache__normalize_cache_parent_directory' \
    "normalizing raw cache parent directory: '${___raw_parent}'"

  if [ -d "$___parent" ]
  then
    :
  else
    if ___output="$(mkdir --parents "$___parent" 2>&1)"
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
#------------------------------------------------------------------------------
# Tools:
#   mktemp test
#==============================================================================
_dm_test__cache__create_base_cache_directory() {
  if ___mktemp_output="$( \
    mktemp \
      -t \
      --directory \
      --tmpdir="$DM_TEST__CACHE__RUNTIME__NORMALIZED_CACHE_PARENT_DIRECTORY" \
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
#------------------------------------------------------------------------------
# Tools:
#   test
#==============================================================================
dm_test__cache__cleanup() {
  dm_test__debug 'dm_test__cache__cleanup' \
    'cleanup process started..'

  ___cleanup_targets="$(_dm_test__cache__cleanup__find_targets)"

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
#------------------------------------------------------------------------------
# Tools:
#   find echo wc test
#==============================================================================
_dm_test__cache__cleanup__find_targets() {
  dm_test__debug '_dm_test__cache__cleanup__find_targets' \
    'looking for deletable cache directories..'

  if ___find_output="$( \
    find "$DM_TEST__CACHE__RUNTIME__NORMALIZED_CACHE_PARENT_DIRECTORY" \
      -maxdepth 1 \
      -type d \
      -name "${DM_TEST__CACHE__CONFIG__DIRECTORY_PREFIX}*" \
      2>&1 \
  )"
  then

    dm_test__debug '_dm_test__cache__cleanup__find_targets' \
      "deletable directory count: $(echo "$___find_output" | wc --lines)"
    echo "$___find_output"

  else

    dm_test__debug '_dm_test__cache__cleanup__find_targets' \
      'error happened while looking for cache directories.. exiting!'

    dm_test__report_error_and_exit \
      'Cache system clean up failed!' \
      'An unexpected error happened during the clean up process!' \
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
#------------------------------------------------------------------------------
# Tools:
#   rm test
#==============================================================================
_dm_test__cache__cleanup__delete_target() {
  ___target="$1"

  dm_test__debug '_dm_test__cache__cleanup__delete_target' \
    "deleting '${___target}'.."

  if ___rm_output="$(rm --recursive --force "$___target" 2>&1)"
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
# The cache system provides a way to create temporary files that can be used
# during the test execution. These temporary files are created inside a
# seprated directory. The files are generated with a precise timestamp postfix,
# to prevent collision between the generated file names.
#==============================================================================

# Variable that holds the name of the temporary files directory. This variable
# is not intended for accessing the directory.
DM_TEST__CACHE__CONFIG__TEMP_FILES_PATH_NAME='temp_files'

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
#------------------------------------------------------------------------------
# Tools:
#   mkdir echo printf
#==============================================================================
_dm_test__cache__init__temp_files_base_directory() {
  # Using a subshell here to prevent the long line.
  # shellcheck disable=2116
  DM_TEST__CACHE__RUNTIME__TEMP_FILES_PATH="$( \
    printf '%s' "${DM_TEST__CACHE__RUNTIME__CACHE_PATH}/"; \
    echo "$DM_TEST__CACHE__CONFIG__TEMP_FILES_PATH_NAME" \
  )"
  mkdir --parents "$DM_TEST__CACHE__RUNTIME__TEMP_FILES_PATH"

  dm_test__debug '_dm_test__cache__init__temp_files_base_directory' \
    "temp files base created: '${DM_TEST__CACHE__RUNTIME__TEMP_FILES_PATH}'"
}

#==============================================================================
# Creates a temporary file path in the cache directory and returns its path.
# Note: only a filepath will be created, the caller is responsible for actually
# creating the file.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__RUNTIME__TEMP_FILES_PATH
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
#------------------------------------------------------------------------------
# Tools:
#   echo
#==============================================================================
dm_test__cache__create_temp_file() {
  ___postfix="$(_dm_test__cache__generate_postfix)"
  ___file="${DM_TEST__CACHE__RUNTIME__TEMP_FILES_PATH}/${___postfix}"
  echo "$___file"

  dm_test__debug 'dm_test__cache__create_temp_file' \
    "temp file created: '${___file}'"
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
# inside a seprated directory. The directories are generated with a precise
# timestamp postfix, so collision between the names are very unlikely.
#==============================================================================

# Variable that holds the name of the temporary directories directory. This
# variable is not intended for accessing the directory.
DM_TEST__CACHE__CONFIG__TEMP_DIRS_PATH_NAME='temp_directories'

# Variable thar holds the runtime path of the temporary direcotories directory.
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
#------------------------------------------------------------------------------
# Tools:
#   mkdir echo printf
#==============================================================================
_dm_test__cache__init__temp_directories_base_directory() {
  # Using a subshell here to prevent the long line.
  # shellcheck disable=2116
  DM_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH="$( \
    printf '%s' "${DM_TEST__CACHE__RUNTIME__CACHE_PATH}/"; \
    echo "$DM_TEST__CACHE__CONFIG__TEMP_DIRS_PATH_NAME" \
  )"
  mkdir --parents "$DM_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH"

  dm_test__debug '_dm_test__cache__init__temp_directories_base_directory' \
    "temp dirs base created: '${DM_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH}'"
}

#==============================================================================
# Creates a temporary directory in the cache directory and returns its path.
#------------------------------------------------------------------------------
# Globals:
#   DM_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH
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
#------------------------------------------------------------------------------
# Tools:
#   mkdir echo
#==============================================================================
dm_test__cache__create_temp_directory() {
  ___postfix="$(_dm_test__cache__generate_postfix)"
  ___dir="${DM_TEST__CACHE__RUNTIME__TEMP_DIRS_PATH}/${___postfix}.d"
  mkdir --parents "$___dir"
  echo "$___dir"

  dm_test__debug 'dm_test__cache__create_temp_directory' \
    "temporary directory created: '${___dir}'"
}

#==============================================================================
#  _   _ _   _ _ _ _   _
# | | | | |_(_) (_) |_(_) ___  ___
# | | | | __| | | | __| |/ _ \/ __|
# | |_| | |_| | | | |_| |  __/\__ \
#  \___/ \__|_|_|_|\__|_|\___||___/
#==============================================================================
# UTILITIES
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
#------------------------------------------------------------------------------
# Tools:
#   date echo
#==============================================================================
_dm_test__cache__generate_postfix() {
  ___postfix="$(date +'%s%N')"
  echo "$___postfix"

  dm_test__debug '_dm_test__cache__generate_postfix' \
    "postfix generated: '${___postfix}'"
}
