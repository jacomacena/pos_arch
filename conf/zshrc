# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10
SAVEHIST=10
bindkey -e

# bindkeys

bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[2~' overwrite-mode
bindkey '^[[3~' delete-char
bindkey '^[[A'  up-line-or-history
bindkey '^[[B'  down-line-or-history
bindkey '^[[C'  forward-char
bindkey '^[[D'  backward-char
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word


# End of lines configured by zsh-newuser-install

setopt histexpiredupsfirst          # Expire duplicate entries first when trimming history.
setopt histignorespace              # ignore line with leading space
setopt incappendhistory             # append history at same time, not at shell exits
setopt nobanghist                   # don't expand !
setopt nobeep                       # nobeep in tty
setopt sharehistory                 # share history between sessions


# The following lines were added by compinstall
zstyle :compinstall filename '$HOME/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Exports
export VISUAL="vim"
#export JAVA_HOME="/usr/lib/jvm/java-15-openjdk"

### CUSTOM ###
#plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

#alias
source ~/.alias/aliases.sh

# theme
autoload -U promptinit; promptinit
prompt spaceship

# Include hidden files.
_comp_options+=(globdots)

# spaceship
SPACESHIP_PROMPT_ORDER=(
  user          # Username section
  dir           # Current directory section
  host          # Hostname section
  git           # Git section (git_branch + git_status)
  # hg            # Mercurial section (hg_branch  + hg_status)
  # package       # Package version
  # node          # Node.js section
  # ruby          # Ruby section
  # elixir        # Elixir section
  # xcode         # Xcode section
  # swift         # Swift section
  # golang        # Go section
  # php           # PHP section
  # rust          # Rust section
  # haskell       # Haskell Stack section
  # julia         # Julia section
  # docker        # Docker section
  # aws           # Amazon Web Services section
  # gcloud        # Google Cloud Platform section
  venv          # virtualenv section
  # conda         # conda virtualenv section
  # pyenv         # Pyenv section
  # dotnet        # .NET section
  # ember         # Ember.js section
  # kubectl       # Kubectl context section
  # terraform     # Terraform workspace section
  line_sep      # Line break
  # battery       # Battery level and status
  # vi_mode       # Vi-mode indicator
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)
SPACESHIP_RPROMPT_ORDER=(
  # time          # Time stamps section
  exec_time     # Execution time
)
SPACESHIP_CHAR_SYMBOL=" ➜ "
SPACESHIP_GIT_STATUS_BEHIND=""
SPACESHIP_GIT_STATUS_AHEAD=""
#if [ "$(hostname)" != "arch" ]
#then
#    SPACESHIP_USER_SHOW=always
#    SPACESHIP_HOST_SHOW=always
#fi
# SPACESHIP_VI_MODE_COLOR=#586e75
# SPACESHIP_VI_MODE_INSERT=[i]
# SPACESHIP_VI_MODE_NORMAL=[n]
