#!/bin/sh

#==============================================================================
# This testing file is intended to test the dependent program and shell
# built-ins to have the required behavior. If a tool fails during these test,
# an additional tool selection layer needs to be introduced to the system that
# dynamically selects the appropriate tool interface to be used.
#==============================================================================

#==============================================================================
# SANE ENVIRONMENT
#==============================================================================

set -e  # exit on error
set -u  # prevent unset variable expansion

#==============================================================================
# HELPER FUNCTIONS
#==============================================================================

# Checking the availibility and usability of tput. If it is available and
# usable we can set the global coloring variables with it.
if command -v tput >/dev/null && tput init >/dev/null 2>&1
then
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  BOLD="$(tput bold)"
else
  RED=''
  GREEN=''
  BOLD=''
fi

log_task() {
  message="$1"
    echo "${BOLD}[ ${BLUE}..${RESET}${BOLD} ]${RESET} ${message}"
}

log_success() {
  message="$1"
    echo "${BOLD}[ ${GREEN}OK${RESET}${BOLD} ]${RESET} ${message}"
}

log_failure() {
  message="$1"
    echo "${BOLD}[ ${RED}!!${RESET}${BOLD} ]${RESET} ${message}"
}

tool_assert() {
  title="$1"
  expected="$2"
  result="$3"

  if [ "$result" = "$expected"  ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit 1
  fi
}

#==============================================================================
# TOOL: BASENAME
#==============================================================================
# No flags were used with this tool, assuming the base behavior is always
# present.

#==============================================================================
# TOOL: CAT
#==============================================================================
# No flags were used with this tool only the dash file parameter that should
# explicitly trigger the standard input read, assuming the this behavior is
# always present.

#==============================================================================
# TOOL: CD
#==============================================================================
# Assuming this utility behaves uniformily as it is defined by the POSIX
# standard.

#==============================================================================
# TOOL: COMMAND
#==============================================================================
# Assuming this utility behaves uniformily as it is defined by the POSIX
# standard.

#==============================================================================
# TOOL: CUT
#==============================================================================
title='cut - delimiter and field selection'
data='one/two/three/four'
expected='two/three/four'
result="$(echo "$data" | cut --delimiter '/' --fields '2-')"
tool_assert "$title" "$expected" "$result"

title='cut - character rane selection'
data='123456789'
expected='12345'
result="$(echo "$data" | cut --characters='1-5')"
tool_assert "$title" "$expected" "$result"

#==============================================================================
# TOOL: DATE
#==============================================================================
title='date - generated timestamp is numbers only'
result="$(date +'%s%N')"
if echo "$result" | grep --silent -E '[[:digit:]]+'
then
  log_success "$title"
else
  log_failure "$title"
  log_failure 'should have generated only digits'
  log_failure "failed result: '${result}'"
  exit 1
fi

#==============================================================================
# TOOL: DIRNAME
#==============================================================================
# No flags were used with this tool, assuming the base behavior is always
# present.

#==============================================================================
# TOOL: ECHO
#==============================================================================
# No flags were used with this tool, assuming the base behavior is always
# present.

#==============================================================================
# TOOL: EXIT
#==============================================================================
# No flags were used with this tool, assuming the base behavior is always
# present.

#==============================================================================
# TOOL: FIND
#==============================================================================
title='find - basic file search by name'
if find . -type 'f' -name '*' >/dev/null
then
  log_success "$title"
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

title='find - basic file search by name zero terminated'
if find . -type 'f' -name '*' -print0 >/dev/null
then
  log_success "$title"
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

title='find - basic direcroty search by name'
if find . -type 'd' -name '*' >/dev/null
then
  log_success "$title"
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

title='find - basic directory search by name zero terminated'
if find . -type 'd' -name '*' -print0 >/dev/null
then
  log_success "$title"
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

#==============================================================================
# TOOL: GREP
#==============================================================================
title='grep - extended regexp mode'
expected='hello'
if result="$(echo "hello" | grep -E 'l+')"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'ineffective extended regexp mode'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

title='grep - silent mode'
expected=''
if result="$(echo "hello" | grep --silent '.')"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'ineffective --silent flag'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

title='grep - inverted mode'
expected='hello'
if result="$(echo "hello" | grep --invert-match 'imre')"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'ineffective --invert-match flag'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

title='grep - count mode'
expected='1'
if result="$(echo "hello" | grep --count 'l')"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'ineffective --count flag'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

title='grep - only matching mode'
expected='ll'
if result="$(echo "imre hello" | grep --only-matching 'll')"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'ineffective --only-matching flag'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

#==============================================================================
# TOOL: MKDIR
#==============================================================================
title='mkdir - parents flag'
if mkdir --parents tests
then
  log_success "$title"
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

#==============================================================================
# TOOL: MKFIFO
#==============================================================================
# No flags were used with this tool, assuming the base behavior is always
# present.

#==============================================================================
# TOOL: MKTEMP
#==============================================================================
# No flags were used with this tool, assuming the base behavior is always
# present.

#==============================================================================
# TOOL: PRINTF
#==============================================================================
title='printf - minimum width specifier'
expected=' 42'
if result="$(printf '%*s' 3 '42')"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'unsupported feature'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

title='printf - precision specifier'
expected='123'
if result="$(printf '%.*s' 3 '123456')"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'unsupported feature'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

title='printf - combined minimum width and precision specifier'
expected=' 123'
if result="$(printf '%*.*s' 4 3 '123456')"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'unsupported feature'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

#==============================================================================
# TOOL: READ
#==============================================================================
# The read built-in is specified under the POSIX standard, the used -r flag
# should be supported on all platforms.

#==============================================================================
# TOOL: READLINK
#==============================================================================
title='readlink - canonicalize mode'
if readlink -f . >/dev/null 2>&1
then
  log_success "$title"
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

#==============================================================================
# TOOL: REALPATH
#==============================================================================
title='realpath - no symlink mode'
if realpath --no-symlink . >/dev/null 2>&1
then
  log_success "$title"
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

#==============================================================================
# TOOL: RM
#==============================================================================
title='rm - recursive and force mode'
expected=''
if result="$(rm --recursive --force 'something-that-surely-does-not-exist-123456789')"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'unsupported feature'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

#==============================================================================
# TOOL: SED
#==============================================================================
title='sed - append prefix before line'
expected='prefix - hello'
if result="$(echo 'hello' | sed 's/^/prefix - /')"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'unsupported feature'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

title='sed - remove digits only'
expected='and other text'
if result="$(echo '42 and other text' | sed -E 's/^[[:digit:]]+\s//')"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'unsupported feature'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

title='sed - select line'
expected='line 2'
if result="$( ( echo 'line 1'; echo 'line 2'; echo 'line 3' ) | sed '2q;d')"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'unsupported feature'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

#==============================================================================
# TOOL: SORT
#==============================================================================
title='sort - parameter checking'
if echo 'hello' | sort --zero-terminated --dictionary-order >/dev/null 2>&1
then
  log_success "$title"
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

#==============================================================================
# TOOL: TEST
#==============================================================================
# The test built-in is specified under the POSIX standard, the used -r flag
# should be supported on all platforms.

#==============================================================================
# TOOL: TOUCH
#==============================================================================
# No flags were used with this tool, assuming the base behavior is always
# present.

#==============================================================================
# TOOL: TR
#==============================================================================
title='tr - delete newline'
expected='abc'
if result="$( ( echo 'a'; echo 'b'; echo 'c' ) | tr --delete '\n')"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'unsupported feature'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

#==============================================================================
# TOOL: TRAP
#==============================================================================
# The trap built-in is specified under the POSIX standard, the used -r flag
# should be supported on all platforms.

#==============================================================================
# TOOL: TRUE
#==============================================================================
# No flags were used with this tool, assuming the base behavior is always
# present.

#==============================================================================
# TOOL: UNAME
#==============================================================================
title='uname - parameter checking'
if uname --kernel-name --kernel-release --machine --operating-system >/dev/null 2>&1
then
  log_success "$title"
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

#==============================================================================
# TOOL: WAIT
#==============================================================================
# The wait built-in is specified under the POSIX standard, the used -r flag
# should be supported on all platforms.

#==============================================================================
# TOOL: WC
#==============================================================================
title='wc - lines'
expected='3'
if result="$( ( echo 'a'; echo 'b'; echo 'c' ) | wc --lines)"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'unsupported feature'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

title='wc - chars'
expected='12' # 11 character + 1 newline
if result="$( echo 'this is ok!' | wc --chars)"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'unsupported feature'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

#==============================================================================
# TOOL: XARGS
#==============================================================================
title='xargs - placeholder and additional parameters'
expected='hello'
if result="$( echo 'hello' | xargs --no-run-if-empty -I {} echo {})"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'unsupported feature'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

title='xargs - null terminated'
expected='hello'
if result="$( echo 'hello' | xargs --null)"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'unsupported feature'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

title='xargs - arg length 1'
expected='hello'
if result="$( echo 'hello' | xargs -n1)"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'unsupported feature'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

title='xargs - arg length 2'
expected='hello'
if result="$( echo 'hello' | xargs --max-args=1)"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'unsupported feature'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

#==============================================================================
# TOOL: XXD
#==============================================================================
title='xxd - encode'
expected='68656c6c6f0a'
if result="$( echo 'hello' | xxd -plain)"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'unsupported feature'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi

title='xxd - decode'
expected='hello'
if result="$( echo '68656c6c6f0a' | xxd -plain -reverse)"
then
  if [ "$result" = "$expected" ]
  then
    log_success "$title"
  else
    log_failure "$title"
    log_failure 'unsupported feature'
    log_failure "expected: '${expected}'"
    log_failure "result:   '${result}'"
    exit
  fi
else
  log_failure "$title"
  log_failure 'possible unsupported parameters'
  exit 1
fi
