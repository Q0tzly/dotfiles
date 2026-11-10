#!/bin/bash
# Bootstrap dotfiles on a fresh Mac (needs network):
#   curl -fsSL https://raw.githubusercontent.com/Q0tzly/dotfiles/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/Q0tzly/dotfiles/main/install.sh | bash -s -- --plus
# Flags: --plus (also install config.plus.toml tools), --link-only (skip mise install)
set -euo pipefail

REPO_URL="https://github.com/Q0tzly/dotfiles.git"
DOTFILES="${DOTFILES:-$HOME/dev/github.com/q0tzly/dotfiles}"
PLUS=0
LINK_ONLY=0
for arg in "$@"; do
  case "$arg" in
    --plus) PLUS=1 ;;
    --link-only) LINK_ONLY=1 ;;
    *) echo "unknown flag: $arg" >&2; exit 1 ;;
  esac
done

log() { printf '==> %s\n' "$*"; }

if [[ -d "$DOTFILES/.git" ]]; then
  log "Updating $DOTFILES"
  git -C "$DOTFILES" pull --ff-only || log "pull skipped (no upstream or local changes)"
else
  command -v git >/dev/null || { echo "git not found. Run: xcode-select --install" >&2; exit 1; }
  log "Cloning into $DOTFILES"
  git clone "$REPO_URL" "$DOTFILES"
fi

# link <repo-relative source> <destination>
# Existing real files are moved aside so nothing is lost.
link() {
  local src="$DOTFILES/$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    return
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    mv "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
    log "Backed up existing $dst"
  fi
  ln -s "$src" "$dst"
  log "Linked $dst"
}

link zsh/zshrc "$HOME/.zshrc"
# XDG path on purpose: leaves ~/.gitconfig free for machine-specific settings.
link git/config "$HOME/.config/git/config"
link ghostty/config.ghostty "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
link helix/config.toml "$HOME/.config/helix/config.toml"
link helix/languages.toml "$HOME/.config/helix/languages.toml"
link starship/starship.toml "$HOME/.config/starship.toml"
link mise/config.toml "$HOME/.config/mise/config.toml"
link mise/config.plus.toml "$HOME/.config/mise/config.plus.toml"
link cargo/config.toml "$HOME/.cargo/config.toml"

# Untracked, machine-specific secrets go here; keep it private.
if [[ ! -e "$HOME/.zshrc.local" ]]; then
  (umask 077; : > "$HOME/.zshrc.local")
  log "Created $HOME/.zshrc.local"
fi
chmod 600 "$HOME/.zshrc.local"

if [[ $LINK_ONLY -eq 1 ]]; then
  log "Done (links only)"
  exit 0
fi

export PATH="$HOME/.local/bin:$PATH"
if ! command -v mise >/dev/null; then
  log "Installing mise"
  curl -fsSL https://mise.run | sh
fi

log "Installing tools with mise"
if [[ $PLUS -eq 1 ]]; then
  MISE_ENV=plus mise install --yes
else
  mise install --yes
fi

log "Done. Open a new shell. Ghostty itself is not installed by this script."
