# Human-only extras: convenience aliases that assume a person at the
# keyboard. Loaded by the shell loaders only in the human profile, so
# agents never see command meanings change under them.
# POSIX sh compatible: both shells source it.

alias fl='furl'
alias l='eza --git'
alias la='eza -a --git'
alias lt='eza -T --git -I "target|__pycache__|node_modules"'
alias ll='eza -l --total-size --git'
