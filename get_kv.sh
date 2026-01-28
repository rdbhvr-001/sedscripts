#!/bin/bash

########################################################################
# get_kv — robust key=value reader
#
# Usage:
#   get_kv [flags] <key> <sep> <fallback> <file>
#
# Flags:
#   --strict            trim spaces, quotes, semicolon, comments
#   --no-strict         disable strict preset
#   --trim-spaces
#   --trim-comments
#   --trim-quotes
#   --trim-semicolon
#
########################################################################
get_kv() {
  local strict=0
  local trim_spaces=0
  local trim_comments=0
  local trim_quotes=0
  local trim_semicolon=0

  # ---------- parse flags ----------
  while [[ "$1" == --* ]]; do
    case "$1" in
      --strict)
        strict=1
        ;;
      --no-strict)
        strict=0
        ;;
      --trim-spaces)
        trim_spaces=1
        ;;
      --trim-comments)
        trim_comments=1
        ;;
      --trim-quotes)
        trim_quotes=1
        ;;
      --trim-semicolon)
        trim_semicolon=1
        ;;
      *)
        echo "get_kv: unknown flag: $1" >&2
        return 1
        ;;
    esac
    shift
  done

  # ---------- strict preset ----------
  if (( strict )); then
    trim_spaces=1
    trim_comments=1
    trim_quotes=1
    trim_semicolon=1
  fi

  local key="$1"
  local sep="$2"
  local fallback="$3"
  local file="$4"

  [[ -f "$file" ]] || {
    printf '%s\n' "$fallback"
    return 0
  }

  awk \
    -v key="$key" \
    -v sep="$sep" \
    -v fallback="$fallback" \
    -v ts="$trim_spaces" \
    -v tc="$trim_comments" \
    -v tq="$trim_quotes" \
    -v tsc="$trim_semicolon" '
    BEGIN { found = 0 }

    # skip empty lines and full-line comments
    /^[[:space:]]*($|#|;)/ { next }

    {
      # split on first separator only
      pos = index($0, sep)
      if (pos == 0) next

      k = substr($0, 1, pos - 1)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", k)

      if (k == key) {
        v = substr($0, pos + length(sep))

        # inline comments
        if (tc)
          sub(/[[:space:]]*[#;].*$/, "", v)

        # spaces
        if (ts)
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)

        # trailing semicolon
        if (tsc)
          sub(/[[:space:]]*;[[:space:]]*$/, "", v)

        # wrapping quotes only
        if (tq) {
          if ((v ~ /^".*"$/) || (v ~ /^\047.*\047$/))
            v = substr(v, 2, length(v) - 2)
        }

        print v
        found = 1
        exit
      }
    }

    END {
      if (!found)
        print fallback
    }
  ' "$file"
}

##########################################################################################
# Testing codes
# get_kv animations "=" true picom.conf
# get_kv --strict animations "=" false picom.conf
# get_kv --trim-spaces shadow "=" false picom.conf
# get_kv --trim-quotes log-level "=" urgent picom.conf
# get_kv --strict log-level "=" urgent picom.conf
# get_kv --trim-semicolon active-opacity "=" 0 picom.conf
# get_kv --strict animations "=" false config.conf
# get_kv --strict animations ":" false config.conf
# get_kv --trim-spaces animations ":" true config.conf
# get_kv --trim-comments --trim-quotes commented "=" yes config.conf
# get_kv --trim-quotes quoted "-->" no config.conf
# get_kv --trim-semicolon --trim-quotes quoted "-->" no config.conf
# Note, first, you have to trim the outer most thing, then inner...
#    "yes"; --> first trim spaces, then semicolon, then quotes : strict works fine

# The cli
get_kv "$@"
