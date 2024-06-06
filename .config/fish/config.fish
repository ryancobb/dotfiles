### homebrew ###############################################################################################
if test -d /home/linuxbrew/.linuxbrew # Linux
    set -gx HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew"
    set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
    set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/Homebrew"
else if test -d /opt/homebrew # MacOS
    set -gx HOMEBREW_PREFIX /opt/homebrew
    set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
    set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/homebrew"
end
fish_add_path -gP "$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin"
! set -q MANPATH; and set MANPATH ''
set -gx MANPATH "$HOMEBREW_PREFIX/share/man" $MANPATH
! set -q INFOPATH; and set INFOPATH ''
set -gx INFOPATH "$HOMEBREW_PREFIX/share/info" $INFOPATH
############################################################################################################

set fish_greeting
set -U tide_right_prompt_items status cmd_duration context jobs
set -Ux BAT_THEME ansi
set -Ux EDITOR nvim
set -Ux MANPAGER "sh -c 'col -bx | bat -l man -p'"

alias bx='bundle exec'
alias ll='eza -lbF --git'
alias rg="rg --hidden --glob '!.git'"
alias asdf='mise'

alias gst='git status'
alias gl='git pull'
alias gco='git checkout'
alias ggp='git push -u origin HEAD'
alias gscrub='git reset --hard @{upstream}'

function portkill --argument port
    lsof -t -i:$port | xargs kill -9
end

$HOMEBREW_PREFIX/opt/mise/bin/mise activate fish | source
