# Shared shell base for zsh and bash: minimal and deterministic.
# No prompt, no completion, no decoration, so AI agents and scripts get
# exactly the same environment as a human's non-interactive shell.
# Human-only extras live in shell/human.sh and load only in the human
# profile (see the loaders: zsh/zshrc, bash/bashrc).
# This file must stay POSIX sh compatible: both shells source it.

# PATH in one place: deduplicated, existing directories only.
_dotfiles_new=""
for _dotfiles_dir in \
  "$HOME/.local/bin" \
  "$HOME/.antigravity-ide/antigravity-ide/bin" \
  "$HOME/.codeium/windsurf/bin" \
  "$HOME/.grok/bin" \
  "$HOME/.lmstudio/bin"
do
  [ -d "$_dotfiles_dir" ] || continue
  case ":$PATH:" in
    *":$_dotfiles_dir:"*) ;;
    *) _dotfiles_new="${_dotfiles_new:+${_dotfiles_new}:}$_dotfiles_dir" ;;
  esac
done
[ -n "$_dotfiles_new" ] && PATH="$_dotfiles_new:$PATH"
export PATH
unset _dotfiles_dir _dotfiles_new

# Installers (uv, ...) drop an env file here.
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Tool shims and per-directory tool switching, for humans and agents alike.
if command -v mise >/dev/null 2>&1; then
  if [ -n "${ZSH_VERSION:-}" ]; then
    eval "$(mise activate zsh)"
  elif [ -n "${BASH_VERSION:-}" ]; then
    eval "$(mise activate bash)"
  fi
fi

# Authenticated GitHub requests avoid API rate limits when mise resolves "latest".
if command -v gh >/dev/null 2>&1; then
  _dotfiles_token="$(gh auth token 2>/dev/null)"
  [ -n "$_dotfiles_token" ] && export MISE_GITHUB_TOKEN="$_dotfiles_token"
  unset _dotfiles_token
fi
