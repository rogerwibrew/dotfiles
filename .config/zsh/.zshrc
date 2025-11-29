# Zsh configuration for Roger's dotfiles

# Auto-start Unison sync in tmux on login
if [[ -o interactive ]] && [[ -z "$TMUX" ]]; then
  ~/dotfiles/scripts/sync/start-unison.sh >/dev/null 2>&1 &
  # Auto-pull dotfiles updates on login
  ~/dotfiles/scripts/git/dotfiles-pull.sh >/dev/null 2>&1 &
fi

# Enable colors
autoload -U colors && colors

# Basic auto/tab completion
autoload -U compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive
zmodload zsh/complist
compinit
_comp_options+=(globdots) # Include hidden files

# History settings
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Vi mode
bindkey -v
export KEYTIMEOUT=1

# Git prompt function
git_prompt_info() {
  # Check if we're in a git repo
  git rev-parse --is-inside-work-tree &>/dev/null || return

  # Get current branch name
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

  # Get git status
  local status=""
  if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    status="%F{red}●%f"  # Red dot for dirty
  else
    status="%F{green}●%f"  # Green dot for clean
  fi

  echo " %F{magenta}$branch%f $status"
}

# Prompt - simple and clean with hostname and git info
setopt PROMPT_SUBST
PROMPT='%F{cyan}%m%f %F{blue}%~%f$(git_prompt_info) %F{cyan}❯%f '

# Source aliases from shell config
[[ -f "$XDG_CONFIG_HOME/shell/alias" ]] && source "$XDG_CONFIG_HOME/shell/alias"

# Load nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Syntax highlighting (must be at end of file)
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
