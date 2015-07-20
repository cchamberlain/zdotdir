#!/usr/bin/env zsh
# Defines environment variables.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#   Cole Chamberlain <cole.chamberlain@gmail.com
#

export ZDOTDIR="${ZDOTDIR:-"$HOME/.zsh"}"
export ZPREZTO_ROOT="$ZDOTDIR/.zprezto"
export ZSHENV_PATH="$ZDOTDIR/.zshenv"
export ZPROFILE_PATH="$ZDOTDIR/.zprofile"

# Mac OS X uses path_helper and /etc/paths.d to preload PATH, clear it out first
if [ -x /usr/libexec/path_helper ]; then
  PATH=''
  eval `/usr/libexec/path_helper -s`
fi

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "$ZPROFILE_PATH" ]]; then
  . "$ZPROFILE_PATH"
fi

# Get Dot Files
if [[ ! -f "$ZSHENV_PATH" ]]; then
  if [[ -d "$ZDOTDIR" ]]; then
    printf -- "ZDOTDIR is corrupt.  Backup and delete %s and reload..." "$ZDOTDIR"
  fi
  git clone https://github.com/cchamberlain/zdotdir "$ZDOTDIR"
fi

# Get Prezto
if [[ ! -d "$ZPREZTO_ROOT" ]]; then
  git clone --recursive https://github.com/sorin-ionescu/prezto "$ZPREZTO_ROOT"
fi
