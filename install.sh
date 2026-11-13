#!/bin/bash
# Bootstrap dotfiles on a fresh macOS or Linux machine (needs network):
#   curl -fsSL https://raw.githubusercontent.com/Q0tzly/dotfiles/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/Q0tzly/dotfiles/main/install.sh | bash -s -- --groups lang,ai
# Flags: --groups a,b (enable mise tool groups, see mise/groups/), --all (every group),
#        --link-only (skip mise install)
#        --subcon (also clone and install subcon, which links itself and its Muse skill)
#        --no-mise-group (never fetch mise-group via mise exec for group enabling;
#                         only a mise-group already installed is used)
set -euo pipefail

REPO_URL="https://github.com/Q0tzly/dotfiles.git"
DOTFILES="${DOTFILES:-$HOME/dev/github.com/q0tzly/dotfiles}"
OS="${DOTFILES_OS:-$(uname -s)}"
SUBCON_REPO_URL="https://github.com/Q0tzly/subcon.git"
SUBCON="${SUBCON:-$HOME/dev/github.com/q0tzly/subcon}"
WITH_SUBCON=0
WITH_MISE_GROUP=1
GROUPS_TO_ENABLE=""
ALL_GROUPS=0
LINK_ONLY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --groups) GROUPS_TO_ENABLE="${2:?--groups needs a comma-separated list}"; shift ;;
    --all) ALL_GROUPS=1 ;;
    --link-only) LINK_ONLY=1 ;;
    --subcon) WITH_SUBCON=1 ;;
    --no-mise-group) WITH_MISE_GROUP=0 ;;
    *) echo "unknown flag: $1" >&2; exit 1 ;;
  esac
  shift
done

log() { printf '==> %s\n' "$*"; }

case "$OS" in
  Darwin|Linux) ;;
  *) echo "unsupported OS: $OS" >&2; exit 1 ;;
esac
command -v curl >/dev/null || { echo "curl not found" >&2; exit 1; }

if [[ -d "$DOTFILES/.git" ]]; then
  log "Updating $DOTFILES"
  git -C "$DOTFILES" pull --ff-only || log "pull skipped (no upstream or local changes)"
else
  command -v git >/dev/null || { echo "git not found (macOS: xcode-select --install)" >&2; exit 1; }
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
link bash/bashrc "$HOME/.bashrc"
# XDG path on purpose: leaves ~/.gitconfig free for machine-specific settings.
link git/config "$HOME/.config/git/config"
link git/hooks "$HOME/.config/git/hooks"
case "$OS" in
  Darwin) link ghostty/config.ghostty "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty" ;;
  Linux) link ghostty/config.ghostty "$HOME/.config/ghostty/config.ghostty" ;;
  *) echo "unsupported OS: $OS" >&2; exit 1 ;;
esac
link helix/config.toml "$HOME/.config/helix/config.toml"
link helix/languages.toml "$HOME/.config/helix/languages.toml"
link starship/starship.toml "$HOME/.config/starship.toml"
# The mise base lives in conf.d/, not at config.toml: `mise use -g` writes to
# ~/.config/mise/config.toml, and that file must stay machine-local so tool
# installs never edit the tracked base through a symlink.
if [[ -L "$HOME/.config/mise/config.toml" && "$(readlink "$HOME/.config/mise/config.toml")" == "$DOTFILES/mise/config.toml" ]]; then
  rm "$HOME/.config/mise/config.toml"
  log "Removed legacy ~/.config/mise/config.toml link (base moved to conf.d/base.toml)"
fi
link mise/config.toml "$HOME/.config/mise/conf.d/base.toml"
# Group definitions live here; the mise-group tool itself is a separate
# project installed by mise (see the base tools), and its default groups
# directory is ~/.config/mise/groups.
link mise/groups "$HOME/.config/mise/groups"
link cargo/config.toml "$HOME/.cargo/config.toml"
# One global instruction file for every coding agent. Codex does not expand
# @imports, so the file must be self-contained.
link ai/AGENTS.md "$HOME/.claude/CLAUDE.md"
link ai/AGENTS.md "$HOME/.codex/AGENTS.md"
# Muse reads ~/AGENTS.md as its operating manual, so the same file goes there too.
link ai/AGENTS.md "$HOME/AGENTS.md"

# Tracked hooks: the pre-commit hook guards base files against accidental
# commits of edits that tools made through the symlinks.
git -C "$DOTFILES" config core.hooksPath hooks

# mise-group (the tool that enables/disables the groups in mise/groups) is
# a separate project (Q0tzly/mise-group) and is itself installed by mise:
# it is one of the base tools in mise/config.toml. Before that install has
# run, group enabling borrows it through `mise exec`, which installs it on
# demand. --no-mise-group disables that fallback.
export PATH="$HOME/.local/bin:$PATH"
if [[ $LINK_ONLY -eq 0 ]] && ! command -v mise >/dev/null; then
  log "Installing mise"
  curl -fsSL https://mise.run | sh
fi
MG=""
if command -v mise-group >/dev/null; then
  MG="$(command -v mise-group)"
fi
mise_group() {
  if [[ -n "$MG" ]]; then
    "$MG" "$@"
  elif [[ $WITH_MISE_GROUP -eq 1 ]] && command -v mise >/dev/null; then
    # Config-driven first (the base tools already list mise-group; this
    # also works when a version is installed but `latest` is temporarily
    # hidden by mise's minimum_release_age). The explicit form is the
    # first-run fallback and installs on demand. Only read-only and
    # idempotent subcommands (names, enable --no-install) are used here,
    # so trying the second form after the first fails is safe.
    mise exec -- mise-group "$@" 2>/dev/null || \
      mise exec "github:Q0tzly/mise-group@latest" -- mise-group "$@"
  else
    return 1
  fi
}

if [[ $WITH_SUBCON -eq 1 ]]; then
  if [[ -d "$SUBCON/.git" ]]; then
    log "Updating $SUBCON"
    git -C "$SUBCON" pull --ff-only || log "pull skipped (no upstream or local changes)"
  else
    log "Cloning subcon into $SUBCON"
    git clone "$SUBCON_REPO_URL" "$SUBCON"
  fi
  "$SUBCON/install.sh"
fi

# Untracked, machine-specific secrets go here; keep them private.
for local_rc in "$HOME/.zshrc.local" "$HOME/.bashrc.local"; do
  if [[ ! -e "$local_rc" ]]; then
    (umask 077; : > "$local_rc")
    log "Created $local_rc"
  fi
  chmod 600 "$local_rc"
done

if [[ $ALL_GROUPS -eq 1 || -n "$GROUPS_TO_ENABLE" ]]; then
  if ! mise_group names >/dev/null 2>&1; then
    log "mise-group not available: skipping group enabling (drop --no-mise-group, or install mise-group first)"
  elif [[ $ALL_GROUPS -eq 1 ]]; then
    mise_group enable --no-install $(mise_group names)
  else
    mise_group enable --no-install ${GROUPS_TO_ENABLE//,/ }
  fi
fi

if [[ $LINK_ONLY -eq 1 ]]; then
  log "Done (links only)"
  exit 0
fi

log "Installing tools with mise"
mise install --yes

command -v zsh >/dev/null || log "zsh not found: install it with your package manager (the shell config is for zsh)"
log "Done. Open a new shell. Ghostty itself is not installed by this script."
