# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ ! -f ${ZDOTDIR:-${HOME}}/.zcomet/bin/zcomet.zsh ]]; then
  command git clone https://github.com/agkozak/zcomet.git ${ZDOTDIR:-${HOME}}/.zcomet/bin
fi

source ${ZDOTDIR:-${HOME}}/.zcomet/bin/zcomet.zsh

# Exports #############################################################################################
export BAT_THEME="base16"
export LS_COLORS='no=00;37:fi=00:di=00;33:ln=04;36:pi=40;33:so=01;35:bd=40;33;01:'
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES # needed for ansible node_exporter
export GOPATH="$HOME/go"
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=100000
export HISTFILESIZE=100000

if [[ "$(command -v nvim)" ]]; then
  if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
    alias nvim="nvr -cc split --remote-wait +'set bufhidden=wipe'"
    export VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
    export EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
  else
    export VISUAL="nvim"
    export EDITOR="nvim"
  fi

  export MANPAGER='nvim +Man!'
  export MANWIDTH=999
fi

path+=("$GOPATH/bin")
path+=("$HOME/.local/bin")
path+=("/opt/homebrew/bin")
path+=("/opt/homebrew/sbin")

# zcomet ##############################################################################################

zcomet load asdf-vm/asdf asdf.sh
zcomet load sunlei/zsh-ssh
zcomet load zsh-users/zsh-completions
zcomet load romkatv/powerlevel10k

zcomet load junegunn/fzf shell completion.zsh key-bindings.zsh
(( ${+commands[fzf]} )) || ~[fzf]/install --bin

if [ -x "$(command -v brew)" ]; then
  # brew version of git autocomplete is bad, remove it
  if [[ -f /opt/homebrew/share/zsh/site-functions/_git ]]; then
    command rm /opt/homebrew/share/zsh/site-functions/_git
  fi

  zcomet fpath "$(brew --prefix)/share/zsh/site-functions"
fi

zcomet fpath asdf-vm/asdf completions
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'

zcomet compinit

zcomet load Aloxaf/fzf-tab
zcomet load zsh-users/zsh-autosuggestions
zcomet load zsh-users/zsh-syntax-highlighting

#######################################################################################################


# Aliases #############################################################################################

alias ssh="wezterm ssh"
alias bx='bundle exec'
alias ll='exa -lbF --git'
alias rg="rg --hidden --glob '!.git'"

# Git Aliases
alias lg='lazygit'
alias gst='git status'
alias gl='git pull'
alias gco='git checkout'
alias ggp='git push -u origin HEAD'
alias gscrub='git reset --hard @{upstream}'

if [[ "$(command -v hivemind)" ]]; then alias foreman='hivemind'; fi

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

