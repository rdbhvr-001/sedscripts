#!/bin/bash

########################################################################
# has_kv
#
# Check whether a key exists AND has a value in a config file.
#
# Usage:
#   has_kv [flags] <key> <sep> <file>
#
# Flags:
#   --strict
#       Equivalent to:
#         --ignore-comments
#         --ignore-spaces
#         --ignore-quotes
#         --ignore-semicolon
#       Treats empty / quoted-empty / semicolon-only values as missing.
#
#   --ignore-comments     Ignore inline comments (# or ;)
#   --ignore-spaces       Trim leading/trailing whitespace in value
#   --ignore-quotes       Strip surrounding single or double quotes
#   --ignore-semicolon    Strip trailing semicolon
#
# Default behavior:
#   - Ignores full-line comments
#   - DOES NOT modify value
#   - A value is considered present if it exists after separator
#
# Exit status:
#   0  → key exists AND has a value
#   1  → key missing OR value empty
#
# Examples:
#   has_kv animations = picom.conf
#   has_kv --strict animations = picom.conf
#
########################################################################
has_kv() {
  ignore_comments=0
  ignore_spaces=0
  ignore_quotes=0
  ignore_semicolon=0

  # --- parse flags ---
  while [ "${1#--}" != "$1" ]; do
    case "$1" in
      --ignore-comments)  ignore_comments=1 ;;
      --ignore-spaces)    ignore_spaces=1 ;;
      --ignore-quotes)    ignore_quotes=1 ;;
      --ignore-semicolon) ignore_semicolon=1 ;;
      --strict)
        ignore_comments=1
        ignore_spaces=1
        ignore_quotes=1
        ignore_semicolon=1
        ;;
      *)
        echo "has_kv: unknown flag $1" >&2
        return 1
        ;;
    esac
    shift
  done

  key="$1"
  sep="$2"
  file="$3"

  [ -f "$file" ] || return 1

  awk \
    -v key="$key" \
    -v sep="$sep" \
    -v ic="$ignore_comments" \
    -v is="$ignore_spaces" \
    -v iq="$ignore_quotes" \
    -v isc="$ignore_semicolon" '
    BEGIN { found = 0 }

    # skip empty or full-line comments
    /^[[:space:]]*($|#|;)/ { next }

    {
      split($0, parts, sep)
      k = parts[1]
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", k)

      if (k != key)
        next

      # extract value (everything after first sep)
      v = substr($0, index($0, sep) + length(sep))

      if (ic) {
        sub(/[[:space:]]*[#;].*$/, "", v)
      }

      if (is) {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
      }

      if (isc) {
        sub(/[[:space:]]*;[[:space:]]*$/, "", v)
      }

      if (iq) {
        if (v ~ /^".*"$/ || v ~ /^'\''.*'\''$/)
          v = substr(v, 2, length(v) - 2)
      }

      if (length(v) > 0) {
        found = 1
      }

      exit
    }

    END { exit found ? 0 : 1 }
  ' "$file"
}

has_kv "$@"
