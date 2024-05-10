# Exports #############################################################################################
if [ -f ~/.secretrc ]; then
  source ~/.secretrc
fi


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
export ZSH_TAB_TITLE_DEFAULT_DISABLE_PREFIX=true

path+=("$GOPATH/bin")
path+=("$HOME/.local/bin")
path+=("/opt/homebrew/bin")
path+=("/opt/homebrew/sbin")

#######################################################################################################

if type brew &>/dev/null; then
  export BREW_PREFIX=$(brew --prefix)

  # brew version of git autocomplete is bad, remove it
  if [[ -f $BREW_PREFIX/share/zsh/site-functions/_git ]]; then
    command rm $BREW_PREFIX/share/zsh/site-functions/_git
  fi

  source $BREW_PREFIX/opt/asdf/libexec/asdf.sh
  fpath+="$BREW_PREFIX/share/zsh/site-functions"
fi

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# Set the root name of the plugins files (.txt and .zsh) antidote will use.
zsh_plugins=${ZDOTDIR:-~}/.zsh_plugins

# Ensure the .zsh_plugins.txt file exists so you can add plugins.
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

# Lazy-load antidote from its functions directory.
fpath+="$BREW_PREFIX/opt/antidote/share/antidote/functions/"
autoload -Uz antidote

# Generate a new static file whenever .zsh_plugins.txt is updated.
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi

# Source your static plugins file.
source ${zsh_plugins}.zsh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if [ -x "$(command -v fzf)" ]; then bindkey '^r' fzf-history-widget; fi

autoload -Uz promptinit && promptinit && prompt 'powerlevel10k'

#######################################################################################################

# Aliases #############################################################################################
alias bx='bundle exec'
alias ll='eza -lbF --git'
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

setopt inc_append_history
setopt share_history
setopt extended_history
setopt hist_ignore_all_dups

unsetopt nomatch # run rake task with args with no error

bindkey -e

eval "$(direnv hook zsh)"

