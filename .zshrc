#!/usr/bin/env zsh

if [[ -s "$ZPREZTO_ROOT/init.zsh" ]]; then
  . "$ZPREZTO_ROOT/init.zsh"
fi

export GIT_USERNAME="cchamberlain"
export USR_SRC_ROOT="$HOME/cchamberlain"
export GIST_ZSHRC_ID="9cfb3b207f64df45a7ac"
export GIST_ZSHENV_ID="28a690261e9fc1819641"
export GIST_VIMRC_ID="f919af4e9a8a4c3621ac"

export GIT_BASE_URL="https://$GIT_USERNAME@github.com"
export NPM_GIT_SRC="$GIT_BASE_URL/cchamberlain/npm"
export USR_ZSHSCRIPT_ROOT="$ZDOTDIR/zsh"

. "$USR_ZSHSCRIPT_ROOT/checks.zsh"
. "$USR_ZSHSCRIPT_ROOT/colors.zsh"
. "$USR_ZSHSCRIPT_ROOT/setopt.zsh"
. "$USR_ZSHSCRIPT_ROOT/exports.zsh"
. "$USR_ZSHSCRIPT_ROOT/alias.zsh"
. "$USR_ZSHSCRIPT_ROOT/functions.zsh"
