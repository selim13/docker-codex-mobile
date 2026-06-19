#!/bin/sh
set -eu

if [ "$#" -gt 0 ]; then
    case "$1" in
        codexapp)
            shift
            ;;
        -*)
            ;;
        *)
            exec "$@"
            ;;
    esac
fi

CODEX_HOME="${CODEX_HOME:-"$HOME/.codex"}"
PASSWORD_FILE="${CODEXUI_PASSWORD_FILE:-"$CODEX_HOME/codexui-password"}"

mkdir -p "$(dirname "$PASSWORD_FILE")"

if [ -f "$PASSWORD_FILE" ]; then
    PASSWORD="$(sed -n '1p' "$PASSWORD_FILE")"
    if [ -z "$PASSWORD" ]; then
        echo "codexapp password file is empty: $PASSWORD_FILE" >&2
        exit 1
    fi
else
    PASSWORD="$(node -e "const { randomInt } = require('node:crypto'); const chars = 'abcdefghijklmnopqrstuvwxyz0123456789'; const group = () => Array.from({ length: 3 }, () => chars[randomInt(chars.length)]).join(''); console.log([group(), group(), group()].join('-'))")"
    (
        umask 077
        printf '%s\n' "$PASSWORD" > "$PASSWORD_FILE"
    )
fi

exec codexapp --password "$PASSWORD" "$@"
