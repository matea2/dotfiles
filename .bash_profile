#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

set -o vi

export PATH="$PATH:$HOME/bin"
export LANG="ja_JP.UTF-8"
export LESSHISTFILE=-
export BC_ENV_ARGS="-q $HOME/.config/bc"
