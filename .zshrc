if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ ! -f ${ZDOTDIR:-${HOME}}/.zcomet/bin/zcomet.zsh ]]; then
  command git clone https://github.com/agkozak/zcomet.git ${ZDOTDIR:-${HOME}}/.zcomet/bin
fi

source ${ZDOTDIR:-${HOME}}/.zcomet/bin/zcomet.zsh

if [ -f ~/.secretrc ]; then
  source ~/.secretrc
fi

if [[ -f "/opt/homebrew/opt/asdf/libexec/asdf.sh" ]]; then
  source /opt/homebrew/opt/asdf/libexec/asdf.sh
fi

if [[ -f "$HOME/.asdf/asdf.sh" ]]; then
  source "$HOME/.asdf/asdf.sh"
fi

# Exports #############################################################################################
export BAT_THEME="base16"
export CPPFLAGS="-I/opt/homebrew/opt/icu4c/include"
export DIRENV_LOG_FORMAT=
export EDITOR="nvim"
export GOPATH="$HOME/go"
export HISTFILE="$HOME/.zsh_history"
export HISTFILESIZE=100000
export HISTSIZE=100000
export LDFLAGS="-L/opt/homebrew/opt/icu4c/lib"
export LS_COLORS=''
export MANPAGER='nvim +Man!'
export MANWIDTH=999
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES # needed for ansible node_exporter
export VISUAL="nvim"
export XDG_CONFIG_HOME="$HOME/.config"
export ZELLIJ_CONFIG_DIR="$HOME/.config/zellij"

path+=("$GOPATH/bin")
path+=("$HOME/.local/bin")
path+=("/opt/homebrew/bin")
path+=("/opt/homebrew/sbin")
#######################################################################################################

# zcomet ##############################################################################################
zcomet load sunlei/zsh-ssh
zcomet load zsh-users/zsh-completions
zcomet load romkatv/powerlevel10k
zcomet load trystan2k/zsh-tab-title

if [ -x "$(command -v brew)" ]; then
  # brew version of git autocomplete is bad, remove it
  if [[ -f /opt/homebrew/share/zsh/site-functions/_git ]]; then
    command rm /opt/homebrew/share/zsh/site-functions/_git
  fi

  zcomet fpath "$(brew --prefix)/share/zsh/site-functions"
fi

zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

zcomet compinit

zcomet load Aloxaf/fzf-tab
zcomet load zsh-users/zsh-autosuggestions
zcomet load zsh-users/zsh-syntax-highlighting
#######################################################################################################

# Aliases #############################################################################################
alias bx='bundle exec'
alias ll='exa -lbF --git'
alias rg="rg --hidden --glob '!.git'"
alias zj='zellij'

# Git Aliases
alias lg='lazygit'
alias gst='git status'
alias gl='git pull'
alias gco='git checkout'
alias ggp='git push -u origin HEAD'
alias gscrub='git reset --hard @{upstream}'

if [[ "$(command -v hivemind)" ]]; then alias foreman='hivemind'; fi
#######################################################################################################

# Functions ###########################################################################################
copdiff() { git diff --name-only --diff-filter=d $1 -- "*.rb" } 
copexclude() { sed "/^db\/schema\.rb/d" }
cop() { copdiff $1 | copexclude | xargs bundle exec rubocop -a }
portkill() { lsof -t -i:$1 | xargs kill -9 }

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/ryancobb/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/ryancobb/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/ryancobb/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/ryancobb/google-cloud-sdk/completion.zsh.inc'; fi

setopt inc_append_history
setopt share_history
setopt extended_history
setopt hist_ignore_all_dups

unsetopt nomatch # run rake task with args with no error

bindkey -e
if [ -x "$(command -v fzf)" ]; then bindkey '^r' fzf-history-widget; fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [ -x "$(command -v direnv)" ]; then
  eval "$(direnv hook zsh)"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
