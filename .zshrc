#!/usr/bin/env zsh

if [[ -s "$ZPREZTODIR/init.zsh" ]]; then
  . "$ZPREZTODIR/init.zsh"
fi

# [ -s "$HOME/.dnx/dnvm/dnvm.sh" ] && . "$HOME/.dnx/dnvm/dnvm.sh"
source dnvm.sh
export MONO_MANAGED_WATCHER=disabled

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

