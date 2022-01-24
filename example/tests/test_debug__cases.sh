#!/bin/sh
#==============================================================================
# DEBUG MODE DEMONSTRATION
#==============================================================================

test__success() {
  dm_tools__echo "standard output content"
  >&3 dm_tools__echo "fd3 content"
  assert true
}

test__failure() {
  dm_tools__echo "standard output content"
  >&3 dm_tools__echo "fd3 content"
  assert false
}
