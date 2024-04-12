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

if type brew &>/dev/null 
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
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

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load

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

if [ -x "$(command -v fzf)" ]; then bindkey '^r' fzf-history-widget; fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [ -x "$(command -v direnv)" ]; then
  eval "$(direnv hook zsh)"
fi


