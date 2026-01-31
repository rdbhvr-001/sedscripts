#!/bin/bash

########################################################################
# set_kv — replace only the value token, preserve formatting
#
# Usage:
#   set_kv <key> <old> <sep> <new> <file>
#
######################################################################
set_kv() {
  local key="$1"
  local old="$2"
  local sep="$3"
  local new="$4"
  local file="$5"

  [[ -z "$key" || -z "$sep" || -z "$file" ]] && {
    echo "usage: set_kv <key> <old|_> <sep> <new> <file>" >&2
    return 2
  }

  [[ -f "$file" ]] || touch "$file"

  local tmp
  tmp="$(mktemp)"

  awk \
    -v key="$key" \
    -v old="$old" \
    -v new="$new" \
    -v sep="$sep" '
    BEGIN { changed = 0 }

    {
      pos = index($0, sep)
      if (pos == 0) {
        print
        next
      }

      k = substr($0, 1, pos - 1)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", k)

      if (k != key || changed) {
        print
        next
      }

      before = substr($0, 1, pos + length(sep) - 1)
      after  = substr($0, pos + length(sep))

      # replace-anything mode
      if (old == "_") {
        sub(/[^[:space:];#]+/, new, after)
        print before after
        changed = 1
        next
      }

      # replace specific token
      if (sub(old, new, after)) {
        print before after
        changed = 1
        next
      }

      print
    }

    END {
      if (!changed)
        exit 1
    }
  ' "$file" > "$tmp"

  if [[ $? -eq 0 ]]; then
    mv "$tmp" "$file"
    return 0
  else
    rm -f "$tmp"
    return 1
  fi
}

##############################################################################################
# Command line it...

# set_kv "$@"
