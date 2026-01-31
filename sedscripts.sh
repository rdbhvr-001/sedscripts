#!/usr/bin/env bash

set -e

cmd="$1"
shift || true   # remove command, keep remaining args intact

case "$cmd" in
    get_kv|set_kv|has_k|has_kv)
        source "$(dirname "$0")/$cmd.sh"
        "$cmd" "$@"
        ;;
    ""|-h|--help)
        echo "Usage: $0 <get_kv|set_kv|has_k|has_kv> [args...]"
        exit 1
        ;;
    *)
        echo "sedscripts: unknown command '$cmd'" >&2
        exit 1
        ;;
esac
