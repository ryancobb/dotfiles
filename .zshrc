# Exports #############################################################################################
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

if test -d /home/linuxbrew/.linuxbrew; then # Linux
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
  export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
  export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/Homebrew"
elif test -d /opt/homebrew; then # MacOS
  export HOMEBREW_PREFIX="/opt/homebrew"
  export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
  export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/homebrew"
fi

path+=("$HOMEBREW_PREFIX/bin")
path+=("$HOMEBREW_PREFIX/sbin")
manpath+=("$HOMEBREW_PREFIX/share/man")
infopath+=("$HOMEBREW_PREFIX/share/info")

path+=("$GOPATH/bin")
path+=("$HOME/.local/bin")

#######################################################################################################

if test -d $HOMEBREW_PREFIX; then
  # brew version of git autocomplete is bad, remove it
  if [[ -f $HOMEBREW_PREFIX/share/zsh/site-functions/_git ]]; then
    command rm $HOMEBREW_PREFIX/share/zsh/site-functions/_git
  fi

  eval "$($HOMEBREW_PREFIX/bin/mise activate zsh)"

  fpath+="$HOMEBREW_PREFIX/share/zsh/site-functions"
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
fpath+="$HOMEBREW_PREFIX/opt/antidote/share/antidote/functions/"
autoload -Uz antidote

# Generate a new static file whenever .zsh_plugins.txt is updated.
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi

# Source your static plugins file.
source ${zsh_plugins}.zsh

if type fzf > /dev/null 2>&1; then
  source <(fzf --zsh)
fi

autoload -Uz promptinit && promptinit

#######################################################################################################

# Aliases #############################################################################################
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
