#!/bin/bash
# Daily mise upgrade of core plus every enabled group (see mise-group).
# launchd/systemd have no login-shell env, so set PATH/token explicitly.
set -u
export PATH="$HOME/.local/bin:/usr/bin:/bin"

# Authenticated GitHub requests avoid API rate limits when resolving "latest".
if token="$(mise exec gh -- gh auth token 2>/dev/null)" && [[ -n $token ]]; then
  export MISE_GITHUB_TOKEN="$token"
fi

echo "=== $(date '+%F %T') mise upgrade ==="
mise upgrade --yes
