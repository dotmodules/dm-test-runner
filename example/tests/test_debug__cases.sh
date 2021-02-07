#==============================================================================
# DEBUG MODE DEMONSTRATION
#==============================================================================

test__success() {
  echo "standard output content"
  >&3 echo "fd3 content"
  assert true
}

test__failure() {
  echo "standard output content"
  >&3 echo "fd3 content"
  assert false
}
