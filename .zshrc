# Zsh configuration for Roger's dotfiles

# Auto-start Unison sync in tmux on login
if [[ -o interactive ]] && [[ -z "$TMUX" ]]; then
  ~/dotfiles/scripts/sync/start-unison.sh >/dev/null 2>&1 &
fi

# Enable colors
autoload -U colors && colors

# Basic auto/tab completion
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots) # Include hidden files

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Vi mode
bindkey -v
export KEYTIMEOUT=1

# Prompt - simple and clean
PROMPT='%F{blue}%~%f %F{cyan}❯%f '

# Aliases
alias ls='eza'
alias ll='eza -l'
alias la='eza -la'
alias lt='eza --tree'

# SSH and Sync shortcuts
alias ssh-newton='~/dotfiles/scripts/ssh/connect-newton.sh'
alias sync-now='~/dotfiles/scripts/sync/sync-now.sh'
alias sync-check='tmux attach -t unison'
alias sync-stop='tmux kill-session -t unison'
alias sync-log='tail -f ~/.unison/dev-sync.log'

# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
