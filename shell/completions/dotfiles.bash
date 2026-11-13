# bash completion for the dotfiles command. Sourced by the bash loader.
_dotfiles_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=($(compgen -W "status check update help" -- "$cur"))
  elif [ "$COMP_CWORD" -ge 2 ] && [ "${COMP_WORDS[1]}" = "update" ]; then
    COMPREPLY=($(compgen -W "--no-upgrade --auto" -- "$cur"))
  else
    COMPREPLY=()
  fi
}
complete -F _dotfiles_complete dotfiles
