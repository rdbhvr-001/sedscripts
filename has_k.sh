#!/bin/bash

########################################################################
# has_k
#
# Check whether a key exists in a config file.
#
# Usage:
#   has_k <key> <sep> <file>
#
# Arguments:
#   <key>   : key name to look for
#   <sep>   : key-value separator (e.g. =, :, space)
#   <file>  : config file
#
# Behavior:
#   - Ignores empty lines
#   - Ignores commented lines (# or ;)
#   - Trims surrounding whitespace around the key
#   - Matches the key exactly (no prefix matching)
#   - Does NOT check or parse the value
#   - Does NOT modify the file
#
# Exit status:
#   0  → key exists
#   1  → key does not exist or file missing
#
# Examples:
#   has_k animations = picom.conf && echo "exists"
#   has_k backend : config.ini || echo "missing"
#
########################################################################


has_k() {
  key="$1"
  sep="$2"
  file="$3"

  [ -f "$file" ] || return 1

  awk -v key="$key" -v sep="$sep" '
    BEGIN { found = 0 }

    /^[[:space:]]*($|#|;)/ { next }

    {
      split($0, parts, sep)
      k = parts[1]
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", k)

      if (k == key) {
        found = 1
        exit
      }
    }

    END { exit found ? 0 : 1 }
  ' "$file"
}

has_k "$@"
