#!/bin/sh
#==============================================================================
# DEBUG MODE DEMONSTRATION
#==============================================================================

test__success() {
  posix_adapter__echo "standard output content"
  >&3 posix_adapter__echo "fd3 content"
  assert true
}

test__failure() {
  posix_adapter__echo "standard output content"
  >&3 posix_adapter__echo "fd3 content"
  assert false
}
