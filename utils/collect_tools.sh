#!/bin/sh
#==============================================================================
# Collecting the tools used in this library. This function expects that all
# functions in this library documents the ised tools in its docstring after the
# `Tools:` header.
#==============================================================================

cd "$(dirname "$(readlink -f "$0")")" || exit

HEADER_TEMPLATE="# Tools:"

find .. -type f -name '*.sh' -print0 | \
  # Filtering the tools list in each file by gathering the header+1 lines.
  xargs -0 -I {} grep -A 1 "$HEADER_TEMPLATE" {} | \
  # Ignoring grep's match separator.
  grep -v '^--' | \
  # Ignoring the header templates.
  grep -v "$HEADER_TEMPLATE" | \
  # Ignoring the matches that contains no tools.
  grep -v 'None' | \
  # Breaking up the matches into one workd per line.
  xargs -n1 | \
  sort | \
  uniq | \
  # Removing the leftover hashmark.
  grep -v '#'
