# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#######################################################################################################
# Exports
#######################################################################################################

if [ -f ~/.secretrc ]; then
  source ~/.secretrc
fi

export BAT_THEME="ansi"
export CPPFLAGS="-I/opt/homebrew/opt/icu4c/include"
export EDITOR="nvim"
export GOPATH="$HOME/go"
export HISTFILE="$HOME/.zsh_history"
export HISTFILESIZE=100000
export HISTSIZE=100000
export LDFLAGS="-L/opt/homebrew/opt/icu4c/lib"
export LS_COLORS=''
export MANPAGER='nvim +Man!'
export MANWIDTH=999
export VISUAL="nvim"
export XDG_CONFIG_HOME="$HOME/.config"

path+=("$GOPATH/bin")
path+=("$HOME/.local/bin")

#######################################################################################################
# Homebrew
#######################################################################################################

if test -d /home/linuxbrew/.linuxbrew; then # Linux
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
  export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
  export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/Homebrew"
elif test -d /opt/homebrew; then # MacOS
  export HOMEBREW_PREFIX="/opt/homebrew"
  export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
  export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/homebrew"
fi

if test -d $HOMEBREW_PREFIX; then
  path+=("$HOMEBREW_PREFIX/bin")
  path+=("$HOMEBREW_PREFIX/sbin")
  manpath+=("$HOMEBREW_PREFIX/share/man")
  infopath+=("$HOMEBREW_PREFIX/share/info")
  fpath+="$HOMEBREW_PREFIX/share/zsh/site-functions"

  # brew version of git autocomplete is bad, remove it
  if [[ -f $HOMEBREW_PREFIX/share/zsh/site-functions/_git ]]; then
    command rm $HOMEBREW_PREFIX/share/zsh/site-functions/_git
  fi

  eval "$($HOMEBREW_PREFIX/bin/mise activate zsh)"
fi

#######################################################################################################
# zcomet
#######################################################################################################

if [[ ! -f ${ZDOTDIR:-${HOME}}/.zcomet/bin/zcomet.zsh ]]; then
  command git clone https://github.com/agkozak/zcomet.git ${ZDOTDIR:-${HOME}}/.zcomet/bin
fi

source ${ZDOTDIR:-${HOME}}/.zcomet/bin/zcomet.zsh

zcomet load zsh-users/zsh-completions

zcomet load sunlei/zsh-ssh
zcomet load agkozak/zsh-z
zcomet load romkatv/powerlevel10k

zcomet load Aloxaf/fzf-tab
zcomet load zsh-users/zsh-syntax-highlighting
zcomet load zsh-users/zsh-autosuggestions

zcomet compinit

#######################################################################################################
# Aliases
#######################################################################################################

alias bx='bundle exec'
alias ll='eza -lbF --git'
alias rg="rg --hidden --glob '!.git'"

# Git Aliases
alias gst='git status'
alias gl='git pull'
alias gco='git checkout'
alias ggp='git push -u origin HEAD'
alias gscrub='git reset --hard @{upstream}'

#######################################################################################################
# Functions
#######################################################################################################

copdiff() { git diff --name-only --diff-filter=d $1 -- "*.rb" } 
copexclude() { sed "/^db\/schema\.rb/d" }
cop() { copdiff $1 | copexclude | xargs bundle exec rubocop -a }
portkill() { lsof -t -i:$1 | xargs kill -9 }

#######################################################################################################
# Opts
#######################################################################################################

setopt inc_append_history
setopt share_history
setopt extended_history
setopt hist_ignore_all_dups

unsetopt nomatch # run rake task with args with no error

bindkey -e

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
