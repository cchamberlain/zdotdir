#!/usr/bin/env zsh

if [[ -s "$ZPREZTODIR/init.zsh" ]]; then
  . "$ZPREZTODIR/init.zsh"
fi

. /usr/local/Cellar/dnvm/1.0.0-dev/libexec/dnvm.sh
. "$ZSCRIPTDIR/checks.zsh"
. "$ZSCRIPTDIR/colors.zsh"
. "$ZSCRIPTDIR/setopt.zsh"
. "$ZSCRIPTDIR/exports.zsh"
. "$ZSCRIPTDIR/bindkeys.zsh"
. "$ZSCRIPTDIR/prompt.zsh"
. "$ZSCRIPTDIR/completion.zsh"
. "$ZSCRIPTDIR/hashes.zsh"
. "$ZSCRIPTDIR/aliases.zsh"
. "$ZSCRIPTDIR/functions.zsh"
. "$ZSCRIPTDIR/history.zsh"

[[ -f "$ZPERSONAL_PATH" ]] && . "$ZPERSONAL_PATH"

