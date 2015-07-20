#!/usr/bin/env zsh

if [[ -s "$ZPREZTO_ROOT/init.zsh" ]]; then
  . "$ZPREZTO_ROOT/init.zsh"
fi


. "$ZSCRIPTDIR/checks.zsh"
. "$ZSCRIPTDIR/colors.zsh"
. "$ZSCRIPTDIR/setopt.zsh"
. "$ZSCRIPTDIR/exports.zsh"
. "$ZSCRIPTDIR/prompt.zsh"
. "$ZSCRIPTDIR/completion.zsh"
. "$ZSCRIPTDIR/hashes.zsh"
. "$ZSCRIPTDIR/aliases.zsh"
. "$ZSCRIPTDIR/functions.zsh"
. "$ZSCRIPTDIR/history.zsh"
