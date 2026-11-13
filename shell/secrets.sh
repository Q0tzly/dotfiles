# API keys and other secrets: one store, outside this repository.
# This file is only the loader and helpers; it must never contain a value.
# POSIX sh compatible: both shells source it via shell/base.sh.
#
# Store (created by install.sh, never inside this public repo):
#   ${SECRETS_DIR:-$HOME/.config/secrets}    directory, mode 700
#     <name>     one key per file, mode 600, the raw value and nothing else
#                (name it after the service: sakura, gemini, openai, ...)
#     env.sh     opt-in environment exports, mode 600
#
# Use:
#   secret sakura                     print ~/.config/secrets/sakura
#   secret_export SAKURA_API_KEY sakura
#                                     in env.sh: export the file's value as
#                                     an env var. The value stays in the
#                                     one file; env.sh holds no copy of it.
#
# Credential stores that tools manage themselves (gh, claude, agy OAuth,
# ~/.kaggle/access_token, ssh keys, ...) do NOT belong here. Leave them
# where their tool puts them; this store is for loose API keys only.

SECRETS_DIR="${SECRETS_DIR:-$HOME/.config/secrets}"
export SECRETS_DIR

secret() {
  [ -n "${1:-}" ] && [ -f "$SECRETS_DIR/$1" ] || return 1
  cat "$SECRETS_DIR/$1"
}

secret_export() {
  [ -n "${1:-}" ] && [ -n "${2:-}" ] && [ -f "$SECRETS_DIR/$2" ] || return 0
  export "$1=$(cat "$SECRETS_DIR/$2")"
}

[ -f "$SECRETS_DIR/env.sh" ] && . "$SECRETS_DIR/env.sh"
